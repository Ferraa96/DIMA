import 'package:flutter/material.dart';

class MyUser {
  late String uid = '';
  late String name = '';
  static String groupId = '';
  String picUrl = '';
  late Image picture;

  void setUserId(String uid) {
    this.uid = uid;
  }

  String getUid() {
    return uid;
  }

  void setName(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }

  void setGroupId(String gId) {
    groupId = gId;
  }

  String getGroupId() {
    return groupId;
  }

  void setPicUrl(String picUrl) {
    this.picUrl = picUrl;
  }

  String getPicUrl() {
    return picUrl;
  }

  void setPicture(Image picture) {
    this.picture = picture;
  }

  Image getPicture() {
    return picture;
  }
}
