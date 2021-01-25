import 'package:dating_app/app_screens/upload.dart';
import 'package:dating_app/app_screens/sign_in.dart';
import 'package:dating_app/model/user.dart';
import 'package:dating_app/widget/progress_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../create_account_page.dart';

// ignore: must_be_immutable
class LandingPage extends StatelessWidget {
  final CollectionReference usersReference =
      Firestore.instance.collection("users");
  final CollectionReference _followersReference =
      Firestore.instance.collection("followers");
  final DateTime _timestamp = DateTime.now();
  // ignore: unused_field
  User _currentUser;

  bool isExists = false;

  // ignore: missing_return
  Future<Widget> _saveUserInfoToFirestore(BuildContext context) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot documentSnapshot =
        await usersReference.document(user.uid).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return CreateAccountPage();
      }));
      if (username != null) {
        usersReference.document(user.uid).setData({
          "id": user.uid,
          "profileName": user.displayName,
          "username": username,
          "url": user.photoUrl,
          "email": user.email,
          "bio": "",
          "timestamp": _timestamp
        });
        //Making the user by default to follow itself becuase to show its own posts on timeline
        await _followersReference
            .document(user.uid)
            .collection("userFollowers")
            .document(user.uid)
            .setData({});

        documentSnapshot = await usersReference.document(user.uid).get();
        _currentUser = User.fromDocument(documentSnapshot);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UploadPage()));
      }
    } else {
      _currentUser = User.fromDocument(documentSnapshot);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UploadPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) return SignIn();
          _saveUserInfoToFirestore(context);
          return Container();
        } else {
          return Scaffold(
            body: Center(
              child: circularProgress(),
            ),
          );
        }
      },
    );
  }
}
