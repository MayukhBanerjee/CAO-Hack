import 'package:flutter/material.dart';
import 'dart:async';
import 'package:edgefusion/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFading = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });

    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!isLoading) {
        timer.cancel();
      }
      setState(() {
        isFading = !isFading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: isFading ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 800),
              child: Image.network(
                'https://ik.imagekit.io/hp0zzdnkn/icon.png?updatedAt=1744541273063',
                width: 700,
                height: 300,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
