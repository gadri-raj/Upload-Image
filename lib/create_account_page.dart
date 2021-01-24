import 'dart:async';

import 'package:dating_app/widget/header_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String _username;

  void _checkUserName() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("users")
        .where("username", isEqualTo: _username)
        .getDocuments();

    if (querySnapshot.documents.length > 0) {
      SnackBar snackBar =
          SnackBar(content: Text("Username already taken by someone"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(content: Text("Welcome $_username"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, _username);
      });
    }
  }

  void _submitUsername() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _checkUserName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, title: "Settings", disappearedBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 26.0,
                  ),
                  child: Center(
                    child: Text(
                      "Set up a username",
                      style: TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(fontSize: 16.0),
                          hintText: "must be atleast 5 characters",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value.isEmpty)
                            return "Enter a username";
                          else if (value.trim().length < 5)
                            return "username must contain atleast 5 characters";
                          else if (value.trim().length > 15)
                            return "username too long";
                          else
                            return null;
                        },
                        onSaved: (value) {
                          _username = value;
                        },
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _submitUsername,
                  child: Container(
                    margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                    height: 55.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
