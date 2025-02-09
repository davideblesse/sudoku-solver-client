import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'take_picture_screen.dart';
import 'display_picture_screen.dart';
import 'image_service.dart';

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: secondaryColor,
        fontFamily: 'Arial', // Default system font
      ),
      home: SplashScreen(cameras: cameras),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for the scale transition.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animate the scale from 0.5 to 1.0 with an ease-out curve.
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the animation.
    _animationController.forward();

    // Navigate to HomePage after 3 seconds.
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            camera: widget.cameras.isNotEmpty ? widget.cameras.first : null,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the full screen width.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Use a full-screen gradient background for a modern look.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated scale transition for the logo image.
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/ss_logo_nobg.png',
                  width: screenWidth * 1.0, // Make the logo as wide as the screen.
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              // A catchy tagline below the logo.
              const Text(
                'Capture & Solve Your Sudoku!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final CameraDescription? camera;
  final ImageService _imageService = ImageService();

  HomePage({Key? key, this.camera}) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final imagePath = await _imageService.pickImageFromGallery();
    if (imagePath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: imagePath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with low opacity for a subtle watermark.
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Center(
                child: Image.asset(
                  'assets/ss_logo_nobg.png',
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Main content with buttons.
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: camera != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TakePictureScreen(camera: camera!),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.camera_alt, color: secondaryColor),
                  label: const Text(
                    'Capture Sudoku from Camera',
                    style: TextStyle(color: secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(context),
                  icon: const Icon(Icons.photo_library, color: primaryColor),
                  label: const Text(
                    'Choose Sudoku from Gallery',
                    style: TextStyle(color: primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    side: const BorderSide(
                        color: primaryColor, width: 2), // Adds a border.
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
