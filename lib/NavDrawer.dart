import 'package:dating_app/Home.dart';
import 'package:flutter/material.dart';

import 'Profile.dart';
import 'Setting.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawer createState() => _NavDrawer();
}

class _NavDrawer extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        UserAccountsDrawerHeader(
          accountEmail: Text("abc@gmail.com"),
          accountName: Text("Abc"),
          currentAccountPicture: Image.asset("assets/images/avatar.png"),
        ),
        ListTile(
          title: Text("Home"),
          onTap: () {
            Route newRoute = MaterialPageRoute(builder: (_) => Home());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
        ListTile(
          title: Text("Profile"),
          onTap: () {
            Route newRoute = MaterialPageRoute(builder: (_) => Profile());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
        ListTile(
          title: Text("Settings"),
          onTap: () {
            Route newRoute = MaterialPageRoute(builder: (_) => Setting());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ],
    );
  }
}
