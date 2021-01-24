import 'package:flutter/material.dart';

Widget circularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12.0,),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightGreenAccent),
    ),
  );
}

Widget linearProgress(){
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12.0,),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.lightGreenAccent),
    ),
  );
}