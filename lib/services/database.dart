import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/user.dart';
import 'dart:math';

class DatabaseService {
  void registerUser(String userID, String email) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users.doc(userID).set({
      'email': email,
    });
  }

  Future<void> addUserName(String userID, String name) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(userID).update({
      'name': name,
    });
  }

  Future<MyUser> retrieveUser(String uid) async {
    MyUser user = MyUser(uid: uid);

    var collection = FirebaseFirestore.instance.collection('users');

    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      user.setName(data?['name']);
    }
    return user;
  }

  void addUserToGroup(String uid, String groupId) {}

  String _getRandomString() {
    Random rand = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(6, (index) => _chars[rand.nextInt(_chars.length)])
        .join();
  }

  void createGroup(String uid) {
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    groups.doc(uid).set({'userId': uid});
    users.doc(uid).update({
      'groupdId': uid,
    });
  }

  void joinGroup(String uid, groupId) {
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
  }
}
