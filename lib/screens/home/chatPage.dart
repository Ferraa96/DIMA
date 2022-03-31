import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/chatMessage.dart';
import 'package:dima/models/data.dart';
import 'package:dima/services/appData.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Widget _messages;
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    _messages = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(AppData().user.getGroupId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data() == null) {
            return const Center(
              child: Text('Send the first message'),
            ); // if there are no chats yet
          }
          List list = List.from(snapshot.data!.data()!['messages']);
          return Container(
            padding: const EdgeInsets.only(bottom: 60),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: list.length,
              reverse: true,
              itemBuilder: (_, index) {
                return ChatMessage(
                  senderId: list[list.length - index - 1]['sender'],
                  messageContent: list[list.length - index - 1]['content'],
                  timestamp: DateTime.parse(
                    list[list.length - index - 1]['timestamp'],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 0,
                );
              },
            ),
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController chatController = TextEditingController();
    return Container(
      child: Stack(
        children: <Widget>[
          _messages,
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
                )
              ),
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 55,
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                      ),
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
                      ChatMessage msg = ChatMessage(
                        senderId: AppData().user.getUid(),
                        messageContent: chatController.text,
                        timestamp: DateTime.now(),
                      );
                      DatabaseService()
                          .sendMessage(msg, AppData().user.getGroupId());
                      chatController.clear();
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
      ),
    );
  }
}
