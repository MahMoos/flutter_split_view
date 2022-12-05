library flutter_split_view;

import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PageBuilder = Page Function({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
});

MaterialPage<void> _materialPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    MaterialPage<void>(
      name: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

CupertinoPage<void> _cupertinoPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    CupertinoPage<void>(
      title: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

class _PageConfig {
  final Widget child;
  final String? name;
  final Object? arguments;
  final String? restorationId;
  final bool? fullscreenDialog;

  _PageConfig({
    required this.child,
    this.name,
    this.arguments,
    this.restorationId,
    this.fullscreenDialog,
  });
}

/// A widget that splits the screen into two views automatically when the
/// device's width is greater than [breakpoint].
class SplitView extends StatefulWidget {
  static const _kDefaultBreakpoint = 600.0;
  static const _divider = VerticalDivider();
  static const Color defaultSplitterColor = Colors.grey;
  static const Color defaultActiveSplitterColor =
      Color.fromARGB(0xff, 0x66, 0x66, 0x66);
  static const double defaultSplitterWidth = 12.0;
  static const double defaultInitialWeight = 0.5;
  static const double _weightLimit = 0.01;

  const SplitView.material({
    Key? key,
    required this.child,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
    this.initialWeight = defaultInitialWeight,
    this.divider = _divider,
    this.isResizable = false,
    this.minWidth,
    this.maxWidth,
    this.controller,
    this.splitterWidth = defaultSplitterWidth,
    this.splitterColor = defaultSplitterColor,
    this.activeSplitterColor = defaultActiveSplitterColor,
    this.onWeightChanged,
    this.grip,
    this.activeGrip,
  })  : pageBuilder = _materialPageBuilder,
        assert(initialWeight >= 0.0 && initialWeight <= 1.0),
        super(key: key);

  const SplitView.cupertino({
    Key? key,
    required this.child,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
    this.initialWeight = defaultInitialWeight,
    this.divider = _divider,
    this.isResizable = false,
    this.minWidth,
    this.maxWidth,
    this.controller,
    this.splitterWidth = defaultSplitterWidth,
    this.splitterColor = defaultSplitterColor,
    this.activeSplitterColor = defaultActiveSplitterColor,
    this.onWeightChanged,
    this.grip,
    this.activeGrip,
  })  : pageBuilder = _cupertinoPageBuilder,
        assert(initialWeight >= 0.0 && initialWeight <= 1.0),
        super(key: key);

  const SplitView.custom({
    Key? key,
    required this.child,
    this.breakpoint = _kDefaultBreakpoint,
    this.placeholder,
    this.title,
    this.initialWeight = defaultInitialWeight,
    this.divider = _divider,
    this.isResizable = false,
    this.minWidth,
    this.maxWidth,
    this.controller,
    this.splitterWidth = defaultSplitterWidth,
    this.splitterColor = defaultSplitterColor,
    this.activeSplitterColor = defaultActiveSplitterColor,
    this.onWeightChanged,
    this.grip,
    this.activeGrip,
    required this.pageBuilder,
  }) : assert(initialWeight >= 0.0 && initialWeight <= 1.0),
        super(key: key);

  static SplitViewState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SplitViewState>();
    assert(state != null, 'No SplitViewState found in the context');
    return state!;
  }

  /// The width threshold at which the secondary view will be shown.
  final double breakpoint;

  /// The root page.
  final Widget child;

  /// Title of the root page, used for the back button in Cupertino.
  final String? title;

  /// Initial weight of the main view width to the whole view width
  /// value must be between 0.0 - 1.0
  final double initialWeight;

  /// Placeholder widget to show when the secondary view is visible and no page
  /// is selected.
  final Widget? placeholder;

  /// Divider widget, visible only when [isResizable] is not set.
  /// Defaults to a [VerticalDivider]
  final Widget divider;

  /// Set to true if you want the width to be adjustable
  /// defaults to false
  final bool isResizable;

  /// Minimum width of the child
  final double? minWidth;

  /// Maximum width of the child
  final double? maxWidth;

  /// Controls the views being splitted.
  final SplitViewController? controller;

  /// The splitter width.
  final double splitterWidth;

  /// Splitter background color.
  final Color splitterColor;

  /// Splitter background color when active (hovered or pressed).
  final Color activeSplitterColor;

  /// Called when the user moves the grip.
  final ValueChanged<UnmodifiableListView<double?>>? onWeightChanged;

  /// Grip widget.
  final Widget? grip;

  /// Grip widget for active state.
  final Widget? activeGrip;

  final PageBuilder pageBuilder;

  @override
  SplitViewState createState() => SplitViewState();
}

class SplitViewState extends State<SplitView> {
  var _pages = <Page>[];

  final _pageConfigs = <_PageConfig>[];

  var isSplitted = false;

  late SplitViewController _controller;
  late Color _gripColor;
  Widget? _gripWidget;
  bool _dragging = false;

  late double _startWeight1;
  late double _startWeight2;
  late double _startSize;
  late Offset _startDragPos;

  @override
  void initState() {
    super.initState();
    _pageConfigs.add(
      _PageConfig(child: widget.child, name: widget.title),
    );
    _updatePages();
    _controller =
        widget.controller != null ? widget.controller! : SplitViewController();
    _controller._init(2);
    _controller._weights[0] = widget.initialWeight;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gripColor = widget.splitterColor;
    _gripWidget = widget.grip;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        isSplitted = constraints.maxWidth >= widget.breakpoint;
        double viewsWidth = constraints.maxWidth - widget.splitterWidth;
        if (widget.maxWidth != null &&
            viewsWidth * _controller.weights[0]! > widget.maxWidth!) {
          _controller._weights[0] = widget.maxWidth! / viewsWidth;
        }
        if (widget.minWidth != null &&
            viewsWidth * _controller.weights[0]! < widget.minWidth!) {
          _controller._weights[0] = widget.minWidth! / viewsWidth;
        }
        if (!isSplitted) {
          return Navigator(
            pages: _pages,
            onPopPage: _onPopPage,
          );
        }
        return Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: widget.minWidth ?? 0,
                  maxHeight: widget.maxWidth ?? viewsWidth),
              child: SizedBox(
                width: viewsWidth * _controller.weights[0]!,
                child: Navigator(
                  pages: [_pages.first],
                  onPopPage: _onPopPage,
                ),
              ),
            ),
            if (!widget.isResizable) widget.divider,
            if (widget.isResizable)
              SizedBox(
                width: widget.splitterWidth,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  onEnter: (event) {
                    setState(() {
                      _gripColor = widget.activeSplitterColor;
                      _gripWidget = widget.activeGrip;
                    });
                  },
                  onExit: (_) {
                    if (_dragging == false) {
                      setState(() {
                        _gripColor = widget.splitterColor;
                        _gripWidget = widget.grip;
                      });
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragDown: (details) {
                      _dragging = true;
                      _gripColor = widget.activeSplitterColor;
                      _gripWidget = widget.activeGrip;
                      _startDragPos =
                          _getLocalPosition(context, details.globalPosition);
                      _startWeight1 = _controller.weights[0]!;
                      _startWeight2 = _controller.weights[1]!;
                      _startSize = viewsWidth * _startWeight1;
                    },
                    onHorizontalDragEnd: (details) {
                      _dragging = false;
                      setState(() {
                        _gripColor = widget.splitterColor;
                        _gripWidget = widget.grip;
                      });
                    },
                    onHorizontalDragUpdate: (detail) {
                      final pos =
                          _getLocalPosition(context, detail.globalPosition);
                      var diff = pos.dx - _startDragPos.dx;
                      _changeWeights(diff, viewsWidth);
                    },
                    child: Container(
                      color: _gripColor,
                      alignment: Alignment.center,
                      child: _gripWidget,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _buildSecondaryView(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecondaryView() {
    if (_pages.length == 1) {
      return widget.placeholder ?? Container();
    }

    return Navigator(
      pages: _pages.sublist(1),
      onPopPage: _onPopPage,
    );
  }

  void push(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    final pageConfig = _PageConfig(
      child: page,
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    _pageConfigs.add(pageConfig);

    setState(_updatePages);
  }

  void pop() {
    if (_pageConfigs.length == 1) {
      return;
    }

    _pageConfigs.removeLast();

    setState(_updatePages);
  }

  /// Number of pages in the stack.
  int get pageCount => _pageConfigs.length;

  /// Replaces the page at [index] with [page].
  void replace({
    required int index,
    required Widget page,
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _pageConfigs[index] = _PageConfig(
      child: page,
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    setState(_updatePages);
  }

  /// Pops the pages until the [index]-th is reached.
  void popUntil(int index) {
    if (index < 0 || index >= pageCount) {
      throw ArgumentError('Index $index is out of bounds');
    }

    while (pageCount - 1 > index) {
      _pageConfigs.removeLast();
    }

    setState(_updatePages);
  }

  /// Sets the page displayed at seconday view. This clears all other pages on
  /// top of the page displayed at secondary view (aka 2nd page in the stack).
  void setSecondary(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _pageConfigs.removeRange(1, _pageConfigs.length);

    _pageConfigs.add(
      _PageConfig(
        child: page,
        name: title,
        arguments: arguments,
        restorationId: restorationId,
        fullscreenDialog: fullscreenDialog,
      ),
    );

    setState(_updatePages);
  }

  bool get isSecondaryVisible {
    return isSplitted;
  }

  void _updatePages() {
    final pages = <Page>[];
    for (var i = 0; i < _pageConfigs.length; i++) {
      final pageConfig = _pageConfigs[i];
      final pageKey = ValueKey(i);
      final page = widget.pageBuilder(
        key: pageKey,
        child: pageConfig.child,
        title: pageConfig.name,
        arguments: pageConfig.arguments,
        restorationId: pageConfig.restorationId,
      );
      pages.add(page);
    }
    _pages = pages;
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (_pageConfigs.length <= 1) {
      return false;
    }
    if (route.didPop(result)) {
      _pageConfigs.removeLast();
      _updatePages();
      return true;
    }
    return false;
  }

  void _changeWeights(double diff, double size, [int index = 0]) {
    if (_startSize + diff > size ||
        widget.maxWidth != null && _startSize + diff > widget.maxWidth! ||
        _startSize + diff < 0 ||
        widget.minWidth != null && _startSize + diff < widget.minWidth!) return;
    var newWeight1 = (_startSize + diff) / size;
    newWeight1 = _adjustWeight(newWeight1, _controller.limits[index]);
    if (_controller.limits[index] != null) {
      if (_controller.limits[index]!.min != null) {
        newWeight1 = max(newWeight1, _controller.limits[index]!.min!);
      }
      if (_controller.limits[index]!.max != null) {
        newWeight1 = min(newWeight1, _controller.limits[index]!.max!);
      }
    }
    var newWeight2 = _startWeight1 + _startWeight2 - newWeight1;
    if (_controller.limits[index + 1] != null) {
      if (_controller.limits[index + 1]!.min != null) {
        newWeight2 = max(newWeight2, _controller.limits[index + 1]!.min!);
      }
      if (_controller.limits[index + 1]!.max != null) {
        newWeight2 = min(newWeight2, _controller.limits[index + 1]!.max!);
      }
      newWeight1 = _startWeight1 + _startWeight2 - newWeight2;
    }
    setState(() {
      _controller._weights[index] = newWeight1;
      _controller._weights[index + 1] = newWeight2;
    });

    if (widget.onWeightChanged != null) {
      widget.onWeightChanged!(_controller.weights);
    }
  }

  Offset _getLocalPosition(BuildContext context, Offset pos) {
    var container = context.findRenderObject() as RenderBox;
    return container.globalToLocal(pos);
  }

  double _adjustWeight(double weight, WeightLimit? limit) {
    var w = min(weight, _startWeight1 + _startWeight2 - SplitView._weightLimit);
    w = max(w, SplitView._weightLimit);
    return w;
  }
}

/// Controller for [Splitview]
class SplitViewController {
  /// Specifies the weight of each views.
  UnmodifiableListView<double?> get weights => UnmodifiableListView(_weights);

  /// Specifies the limits of each views.
  UnmodifiableListView<WeightLimit?> get limits =>
      UnmodifiableListView(_limits);

  List<double?> _weights;
  List<WeightLimit?> _limits;

  SplitViewController._(this._weights, this._limits);

  /// Creates a [SplitViewController]
  ///
  /// The [weights] specifies the ratio in the view. The sum of the [weights] cannot exceed 1.
  factory SplitViewController(
      {List<double?>? weights, List<WeightLimit?>? limits}) {
    weights ??= List.empty(growable: true);
    limits ??= List.empty(growable: true);
    return SplitViewController._(weights, limits);
  }

  void _init(int length) {
    if (_weights.length < length) {
      _weights.length = length;
    }
    if (_limits.length < length) {
      _limits.length = length;
    }
    int nullCnt = _weights.where((element) => element == null).length;
    double weightSum = 0.0;
    for (var weight in _weights) {
      weightSum += weight ?? 0;
    }
    double weightRemain = 1.0 - weightSum;
    double calcWeight = weightRemain / nullCnt;
    for (int i = 0; i < _weights.length; i++) {
      if (_weights[i] == null) {
        _weights[i] = calcWeight;
      }
    }
  }
}

/// A WeightLimit class.
class WeightLimit {
  /// Minimal weight limit.
  final double? min;

  /// Maximum weight limit.
  final double? max;

  WeightLimit({this.min, this.max});
}
