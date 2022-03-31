import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/chatMessage.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';
import 'dart:math';

import 'package:dima/services/appData.dart';
import 'package:dima/services/imageEditor.dart';
import 'package:dima/services/imageGetter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  void registerUser(String userID, String email) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users.doc(userID).set({
      'email': email,
    }, SetOptions(merge: true));
  }

  Future<void> updateUserName(String userID, String name) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(userID).update({
      'name': name,
    });
  }

  Future<void> updateImage(String userId, ImageSource source) async {
    String? path = await ImageGetter().selectFile(source);
    if (path == null) {
      return;
    }
    File? file = await ImageEditor().cropSquareImage(File(path));
    if (file == null) {
      return;
    }
    try {
      final ref = FirebaseStorage.instance.ref('profilePictures/$userId');
      await ref.putFile(file);
      final String url = await ref.getDownloadURL();
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      users.doc(userId).update({
        'picture': url,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<MyUser> retrieveUser(String uid) async {
    MyUser user = MyUser();
    user.setUserId(uid);
    String pictureUrl = '';

    var collection = FirebaseFirestore.instance.collection('users');

    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      user.setUserId(uid);
      user.setName(data?['name']);
      MyUser.groupId = data?['groupId'];
      pictureUrl = data?['picture'];
    }
    if (pictureUrl != null) {
      user.setPicUrl(pictureUrl);
      user.setPicture(Image.network(pictureUrl));
    }
    return user;
  }

  // retrieve all the users that are not already in local cache
  Future<List<MyUser>> retrieveUsers(List<String> uids) async {
    List<MyUser> newUsers = [];
    for (String uid in uids) {
      newUsers.add(await retrieveUser(uid));
    }
    return newUsers;
  }

  Future<bool> _addUserToGroup(String uid, String groupId) async {
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final snapshot = await groups.doc(groupId).get();
    if (snapshot.exists) {
      groups.doc(groupId).update({
        'members': FieldValue.arrayUnion([uid]),
      });
      users.doc(uid).update({
        'groupId': groupId,
      });
      return true;
    }
    return false;
  }

  String _getRandomString() {
    Random rand = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(6, (index) => _chars[rand.nextInt(_chars.length)])
        .join();
  }

  String createGroup(String uid) {
    List member = [uid];
    String code = _getRandomString();
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    CollectionReference invitationCode =
        FirebaseFirestore.instance.collection('invitationCode');
    groups.doc(uid).set({
      'members': member,
      'invitationCode': code,
    });
    users.doc(uid).update({
      'groupId': uid,
    });
    invitationCode.doc(code).set({
      'group': uid,
    });
    return code;
  }

  Future<String> _getGroupFromCode(String code) async {
    var invitationCode =
        FirebaseFirestore.instance.collection('invitationCode');
    var docSnapshot = await invitationCode.doc(code).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      return data?['group'];
    } else {
      return '';
    }
  }

  Future<bool> joinGroup(String uid, String code) async {
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
    String groupId = await _getGroupFromCode(code);
    if (groupId != '') {
      if (await _addUserToGroup(uid, groupId)) {
        AppData().user.setGroupId(groupId);
        return true;
      }
    }
    return false;
  }

  Future<Group> retrieveGroup(String uid) async {
    var groupsColl = FirebaseFirestore.instance.collection('groups');
    var usersColl = FirebaseFirestore.instance.collection('users');
    Group group = Group();
    List<String> users = [];
    String groupId;
    Map<String, dynamic>? usersData;

    var docSnapshot = await usersColl.doc(uid).get();
    // get the groupId for the user
    if (docSnapshot.exists) {
      usersData = docSnapshot.data();
      groupId = usersData?['groupId'];
    } else {
      return group;
    }

    // get the id of all the users in the group
    if (groupId != null) {
      var docSnapshot = await groupsColl.doc(groupId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var array = data?['members'];
        users = List<String>.from(array);
        group.setGroupCode(data?['invitationCode']);
      }
    } else {
      return group;
    }

    // get the info for all the users
    if (users.isNotEmpty) {
      for (String user in users) {
        group.addUser(await retrieveUser(user));
      }
    }
    return group;
  }

  Future<void> sendMessage(ChatMessage message, String groupId) async {
    CollectionReference chatColl =
        FirebaseFirestore.instance.collection('chats');
    chatColl.doc(groupId).set(
      {
        'messages': FieldValue.arrayUnion([
          {
            'sender': message.senderId,
            'content': message.messageContent,
            'timestamp': DateFormat("yyyy-MM-dd HH:mm:ss.mmm").format(message.timestamp.toUtc()),
          }
        ]),
      },
      SetOptions(merge: true),
    );
  }
}
