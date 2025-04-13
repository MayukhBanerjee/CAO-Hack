import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:edgefusion/screens/results_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick an image first!')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.17.215.85:5000/process_image'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(imageBytes: bytes),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error while processing image.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EdgeFusion',
          style: GoogleFonts.specialElite(
            fontWeight: FontWeight.w800,
            color: const Color.fromARGB(255, 255, 48, 48),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 29, 6, 6),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://ik.imagekit.io/hp0zzdnkn/imgbg?updatedAt=1744537104793',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: screenHeight * 0.4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Center(child: Text('No image selected')),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: Text(
                        'Pick Image',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: _isProcessing
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              'Process Image',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      onPressed: _isProcessing ? null : _processImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
