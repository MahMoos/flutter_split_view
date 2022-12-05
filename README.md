## flutter_split_view

A Navigator 2.0 based Flutter widget that automatically splits the screen into two views based on available space with the ability to make the width of the views adjustable.

![Demo](https://raw.githubusercontent.com/TerminalStudio/flutter_split_view/main/media/demo.gif?token=GHSAT0AAAAAABIZ4MCR753WLCN4QECYUMSSYPJPDSQ)

### Usage

```dart
MaterialApp(
    title: 'SplitView Demo',
    home: SplitView.material(
        child: MainPage(),
    ),
);
```

Cupertino: 

```dart
CupertinoApp(
    title: 'SplitView Demo',
    home: SplitView.cupertino(
        child: MainPage(),
    ),
);
```

#### Resizable Width

```dart
SplitView.material(
    breakpoint: 840,
    initialWeight: 0.4,
    isResizable: true,
    minWidth: 320,
    maxWidth: 640,
    splitterWidth: 8,
    splitterColor: Theme.of(context).scaffoldBackgroundColor,
    activeSplitterColor: Theme.of(context).scaffoldBackgroundColor,
    grip: const Grip(),
    activeGrip: const Grip.active(),
    placeholder: const PlaceholderPage(),
    child: const MainPage(),
);
```

### Navigating

#### Push

```dart
SplitView.of(context).push(SecondPage());
```

Push with an optional title, which will be used as the back button's title in
Cupertino:

```dart
SplitView.of(context).push(
    SecondPage(),
    title: 'Second',
);
```


#### Pop

```dart
SplitView.of(context).pop();
```

Pop until the n-th page:

```dart
SplitView.of(context).popUntil(1);
```

#### Set the page displayed in the secondary view

```dart
SplitView.of(context).setSecondary(SecondPage());
```

This will clear the stack and push the new page, making it the second page in the stack.

### Get whether the secondary view is visible

```dart 
SplitView.of(context).isSecondaryVisible;
```

### Example


- [example/lib/main.dart](https://github.com/TerminalStudio/flutter_split_view/blob/main/example/lib/main.dart)
- [example/lib/main_cupertino.dart](https://github.com/TerminalStudio/flutter_split_view/blob/main/example/lib/main_cupertino.dart)