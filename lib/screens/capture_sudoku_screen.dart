import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_manager.dart';
import 'image_preview_screen.dart';

class CaptureSudokuScreen extends StatefulWidget {
  final CameraDescription camera;

  const CaptureSudokuScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CaptureSudokuScreenState createState() => _CaptureSudokuScreenState();
}

class _CaptureSudokuScreenState extends State<CaptureSudokuScreen>
    with SingleTickerProviderStateMixin {
  late final CameraManager _cameraManager;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;

  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _cameraManager = CameraManager();
    _initializeCamera();

    // Animated background
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

  Future<void> _initializeCamera() async {
    try {
      await _cameraManager.initializeCamera(widget.camera);
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      _showErrorSnackBar("Failed to initialize camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraManager.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double squareSize = screenWidth * 0.85;

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
              // Instruction text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Align the Sudoku inside the square',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Camera preview in a rounded square container
              Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _isCameraInitialized
                      ? FittedBox(
                          fit: BoxFit.cover, // Ensure correct scaling & prevent stretching
                          child: SizedBox(
                            width: _cameraManager.controller.value.previewSize?.height ?? squareSize,
                            height: _cameraManager.controller.value.previewSize?.width ?? squareSize,
                            child: CameraPreview(_cameraManager.controller),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
      // Floating action button to capture image
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing || !_isCameraInitialized
            ? null
            : () async {
                try {
                  setState(() => _isProcessing = true);
                  final image = await _cameraManager.captureImage();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          ImagePreviewScreen(imagePath: image.path),
                    ),
                  );
                } catch (e) {
                  _showErrorSnackBar('Failed to capture image.');
                } finally {
                  setState(() => _isProcessing = false);
                }
              },
        backgroundColor: Colors.white.withOpacity(0.3),
        elevation: 5,
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
