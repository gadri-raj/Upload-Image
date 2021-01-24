import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dating_app/app_screens/landing_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CollectionReference usersReference =
      Firestore.instance.collection("users");
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;
  //---------------------------------------Methods---------------------------------------------------
  @override
  void initState() {
    _getCurrentUser().then((value) {
      setState(() {
        _currentUser = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<FirebaseUser> _getCurrentUser() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser;
  }

  //---------------------------------------Design---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    _currentUser.photoUrl,
                  ),
                  radius: 60,
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 40),
                Text(
                  'NAME',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                Text(
                  _currentUser.displayName,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'EMAIL',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                Text(
                  _currentUser.email,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                RaisedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    _googleSignIn.signOut();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LandingPage()));
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
