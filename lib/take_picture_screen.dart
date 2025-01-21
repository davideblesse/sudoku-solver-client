import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_solver_android/camera_service.dart';
import 'dart:math' as math;

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
  final int _gridLines = 8;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Sudoku Picture'),
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.green[900],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<void>(
              future: _cameraService.getInitializationFuture(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Transform.rotate(
                    angle: math.pi / 2,
                    child: AspectRatio(
                      aspectRatio: _cameraService.getController().value.aspectRatio,
                      child: CameraPreview(_cameraService.getController()),
                    ),
                  );
                } else {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));
                }
              },
            ),
            FutureBuilder<void>(
                future: _cameraService.getInitializationFuture(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Transform.rotate(
                      angle: math.pi / 2,
                      child: LayoutBuilder(
                          builder: (context, constraints){
                            return  AspectRatio(
                                aspectRatio: _cameraService.getController().value.aspectRatio,
                                child: CustomPaint(
                                    painter: GridPainter(
                                      gridLines: _gridLines,
                                      color: Colors.green.withOpacity(0.4),
                                    )
                                )
                            );
                          }
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }
            ),
          ],
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
          child: const Icon(Icons.camera_alt, color: Colors.white)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Custom painter class for drawing grid lines
class GridPainter extends CustomPainter {
  final int gridLines;
  final Color color;

  GridPainter({required this.gridLines, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    for (int i = 1; i <= gridLines; i++) {
      final double y = size.height * i / (gridLines + 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (int i = 1; i <= gridLines; i++) {
      final double x = size.width * i / (gridLines + 1);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Picture taken'),
          backgroundColor: Colors.red
      ),
      body: Image.file(File(imagePath)),
    );
  }
}