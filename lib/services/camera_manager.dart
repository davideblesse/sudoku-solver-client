import 'package:camera/camera.dart';

class CameraManager {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  
  Future<void> initializeCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
  }
  
CameraController get controller {
  if (!_controller.value.isInitialized) {
    throw Exception("Camera is not initialized");
  }
  return _controller;
}
  
  Future<void> get initializationFuture => _initializeControllerFuture;
  
Future<XFile> captureImage() async {
  await _initializeControllerFuture; // Ensure initialization is completed
  if (!_controller.value.isInitialized || _controller.value.isTakingPicture) {
    throw Exception("Camera is not ready");
  }
  return await _controller.takePicture();
}

  
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
  }
}
