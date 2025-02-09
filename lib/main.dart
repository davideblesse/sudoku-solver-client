import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/splash_screen.dart';

const Color primaryColor = Colors.red;
const Color secondaryColor = Colors.white;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MySudokuSolverApp(cameras: cameras));
}

class MySudokuSolverApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const MySudokuSolverApp({Key? key, required this.cameras}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Solver',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        scaffoldBackgroundColor: secondaryColor,
        fontFamily: 'Arial',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(cameras: cameras),
    );
  }
}
