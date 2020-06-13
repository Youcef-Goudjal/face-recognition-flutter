
import 'package:flutter/material.dart';

class User with ChangeNotifier{
  String uid, email, username, profilePhoto, password;
  List groups = [];
  User({this.uid, this.email, this.username, this.profilePhoto, this.password});
  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['email'] = user.email;
    data['username'] = user.username;
    data['profile_photo'] = user.profilePhoto;
    data['password'] = user.password;
    return data;
  }

  User.fromMap(Map<String, dynamic> data) {
    this.uid = data['uid'];
    this.email = data['email'];
    this.username = data['username'];
    this.profilePhoto = data['profile_photo'];
    this.groups = data['My groups'];
  }
}