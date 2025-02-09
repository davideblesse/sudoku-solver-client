import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import '../services/camera_manager.dart';
import 'edit_recognized_digits_screen.dart';

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
  late final AnimationController _backgroundAnimationController;
  late final Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _cameraManager = CameraManager();
    _cameraManager.initializeCamera(widget.camera);

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
    _cameraManager.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _processCapturedImage(String imagePath) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final Uri url = Uri.parse('https://sudoku-solver-from-image.onrender.com/process-image-test');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseData);
        if (decodedData.containsKey('solution')) {
          _navigateToEditDigitsScreen(decodedData['solution']);
        } else {
          _showErrorSnackBar('Failed to recognize digits.');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _navigateToEditDigitsScreen(String solution) {
    final recognizedDigits = solution.split('') // Split by character, not comma
        .map((e) => int.parse(e.trim())) // Convert each digit to int
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditRecognizedDigitsScreen(digits: recognizedDigits),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double gridSize = screenSize.width * 0.8;
    final double gridLeft = (screenSize.width - gridSize) / 2;
    final double gridTop = (screenSize.height - gridSize) / 2.5;

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
        child: Stack(
          children: [
            // Full-screen camera preview
            Positioned.fill(
              child: FutureBuilder<void>(
                future: _cameraManager.initializationFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_cameraManager.controller);
                  } else {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                },
              ),
            ),
            // Semi-transparent layer surrounding the grid
            Positioned.fill(
              child: CustomPaint(
                painter: SurroundingOverlayPainter(
                  gridSize: gridSize,
                  gridLeft: gridLeft,
                  gridTop: gridTop,
                ),
              ),
            ),
            // Grid overlay
            Positioned(
              left: gridLeft,
              top: gridTop,
              width: gridSize,
              height: gridSize,
              child: CustomPaint(
                painter: CaptureGridPainter(),
              ),
            ),
            // Instruction overlay
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Align your Sudoku inside the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isProcessing
          ? const CircularProgressIndicator(color: Colors.white)
          : FloatingActionButton(
              onPressed: () async {
                try {
                  final image = await _cameraManager.captureImage();
                  if (!mounted) return;
                  await _processCapturedImage(image.path);
                } catch (e) {
                  _showErrorSnackBar('Failed to take a picture.');
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

/// **📌 Grid Overlay for Camera Preview**
class CaptureGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke;

    // Draw rounded border
    final double borderRadius = 20.0;
    final RRect roundedRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(roundedRect, borderPaint);

    // Draw grid lines
    final double cellSize = size.width / 9;
    for (int i = 1; i < 9; i++) {
      linePaint.strokeWidth = (i % 3 == 0) ? 2 : 1;
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), linePaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// **📌 Dark Overlay Surrounding the Grid with Proper Rounded Borders**
class SurroundingOverlayPainter extends CustomPainter {
  final double gridSize, gridLeft, gridTop, borderRadius;

  SurroundingOverlayPainter({
    required this.gridSize,
    required this.gridLeft,
    required this.gridTop,
    this.borderRadius = 20.0, // Ensure it matches the grid's border radius
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);

    // Full-screen dark overlay
    Path fullScreenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Transparent rounded rectangle (cut-out area for the grid)
    RRect transparentGridArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(gridLeft, gridTop, gridSize, gridSize),
      Radius.circular(borderRadius),
    );

    // Create a Path for the transparent area
    Path transparentPath = Path()..addRRect(transparentGridArea);

    // Combine paths using even-odd fill type to create a "hole" effect
    fullScreenPath.addPath(transparentPath, Offset.zero, matrix4: Matrix4.identity().storage);
    fullScreenPath.fillType = PathFillType.evenOdd;

    // Draw the overlay with the transparent cutout
    canvas.drawPath(fullScreenPath, overlayPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

