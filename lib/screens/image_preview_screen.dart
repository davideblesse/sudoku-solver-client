import 'dart:io';
import 'package:flutter/material.dart';
import '../services/sudoku_api_service.dart';
import 'edit_recognized_digits_screen.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  final SudokuApiService _apiService = SudokuApiService();
  bool _isProcessing = false;
  
  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Background gradient animation
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.deepPurpleAccent,
    ).animate(
      CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.easeInOut),
    );

    _backgroundAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    setState(() => _isProcessing = true);

    final recognizedDigits = await _apiService.sendImageForProcessing(widget.imagePath);

    setState(() => _isProcessing = false);

    if (recognizedDigits != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EditRecognizedDigitsScreen(digits: recognizedDigits),
        ),
      );
    } else {
      _showErrorSnackBar('Failed to recognize digits.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.black,
                  Colors.deepPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Text
              const Text(
                'Preview Sudoku Image',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Image preview in a card with a subtle elevation
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Image.file(
                      File(widget.imagePath),
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Show a loading indicator when processing
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      
      // Floating Button (Now Styled as a Full-Width Button)
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processImage,
            icon: const Icon(Icons.auto_fix_high, color: Colors.white),
            label: const Text(
              'Solve Sudoku',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
