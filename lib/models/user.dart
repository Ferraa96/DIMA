class MyUser {
  final String uid;
  late String name = '';
  static late String groupId = '';

  MyUser({required this.uid});

  String getUid() {
    return uid;
  }

  void setName(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }

  static void setGroupId(String gId) {
    groupId = gId;
  }

  String getGroupId() {
    return groupId;
  }
}
