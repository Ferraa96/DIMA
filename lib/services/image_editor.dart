import 'dart:io';

import 'package:image_cropper/image_cropper.dart';

class ImageEditor {
  Future<File?> cropSquareImage(File file) async {
    return await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressQuality: 50,
      compressFormat: ImageCompressFormat.jpg,
    );
  }
}
