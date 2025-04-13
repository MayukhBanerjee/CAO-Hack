import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  Uint8List? _processedImageBytes;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _processedImageBytes = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://<YOUR_FLASK_BACKEND>/process_image');
    final request = http.MultipartRequest('POST', url);
    request.files
        .add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      setState(() {
        _processedImageBytes = bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to process image.'),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EdgeFusion - Sobel Edge Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200),
            if (_processedImageBytes != null)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text("Processed Image:"),
                  Image.memory(_processedImageBytes!, height: 200),
                ],
              ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _processImage,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Process Image'),
            ),
          ],
        ),
      ),
    );
  }
}
