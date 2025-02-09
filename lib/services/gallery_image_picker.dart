import 'package:image_picker/image_picker.dart';

class GalleryImagePicker {
  final ImagePicker _picker = ImagePicker();
  
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
