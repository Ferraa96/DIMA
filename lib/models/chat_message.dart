import 'package:dima/services/app_data.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/formatter.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';

class ChatMessage extends StatelessWidget {
  String senderId = '';
  String? messageContent = '';
  bool hasMedia = false;
  Image? img;
  DateTime timestamp;
  Group group;
  MyUser user;
  ChatMessage({
    Key? key,
    required this.senderId,
    this.messageContent,
    required this.timestamp,
    required this.hasMedia,
    this.img,
    required this.group,
    required this.user,
  }) : super(key: key);

  final Formatter _formatter = Formatter();

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
    if (senderId != user.getUid()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: width / 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.zero),
                  color: Colors.grey.shade400,
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      group.getUserFromId(senderId)!.getName(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors[
                            group.getUserIndexFromId(senderId) %
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Text(
              _formatter.formatTime(TimeOfDay.fromDateTime(timestamp)),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              _formatter.formatTime(TimeOfDay.fromDateTime(timestamp)),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: width / 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.zero,
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  color: Colors.blue[200],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
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
          ),
        ],
      );
    }
  }

  Widget _constructMediaMessage(double width, BuildContext context) {
    if (senderId != user.getUid()) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: width / 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.grey.shade200,
                ),
                padding: const EdgeInsets.all(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      group.getUserFromId(senderId)!.getName(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors[
                            group.getUserIndexFromId(senderId) %
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
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Text(
              _formatter.formatTime(TimeOfDay.fromDateTime(timestamp)),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              _formatter.formatTime(TimeOfDay.fromDateTime(timestamp)),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 5),
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
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (!hasMedia) {
      return _constructTextualMessage(width);
    } else {
      return width > height
          ? _constructMediaMessage(height * 2 / 3, context)
          : _constructMediaMessage(width * 2 / 3, context);
    }
  }
}
