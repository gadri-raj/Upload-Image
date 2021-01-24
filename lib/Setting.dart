import 'package:flutter/material.dart';

import 'Home.dart';

class Setting extends StatefulWidget {
  @override
  _Setting createState() => _Setting();
}

class _Setting extends State<Setting> {
  // ignore: missing_return
  Future<bool> _back() {
    Route newRoute = MaterialPageRoute(builder: (_) => Home());
    Navigator.pushReplacement(context, newRoute);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _back,
      child: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Route newRoute = MaterialPageRoute(builder: (_) => Home());
              Navigator.pushReplacement(context, newRoute);
            },
          ),
          title: Text("Settings"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Settings",
                style: TextStyle(fontSize: 22.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
