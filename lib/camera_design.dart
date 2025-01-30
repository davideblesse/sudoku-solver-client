import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

class CameraDesign extends StatelessWidget {
  final double squareSize;
  final CameraController controller;
  final int gridLines;

  const CameraDesign({
    super.key,
    required this.squareSize,
    required this.controller,
    required this.gridLines,
  });

 @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).scaffoldBackgroundColor, // Beige background color (or use your theme color)
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          // Camera preview with grid overlay and yellow borders
          Center(
            child: Column(
              children: [
                // Add the text directly above the camera preview
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Try Me With a (Hard) Sudoku ;)", // Updated text
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, // Yellow text color
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins', // Use the Poppins font from Google Fonts
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Camera preview
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary, // Yellow border color
                      width: 4, // Border thickness
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cropped camera preview
                      ClipRect(
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
                      ),

                      // Grid overlay
                      CustomPaint(
                        size: Size(squareSize, squareSize),
                        painter: GridPainter(
                          gridLines: gridLines,
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8), // Yellow grid
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Add some space at the bottom
          const SizedBox(height: 20),
        ],
      ),
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





