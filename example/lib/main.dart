// ignore_for_file: prefer_const_constructors,
// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_split_view/flutter_split_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Split View Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple[500],
        scaffoldBackgroundColor: Colors.grey[100]
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Split View'),
        centerTitle: false,
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SplitView.material(
          breakpoint: 840,
          initialWeight: 0.4,
          isResizable: true,
          minWidth: 320,
          maxWidth: 640,
          splitterWidth: 12,
          splitterColor: Colors.transparent,
          activeSplitterColor: Colors.transparent,
          grip: const Grip(),
          activeGrip: const Grip.active(),
          placeholder: const PlaceholderPage(),
          child: const MainPage(),
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Main Page"),
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              child: const Text('click'),
              onPressed: () {
                SplitView.of(context).setSecondary(
                  const SecondPage(),
                  title: 'Second',
                );
              },
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).cardColor,
          ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Second Page"),
            ),
            Spacer(),
            ElevatedButton(
              child: const Text('back'),
              onPressed: () {
                SplitView.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('forward'),
              onPressed: () {
                SplitView.of(context).push(
                  const ThirdPage(),
                  title: 'Third',
                );
              },
            ),
            Spacer(),
          ],
        ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).cardColor,
          ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Third Page"),
          ),
          Spacer(),
          ElevatedButton(
              child: const Text('back'),
              onPressed: () {
                SplitView.of(context).pop();
              },
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Click the button in main view to push to here',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class Grip extends StatelessWidget {
  const Grip({Key? key})
      : _isActive = false,
        super(key: key);

  const Grip.active({Key? key})
      : _isActive = true,
        super(key: key);

  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isActive ? Theme.of(context).primaryColor : Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      width: _isActive ? 5 : 4,
      height: _isActive ? 64 : 56,
    );
  }
}
