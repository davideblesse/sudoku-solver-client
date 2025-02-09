import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:sudoku_solver_client_2/camera_service.dart';
import 'edit_digits_page.dart';

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late final CameraService _cameraService;
  static const int _gridLines = 9;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _cameraService.initCamera(widget.camera);
  }

  @override
  void dispose() {
    _cameraService.disposeCamera();
    super.dispose();
  }

  /// Fixes image rotation and sends it to the server.
  Future<void> _processCapturedImage(String imagePath, BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final Uri url = Uri.parse('https://sudoku-solver-from-image.onrender.com/process-image');

    try {
      final fixedImage = await FlutterExifRotation.rotateImage(path: imagePath);

      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', fixedImage.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decodedData = json.decode(responseData);
        if (decodedData.containsKey('solution')) {
          _navigateToEditDigitsPage(decodedData['solution'], context);
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

  /// Navigates to the EditDigitsPage with recognized Sudoku numbers.
  void _navigateToEditDigitsPage(String solution, BuildContext context) {
    final recognizedDigits = solution.split(',').map((e) => int.parse(e.trim())).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditDigitsPage(digits: recognizedDigits),
      ),
    );
  }

  /// Shows an error message in a snackbar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width * 0.9; // Ensure square

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Capture Your Sudoku',
          style: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Square Camera Preview with Rotation Fix
            FutureBuilder<void>(
              future: _cameraService.getInitializationFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final controller = _cameraService.getController();
                  return SizedBox(
                    width: screenSize,
                    height: screenSize,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: screenSize * controller.value.aspectRatio,
                            height: screenSize,
                            child: Transform.rotate(
                              angle: math.pi / 2, // Fix preview rotation
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  );
                }
              },
            ),
            // Overlay Grid for Sudoku Alignment
            CustomPaint(
              size: Size(screenSize, screenSize),
              painter: GridPainter(),
            ),
            // Instruction Overlay
            Positioned(
              bottom: 100, // Adjusted to not overlap with the FAB
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Place your Sudoku inside the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isProcessing
          ? CircularProgressIndicator(color: primaryColor)
          : FloatingActionButton(
              onPressed: () async {
                try {
                  final image = await _cameraService.takePicture();
                  if (!context.mounted) return;
                  await _processCapturedImage(image.path, context);
                } catch (e) {
                  _showErrorSnackBar('Failed to take a picture.');
                }
              },
              backgroundColor: primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Paints a clean 9x9 grid overlay for Sudoku alignment.
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double cellSize = size.width / 9;

    for (int i = 1; i < 9; i++) {
      final bool isBoldLine = (i % 3 == 0);
      paint.strokeWidth = isBoldLine ? 2 : 1;

      // Vertical lines
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), paint);
      // Horizontal lines
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
