import 'package:dima/services/app_data.dart';
import 'package:dima/shared/constants.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  String senderId = '';
  String? messageContent = '';
  bool hasMedia = false;
  Image? img;
  DateTime timestamp;
  ChatMessage({Key? key, 
    required this.senderId,
    this.messageContent,
    required this.timestamp,
    required this.hasMedia,
    this.img,
  }) : super(key: key);

  void setImage(Image img) {
    this.img = img;
  }

  void _buildMediaViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (
          _,
          __,
          ___,
        ) {
          return DismissiblePage(
            direction: DismissiblePageDismissDirection.multi,
            onDismissed: () => Navigator.of(context).pop(),
            key: UniqueKey(),
            child: Hero(
              tag: identityHashCode(this),
              child: Image(
                image: img!.image,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _constructTextualMessage(double width) {
    if (senderId != AppData().user.getUid()) {
      return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: width / 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppData().group.getUserFromId(senderId)!.getName(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors[AppData().group.getUserIndexFromId(senderId) %
                        colors.length],
                  ),
                ),
                Text(
                  messageContent!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: width / 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue[200],
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              messageContent!,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _constructMediaMessage(double width, BuildContext context) {
    if (senderId != AppData().user.getUid()) {
      return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: width / 2,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.all(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppData().group.getUserFromId(senderId)!.getName(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors[AppData().group.getUserIndexFromId(senderId) %
                        colors.length],
                  ),
                ),
                GestureDetector(
                  child: Hero(
                    child: Image(image: img!.image),
                    tag: identityHashCode(this),
                  ),
                  onTap: () {
                    _buildMediaViewer(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: width / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[200],
            ),
            padding: const EdgeInsets.all(1),
            child: GestureDetector(
              child: Hero(
                child: Image(image: img!.image),
                tag: identityHashCode(this),
              ),
              onTap: () {
                _buildMediaViewer(context);
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (!hasMedia) {
      return _constructTextualMessage(width);
    } else {
      return _constructMediaMessage(width, context);
    }
  }
}
