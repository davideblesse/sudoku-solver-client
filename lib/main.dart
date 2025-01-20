import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_page.dart'; // Import the camera page

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(camera: firstCamera), // HomePage is now the starting point
    ),
  );
}

// HomePage widget to navigate to the camera page
class HomePage extends StatelessWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to TakePictureScreen when the button is pressed
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TakePictureScreen(camera: camera),
              ),
            );
          },
          child: const Text('Go to Camera'),
        ),
      ),
    );
  }
}
