import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_solver_android/camera_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'edit_digits_page.dart';
import 'solution_screen.dart';
import 'camera_design.dart'; // Import the design file

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

  Future<void> sendImageToServer(String imagePath, BuildContext context) async {
    try {
      final url = Uri.parse('https://sudoku-solver-app-v0gc.onrender.com/process-image'); // Endpoint for image processing
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        if (decodedData.containsKey('solution')) {
          final recognizedDigits = decodedData['solution']
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditDigitsPage(digits: recognizedDigits),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to recognize digits.')),
          );
        }
      } else {
        print("Failed to upload image: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send the image.')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture of Your Sudoku'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.indigoAccent,
      body: Center(
        child: FutureBuilder<void>(
          future: _cameraService.getInitializationFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final controller = _cameraService.getController();
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Use the smaller side of the screen to define the square size
                  final double squareSize = math.min(constraints.maxWidth, constraints.maxHeight);

                  return CameraDesign(
                    squareSize: squareSize,
                    controller: controller,
                    gridLines: _gridLines,
                  );
                },
              );
            } else {
              return const CircularProgressIndicator(color: Colors.blue);
            }
          },
        ),
      ),
    floatingActionButton: FloatingActionButton(
    onPressed: () async {
    try {
    final image = await _cameraService.takePicture();
    if (!context.mounted) return;

    // Send the image to the server and navigate to SolutionScreen
    await sendImageToServer(image.path, context);
    } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to take a picture.')),
    );
    }
    },
    backgroundColor: Colors.yellowAccent,
    child: const Icon(Icons.camera_alt, color: Colors.black),
    ),
      // Center the button at the bottom
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}



