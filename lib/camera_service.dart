import 'package:camera/camera.dart';
import 'dart:async';

class CameraService {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  //Initialize the camera
  Future<void> initCamera(CameraDescription camera) async{
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
  }

  //Get the controller for the camera
  CameraController getController() {
    return _controller;
  }

  // Get the initialization future
  Future<void> getInitializationFuture(){
    return _initializeControllerFuture;
  }

  // Take a picture
  Future<XFile> takePicture() async {
    return await _controller.takePicture();
  }

  //Dispose the camera controller
  void disposeCamera() {
    _controller.dispose();
  }
}