import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sudoku_solver_android/take_picture_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// Define beige globally so it can be used everywhere
const Color beige = Color.fromARGB(255, 161, 140, 124);

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: beige, // Use the globally defined beige color
        colorScheme: ColorScheme.fromSeed(
          seedColor: beige,
          primary: beige,
          secondary: const Color.fromARGB(255, 255, 214, 79), // Accent color
        ),
        scaffoldBackgroundColor: beige, // Background color for all screens
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    // Customizing specific text styles
    titleLarge: TextStyle(
      color: const Color.fromARGB(255, 255, 214, 79), // Yellow for important text
      fontSize: 24,
      fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Colors.black, // Ensures readability on beige
          ),
        ),
      ),
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
