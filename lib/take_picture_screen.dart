import 'dart:io';
import 'dart:math' as math; // Import math for calculations
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_solver_android/camera_service.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraService _cameraService;
  final int _gridLines = 9; // 9x9 grid

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

  /// Builds a cropped square camera preview
  Widget buildCroppedCameraPreview(CameraController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller side of the screen to define the square size
        final double squareSize = math.min(constraints.maxWidth, constraints.maxHeight);

        return ClipRect(
          child: SizedBox(
            width: squareSize,
            height: squareSize,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Transform.rotate(
                  angle: math.pi / 2, // Rotate 90 degrees clockwise
                  child: SizedBox(
                    width: squareSize,
                    height: squareSize / controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Sudoku Picture'),
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.green[900],
      body: Center(
        child: FutureBuilder<void>(
          future: _cameraService.getInitializationFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final controller = _cameraService.getController();

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Cropped camera preview
                  buildCroppedCameraPreview(controller),

                  // Grid overlay on top of the preview
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double squareSize = math.min(constraints.maxWidth, constraints.maxHeight);
                      return SizedBox(
                        width: squareSize,
                        height: squareSize,
                        child: CustomPaint(
                          painter: GridPainter(
                            gridLines: _gridLines,
                            color: Colors.green.withOpacity(0.6),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _cameraService.takePicture();
            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// GridPainter: Draws the grid on the camera preview
class GridPainter extends CustomPainter {
  final int gridLines; // Number of grid lines (e.g., 9x9 grid)
  final Color color; // Grid color

  GridPainter({required this.gridLines, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    final cellSize = size.width / gridLines;

    // Draw vertical lines
    for (int i = 1; i < gridLines; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < gridLines; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// DisplayPictureScreen: Displays the captured image
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
