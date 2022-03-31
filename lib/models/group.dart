import 'package:dima/models/user.dart';

class Group {
  List<MyUser> users = [];
  String groupCode = '';

  void addUser(MyUser user) {
    users.add(user);
  }

  void setGroupCode(String groupCode) {
    this.groupCode = groupCode;
  }

  List<MyUser> getList() {
    return users;
  }

  String getGroupCode() {
    return groupCode;
  }

  void setMembers(List<MyUser> members) {
    users = members;
  }

  MyUser? getUserFromId(String uid) {
    for (MyUser user in users) {
      if (uid == user.getUid()) {
        return user;
      }
    }
    return null;
  }
}
