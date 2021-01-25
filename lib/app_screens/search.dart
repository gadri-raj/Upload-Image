import 'package:dating_app/app_screens/landing_page.dart';
import 'package:dating_app/app_screens/upload.dart';
import 'package:dating_app/model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  final CollectionReference usersReference =
      Firestore.instance.collection("users");
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  User currentUser;

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
    searchedUsers = null;
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

  Future<QuerySnapshot> searchedUsers;
  final searchController = TextEditingController();
  String currentSearchingValue;

  AppBar buildSearchBar() {
    return AppBar(
      title: TextFormField(
        autofocus: false,
        controller: searchController,
        onChanged: (val) {
          handleSearch(val);
        },
        decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: "Search for a user",
            filled: true,
            prefixIcon: Icon(
              Icons.search,
              size: 28,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
              },
            )),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container NoContentBody() {
    return Container(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        children: <Widget>[],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  FutureBuilder BuildSearchResults() {
    return FutureBuilder(
      future: searchedUsers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print("Searching");
          return Container(
            padding: EdgeInsets.only(left: 50, top: 20),
            child: Row(
              children: <Widget>[
                Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    )),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                        "Searching $currentSearchingValue",
                        softWrap: true,
                        maxLines: 50,
                      )),
                )
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          print("has Error");
          return Text("Not Found");
        } else {
          List<User> searchedUsers = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            searchedUsers.add(user);
            print(user.username);
          });
          if (searchedUsers.length == 0) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("No result found for \"${currentSearchingValue}\""),
            );
          }
          return ListView(
            children: searchedUsers.map((user) {
              return Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    title: Text(user.profileName),
                    subtitle: Text(user.username),
                    onTap: () {},
                  ),
                  Divider(
                    height: 2.0,
                    indent: MediaQuery.of(context).size.width * 0.25,
                  )
                ],
              );
            }).toList(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchBar(),
      body: searchedUsers == null ? NoContentBody() : BuildSearchResults(),
    );
  }

  void handleSearch(String val) {
    if (val.isNotEmpty) {
      Future<QuerySnapshot> users = usersReference
          .where("profileName", isGreaterThanOrEqualTo: val)
          .getDocuments();
      setState(() {
        currentSearchingValue = val;
        searchedUsers = users;
      });
    }
    if (val.isEmpty) {
      setState(() {
        searchedUsers = null;
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
