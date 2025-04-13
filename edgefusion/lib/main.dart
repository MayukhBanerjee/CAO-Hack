import 'package:flutter/material.dart';

import 'package:edgefusion/home_screen.dart';

void main() => runApp(EdgeFusionApp());

class EdgeFusionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EdgeFusion',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
