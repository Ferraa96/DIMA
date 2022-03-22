import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';
import 'dart:math';

class DatabaseService {
  void registerUser(String userID, String email) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users.doc(userID).set({
      'email': email,
    }, SetOptions(merge: true));
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
      MyUser.groupId = data?['groupId'];
      // user.setGroupId(data?['groupId']);
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

  void _addUserToGroup(String uid, String groupId) {
    CollectionReference groups =
        FirebaseFirestore.instance.collection('groups');
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    groups.doc(groupId).update({
      'members': FieldValue.arrayUnion([uid])
    });
    users.doc(uid).update({
      'groupId': groupId,
    });
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
      _addUserToGroup(uid, groupId);
      return true;
    } else {
      return false;
    }
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
    if (groupId.isNotEmpty) {
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
}
