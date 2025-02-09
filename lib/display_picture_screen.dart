import 'package:flutter/material.dart';
import 'dart:io';

import 'api_service.dart';
import 'edit_digits_page.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  Future<void> _sendImage() async {
    setState(() => _isProcessing = true);

    final recognizedDigits = await _apiService.sendImageToServer(widget.imagePath);

    setState(() => _isProcessing = false);

    if (recognizedDigits != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditDigitsPage(digits: recognizedDigits),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to recognize digits.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selected Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(widget.imagePath)),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _sendImage,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.send, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
