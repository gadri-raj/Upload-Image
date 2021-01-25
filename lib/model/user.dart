import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  String id;
  String profileName;
  String username;
  String url;
  String email;
  String bio;

  User({
    this.id,
    this.profileName,
    this.username,
    this.url,
    this.email,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.documentID,
      email: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
    );
  }
}