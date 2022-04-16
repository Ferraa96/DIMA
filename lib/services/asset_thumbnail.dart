import 'dart:typed_data';

import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({Key? key, 
    required this.asset,
  }) : super(key: key);

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (_, snapshot) {
        final Uint8List? bytes = snapshot.data;
        if (bytes == null) return const Loading();
        return InkWell(
          onTap: () {
            asset.file.then((value) => Navigator.of(context).pop(value!.path));
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
