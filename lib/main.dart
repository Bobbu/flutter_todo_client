import 'package:flutter/material.dart';
import 'pages/todos_page.dart';
import 'themes/dark_theme.dart';
import 'themes/light_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todos Using Flutter',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const TodosPage(),
    );
  }
}
