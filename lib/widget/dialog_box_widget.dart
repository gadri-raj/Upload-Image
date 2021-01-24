import 'package:flutter/material.dart';

Future showDialogBox(BuildContext mContext, String title, String description) {
  return showDialog(
    context: mContext,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                description,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
