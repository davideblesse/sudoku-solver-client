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

class _CaptureSudokuScreenState extends State<CaptureSudokuScreen> {
  late final CameraManager _cameraManager;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _cameraManager = CameraManager();
    _initializeCamera();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double squareSize = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isCameraInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRect(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CameraPreview(_cameraManager.controller),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 120,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Align the Sudoku inside the square',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing || !_isCameraInitialized
            ? null
            : () async {
                try {
                  setState(() => _isProcessing = true);
                  final image = await _cameraManager.captureImage();
                  if (!mounted) return;

                  // Navigate to ImagePreviewScreen using pushReplacement
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imagePath: image.path),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
