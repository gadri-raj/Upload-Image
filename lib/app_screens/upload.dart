import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating_app/widget/dialog_box_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:dating_app/model/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dating_app/app_screens/landing_page.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  //----------------------------------Variables-------------------------------------------------
  File _file;
  FirebaseUser _currentUser;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  User currentUser;
  DocumentReference _docmentReference;
  DocumentSnapshot _documentSnapshot;
  final StorageReference _storageReference =
      FirebaseStorage.instance.ref().child("Posts Pictures");
  final CollectionReference _postsReference =
      Firestore.instance.collection("posts");

  TextEditingController _descriptionTextEditingController =
      TextEditingController();
  TextEditingController _locationTextEditingController =
      TextEditingController();

  bool _uploading = false;
  String _postId = Uuid().v4();
  @override
  void initState() {
    _getCurrentUser().then((value) {
      setState(() {
        _currentUser = value;
      });
    });
    super.initState();

    _getDocumentSnapshot();
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

  void _captureImageWithCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      _file = imageFile;
    });
  }

  //----------------------------------Methods-------------------------------------------------
  void _pickImageFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _file = imageFile;
    });
  }

  _takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("New Post",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Capture Image with Camera",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: _captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Select Image from Gallery",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: _pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearPostInfo() {
    _descriptionTextEditingController.clear();
    _locationTextEditingController.clear();
    setState(() {
      _file = null;
    });
  }

  void _getUserCurrentLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placeMarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      if (placeMarks != null) {
        Placemark mPlaceMark = placeMarks[0];
        String completeAddressInfo =
            "${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, "
            "${mPlaceMark.subLocality} ${mPlaceMark.locality}, "
            "${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, "
            "${mPlaceMark.postalCode} ${mPlaceMark.country}";
        String specificAddress =
            "${mPlaceMark.locality}, ${mPlaceMark.country}";
        _locationTextEditingController.text = specificAddress;
      } else {
        showDialogBox(context, "Error", "Unable To Find Location");
      }
    } catch (e) {
      showDialogBox(context, "Error", e.toString());
    }
  }

  void _getDocumentSnapshot() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
    _docmentReference =
        Firestore.instance.collection("users").document(_currentUser.uid);
    _documentSnapshot = await _docmentReference.get();
  }

  void _compressingPhoto() async {
    final Directory tempDirectory = await getTemporaryDirectory();
    final String path = tempDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(_file.readAsBytesSync());
    final compressedImageFile = File("$path/img_$_postId.jpg")
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      _file = compressedImageFile;
    });
  }

  Future<String> _uploadPhoto(File mImageFile) async {
    StorageUploadTask storageUploadTask =
        _storageReference.child("post_$_postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _savePostInfoToFirestore(
      {String url, String location, String description}) {
    _postsReference
        .document(_currentUser.uid)
        .collection("usersPosts")
        .document(_postId)
        .setData({
      "postId": _postId,
      "ownerId": _currentUser.uid,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": _documentSnapshot['username'],
      "description": description,
      "location": location,
      "url": url
    });
  }

  void _controlUploadAndSave() async {
    setState(() {
      _uploading = true;
    });

    await _compressingPhoto();

    String downloadUrl = await _uploadPhoto(_file);
    _savePostInfoToFirestore(
        url: downloadUrl,
        location: _locationTextEditingController.text,
        description: _descriptionTextEditingController.text);

    //clear everything / setback everything
    _descriptionTextEditingController.clear();
    _locationTextEditingController.clear();
    setState(() {
      _file = null;
      _uploading = false;
      _postId = Uuid().v4(); //Updates the id
    });
  }

  //----------------------------------Design-------------------------------------------------
  Widget _displayUploadScreen() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () async {
                    _takeImage(context);
                  },
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Upload Image',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                SizedBox(height: 40),
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
                      fontSize: 20,
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
                      fontSize: 20,
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

  Widget _displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: _clearPostInfo,
        ),
        title: Text(
          "New Post",
          style: TextStyle(
              fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Share",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
            onPressed: _uploading ? null : () => _controlUploadAndSave(),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _uploading ? LinearProgressIndicator() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(_documentSnapshot['url']),
            ),
            title: Container(
              margin: const EdgeInsets.only(left: 18.0, right: 18.0),
              width: double.infinity,
              child: TextField(
                controller: _descriptionTextEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Say something about image",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: Colors.green,
              size: 36.0,
            ),
            title: Container(
              margin: const EdgeInsets.only(left: 18.0, right: 18.0),
              width: double.infinity,
              child: TextField(
                controller: _locationTextEditingController,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
            height: 48.0,
            width: MediaQuery.of(context).size.width,
            child: RaisedButton.icon(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0)),
              icon: Icon(
                Icons.location_on,
                color: Colors.green,
              ),
              label: Text(
                "Get my current location",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: _getUserCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return _file == null ? _displayUploadScreen() : _displayUploadFormScreen();
  }
}
