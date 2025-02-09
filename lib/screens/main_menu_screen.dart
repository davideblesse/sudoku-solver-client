import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/gallery_image_picker.dart';
import 'capture_sudoku_screen.dart';
import 'image_preview_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final CameraDescription? camera;

  const MainMenuScreen({Key? key, this.camera}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;
  final GalleryImagePicker _galleryPicker = GalleryImagePicker();

  @override
  void initState() {
    super.initState();

    // Animated gradient background transition
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.deepPurpleAccent,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _backgroundAnimationController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final imagePath = await _galleryPicker.pickImageFromGallery();
    if (imagePath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: imagePath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.8;

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
              // Logo with subtle fade effect
              AnimatedOpacity(
                opacity: 0.15,
                duration: const Duration(seconds: 2),
                child: Image.asset(
                  'assets/ss_logo_nobg.png',
                  width: buttonWidth,
                  height: buttonWidth,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Capture Sudoku Button
              SizedBox(
                width: buttonWidth,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: widget.camera != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CaptureSudokuScreen(camera: widget.camera!),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
                  label: const Text(
                    'Capture Sudoku from Camera',
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

              const SizedBox(height: 20),

              // Choose Sudoku from Gallery Button
              SizedBox(
                width: buttonWidth,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: const Icon(Icons.photo_library, size: 24, color: Colors.white),
                  label: const Text(
                    'Choose Sudoku from Gallery',
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
            ],
          ),
        ),
      ),
    );
  }
}
