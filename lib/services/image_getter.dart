import 'package:dima/services/asset_thumbnail.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGetter {
  Future<String?> selectFile(ImageSource source) async {
    final XFile? result = await ImagePicker().pickImage(
      source: source,
    );
    if (result != null) {
      return result.path;
    } else {
      return null;
    }
  }
}

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<AssetEntity> assets = [];

  @override
  void initState() {
    _fetchAssets();
    super.initState();
  }

  Future<void> _fetchAssets() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) {
      return;
    }
    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0,
      end: 1000,
    );
    setState(() {
      assets = recentAssets;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width /
        MediaQuery.of(context).devicePixelRatio;
    double neighbour = 3;
    double left = 6;
    double right = 6;
    int colNum = (width / 140).round();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: ThemeProvider().isDarkMode
                    ? const Color(0xff000624)
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 3),
                child: GridView.builder(
                  itemCount: assets.length,
                  controller: controller,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: colNum),
                  itemBuilder: (_, index) {
                    if (index % colNum == 0) {
                      left = 6;
                      right = 3;
                    } else {
                      left = 3;
                      if ((index + 1) % colNum == 0) {
                        right = 6;
                      } else {
                        right = 3;
                      }
                    }
                    if (index == 0) {
                      return Card(
                        margin: EdgeInsets.only(
                          top: neighbour,
                          left: left,
                          bottom: neighbour,
                          right: neighbour,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Icon(Icons.camera),
                        ),
                      );
                    }
                    return Card(
                      margin: EdgeInsets.only(
                          top: neighbour,
                          bottom: neighbour,
                          right: right,
                          left: left),
                      child: AssetThumbnail(asset: assets[index]),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
