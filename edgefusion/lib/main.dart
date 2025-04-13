import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(EdgeFusionApp());
}

class EdgeFusionApp extends StatelessWidget {
  const EdgeFusionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdgeFusion',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
