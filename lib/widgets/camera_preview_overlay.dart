import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

class CameraPreviewOverlay extends StatelessWidget {
  final double squareSize;
  final CameraController controller;
  final int gridLines;
  
  const CameraPreviewOverlay({
    Key? key,
    required this.squareSize,
    required this.controller,
    required this.gridLines,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Caption above the preview.
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            "Try Me With a (Hard) Sudoku ;)",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Camera preview with border and grid.
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 4,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: SizedBox(
                  width: squareSize,
                  height: squareSize,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Transform.rotate(
                        angle: math.pi / 2,
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
              CustomPaint(
                size: Size(squareSize, squareSize),
                painter: GridOverlayPainter(
                  gridLines: gridLines,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class GridOverlayPainter extends CustomPainter {
  final int gridLines;
  final Color color;
  
  GridOverlayPainter({required this.gridLines, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    
    final cellSize = size.width / gridLines;
    // Draw vertical lines.
    for (int i = 1; i < gridLines; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Draw horizontal lines.
    for (int i = 1; i < gridLines; i++) {
      final y = i * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
