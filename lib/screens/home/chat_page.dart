import 'package:dima/models/chat_message.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/database.dart';
import 'package:dima/services/image_getter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatelessWidget {
  final List chatList;
  ChatPage({required this.chatList});
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget _getMessages() {
    return Container(
      padding: const EdgeInsets.only(bottom: 60),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: chatList.length,
        reverse: true,
        itemBuilder: (_, index) {
          if (chatList.isEmpty) {
            return const Text('Send the first message');
          }
          if (!chatList[chatList.length - index - 1]['hasMedia']) {
            return ChatMessage(
              senderId: chatList[chatList.length - index - 1]['sender'],
              messageContent: chatList[chatList.length - index - 1]['content'],
              hasMedia: false,
              timestamp: DateTime.parse(
                chatList[chatList.length - index - 1]['timestamp'],
              ),
              group: AppData().group,
              user: AppData().user,
            );
          } else {
            return ChatMessage(
              senderId: chatList[chatList.length - index - 1]['sender'],
              hasMedia: true,
              img: Image.network(chatList[chatList.length - index - 1]['image']),
              timestamp: DateTime.parse(
                chatList[chatList.length - index - 1]['timestamp'],
              ),
              group: AppData().group,
              user: AppData().user,
            );
          }
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 0,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController chatController = TextEditingController();
    return Stack(
      children: <Widget>[
        _getMessages(),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            decoration: const BoxDecoration(
                border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 1,
                style: BorderStyle.solid,
              ),
            )),
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: 55,
            width: double.infinity,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext context) {
                        return const Gallery();
                      },
                    ).then((value) {
                      if (value == null) {
                        return;
                      }
                      ChatMessage msg = ChatMessage(
                        senderId: AppData().user.getUid(),
                        timestamp: DateTime.now(),
                        hasMedia: true,
                        group: AppData().group,
                        user: AppData().user,
                      );
                      if (value is bool) {
                        ImageGetter().selectFile(ImageSource.camera).then(
                          (value) {
                            if (value != null) {
                              DatabaseService().sendMessage(
                                  msg, AppData().user.getGroupId(), value);
                            }
                          },
                        );
                      } else {
                        DatabaseService().sendMessage(
                            msg, AppData().user.getGroupId(), value);
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextField(
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    controller: chatController,
                    decoration: const InputDecoration(
                      hintText: "Write message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      if (chatController.text.isNotEmpty) {
                        ChatMessage msg = ChatMessage(
                          senderId: AppData().user.getUid(),
                          messageContent: chatController.text,
                          hasMedia: false,
                          timestamp: DateTime.now(),
                          group: AppData().group,
                          user: AppData().user,
                        );
                        DatabaseService()
                            .sendMessage(msg, AppData().user.getGroupId(), '');
                        chatController.clear();
                      }
                    },
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
