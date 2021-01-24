import 'package:dating_app/widget/dialog_box_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'landing_page.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //---------------------------------------Variables---------------------------------------------------
  final FirebaseAuth _mAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //---------------------------------------Methods---------------------------------------------------
  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _mAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    return user;
  }

  //---------------------------------------Design---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Dating App",
              style: TextStyle(
                fontSize: 60.0,
                color: Colors.white,
                fontFamily: "Lobster",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
            ),
            GestureDetector(
              onTap: () {
                _signIn().then((user) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LandingPage()));
                }).catchError((onError) {
                  showDialogBox(context, "Error", onError.toString());
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                width: double.infinity,
                height: 65.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
