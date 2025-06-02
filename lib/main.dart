import 'package:flutter/material.dart';
import 'package:qsb/screens/home_page.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState()  =>_AppState();

}

class _AppState extends State<App>{
  bool _isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // You could use Provider or a state manager to update the whole app
  }
  @override
  Widget build(BuildContext context ) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      title: 'SecureShareBox',
      home: HomePage(toggleDarkMode: _toggleDarkMode,isDarkMode: _isDarkMode,),
    );
  }

}
