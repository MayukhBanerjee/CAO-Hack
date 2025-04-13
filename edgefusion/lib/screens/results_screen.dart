import 'package:flutter/material.dart';
import 'dart:typed_data';

class ResultScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const ResultScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Processed Image',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://ik.imagekit.io/hp0zzdnkn/imgbg?updatedAt=1744537104793',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                Container(
                  height: screenHeight * 0.5,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(imageBytes, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.2,
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
