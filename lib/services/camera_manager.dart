import 'package:camera/camera.dart';

class CameraManager {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  Future<void> initializeCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
  }
  
  CameraController get controller => _controller;
  
  Future<void> get initializationFuture => _initializeControllerFuture;
  
  Future<XFile> captureImage() async {
    return await _controller.takePicture();
  }
  
  void dispose() {
    _controller.dispose();
  }
}
