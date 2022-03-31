import 'package:dima/services/appData.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  String senderId = '';
  String messageContent = '';
  DateTime timestamp;
  ChatMessage(
      {required this.senderId,
      required this.messageContent,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                Text(
                  messageContent,
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
                  messageContent,
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
}
