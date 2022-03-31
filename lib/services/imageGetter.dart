import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageGetter {

  Future<String?> selectFile(ImageSource source) async {
    final XFile? result =
        await ImagePicker().pickImage(source: source);
    if (result != null) {
      return result.path;
    } else {
      return null;
    }
  }
}
