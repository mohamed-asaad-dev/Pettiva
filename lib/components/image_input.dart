import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput {
  Future<File?> cameraImage() async {
    final pickedImage = ImagePicker();
    final newImage = await pickedImage.pickImage(source: ImageSource.camera);
    if (newImage == null) {
      return null;
    }
    return File(newImage.path);
  }

  Future<File?> galleryImage() async {
    final pickedImage = ImagePicker();
    final newImage = await pickedImage.pickImage(source: ImageSource.gallery);
    if (newImage == null) {
      return null;
    }
    return File(newImage.path);
  }
}
