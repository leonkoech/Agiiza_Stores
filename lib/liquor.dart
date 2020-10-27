import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'location.dart';
import 'main.dart';
//  firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// maps plugins
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoder/geocoder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LiquorTab extends StatefulWidget {
  final userid;
  const LiquorTab({Key key, this.userid}) : super(key: key);
  @override
  _LiquorTabState createState() => _LiquorTabState();
}

class _LiquorTabState extends State<LiquorTab> {
  FirebaseAuth auth = FirebaseAuth.instance;

  getUserId() {
    final User user = auth.currentUser;
    final uid = user.uid;
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.center,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Liquor')
              .where("storeId", isEqualTo: widget.userid!=null?getUserId:widget.userid)
              // .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            if (!snapshot.hasData)
              return Center(
                  child: new Text(
                    'No Liquors\nClick the button below to Add liquor',
                    textAlign:TextAlign.center,
                
                style: TextStyle(color: Color(0xffcccccc)),
              ));

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
//        return a loading screen of sorts
                return new Center(
                  child: SpinKitChasingDots(
                    color: Color(0xffff8181),
                    size: 50.0,
                    duration: Duration(milliseconds: 2000),
                  ),
                );
              default:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 68.0),
                  child: new ListView(
                    scrollDirection: Axis.vertical,
                    children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                      if (snapshot.data.docs != null) {
                        return LiquorItem(
                          imageUrl: document.data()['imageUrl'],
                          liquorId: document.data()['docId'],
                          liquorName: document.data()['liquorName'],
                          liquorPrice: document.data()['liquorPrice'],
                          liquorQty: document.data()['liquorVolume'],
                          activity: document.data()['active'],
                        );
                      } else {
                        return new Text('No Liquor To display');
                      }
                    }).toList(),
                  ),
                );
            }
          },
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Color(0xff16172a),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text('Click here to add any liquor to your store',
                        style:
                            TextStyle(fontSize: 12, color: Color(0x6fe1e1e1)))),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddLiquor()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Color(0xffff8181)),
                    child: Center(
                        child: Text('Add Liquor',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xffe1e1e1)))),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }
}

class LiquorItem extends StatelessWidget {
  final imageUrl;
  final liquorId;
  final liquorPrice;
  final liquorQty;
  final activity;
  final liquorName;
  const LiquorItem(
      {Key key,
      this.imageUrl,
      this.liquorId,
      this.liquorPrice,
      this.liquorQty,
      this.activity,
      this.liquorName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.only(top: 8, bottom: 8, right: 15, left: 15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xfff4f4f4),
          ),
          borderRadius: BorderRadius.circular(6.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Image.network(
              imageUrl,
              height: 70,
              width: 70,
            ),
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(liquorName,
                    style: TextStyle(
                        color: Color(0xfff4f4f4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(liquorQty,
                        style: TextStyle(
                            color: Color(0xfff4f4f4),
                            fontSize: 9,
                            fontWeight: FontWeight.normal)),
                    Text(liquorPrice,
                        style: TextStyle(
                            color: Color(0xfff4f4f4),
                            fontSize: 9,
                            fontWeight: FontWeight.normal))
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
                color: activity ? Color(0xff41EAD4) : Color(0xffff8181),
                borderRadius: BorderRadius.circular(120.0)),
          ),
        ],
      ),
    );
  }
}



class AddLiquor extends StatefulWidget {
  @override
  _AddLiquorState createState() => _AddLiquorState();
}

class _AddLiquorState extends State<AddLiquor> {
  bool _isSwitched = false;
  final liquorNameController = TextEditingController();
  final liquorVolumeController = TextEditingController();
  final liquorPriceController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  String _uploadedFileURL;

  Future uploadEventImage() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Liquor/${_image.path}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      print('File Uploaded');
      setState(() {
        _uploadedFileURL = fileURL;
      });
      addEventInfo();
    });
  }

  void addEventInfo() async {
    // use the name of the store to create the store. The store name should be unique
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    final documentId = generateRandomString(10);
    await databaseReference.collection("Liquor").doc(documentId).set({
      'storeId': uid,
      'docId': documentId,
      'liquorName': liquorNameController.text,
      'liquorVolume': liquorVolumeController.text,
      'liquorPrice': liquorPriceController.text,
      'active': _isSwitched,
      'imageUrl': _uploadedFileURL
    }).then((value) {
         Fluttertoast.showToast(
            msg: "Successfully Added to Your Store",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff16172a),
            textColor: Color(0xfff4f4f4),
            fontSize: 10.0);
    });
  }

// generate a random string to use as your document Id
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String generateRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Widget build(BuildContext context) {
    // check if the information was passed here, and if not show the default empty boxes
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBar(
                        centerTitle: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        title: Text('Add Liquor',
                            style: TextStyle(
                                color: Color(0xffe1e1e1),
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 120,
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              // color: Color(0xff37deed),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _image == null
                                ? Center(
                                    child: Text('No image selected.',
                                        style: TextStyle(
                                            color: Color(0x5fe1e1e1),
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal)))
                                : Image.file(_image),
                          ),
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                  color: Color(0xffff8181),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                    child: Text('select photo',
                                        style: TextStyle(
                                            color: Color(0xffe1e1e1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal)))),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            width: MediaQuery.of(context).size.width * .45,
                            child: Text(
                              "If this switch is turned off, the Liquor won't be visible to customers viewing your store",
                              style: TextStyle(
                                  color: Color(0x5fe1e1e1), fontSize: 11),
                            )),
                        Switch(
                          value: _isSwitched,
                          onChanged: (value) {
                            setState(() {
                              _isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.blueGrey[100],
                          inactiveThumbColor: Colors.blueGrey[200],
                        ),
                      ],
                    ),
                    textinput(context, 'Name of Liquor', liquorNameController),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                margin: EdgeInsets.only(bottom: 6),
                                height: 50,
                                child: TextField(
                                  controller: liquorVolumeController,
                                  style: TextStyle(
                                      color: Color(0xffe1e1e1), fontSize: 13),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffff8181),
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffe1e1e1),
                                            width: 1.0),
                                      ),
                                      hintText: 'Volume in ml',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 11)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: 50,
                                margin: EdgeInsets.only(bottom: 6),
                                child: TextField(
                                  controller: liquorPriceController,
                                  style: TextStyle(
                                      color: Color(0xffe1e1e1), fontSize: 13),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffff8181),
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffe1e1e1),
                                            width: 1.0),
                                      ),
                                      hintText: 'Price in kes',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                              child: bottombtn(
                                  Color(0xffff8181),
                                  Color(0xffe1e1e1),
                                  'Done',
                                  MediaQuery.of(context).size.width * 0.5,
                                  true,
                                  false,
                                  false),
                              onTap: () {
                                uploadEventImage();
                                Navigator.pop(context);
                              })
                        ])
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class EditLiquor extends StatefulWidget {
  @override
  _EditLiquorState createState() => _EditLiquorState();
}

class _EditLiquorState extends State<EditLiquor> {
  bool _isSwitched = false;
  final liquorNameController = TextEditingController();
  final liquorVolumeController = TextEditingController();
  final liquorPriceController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  String _uploadedFileURL;

  Future uploadEventImage() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('Liquor/${_image.path}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      print('File Uploaded');
      setState(() {
        _uploadedFileURL = fileURL;
      });
      addEventInfo();
    });
  }

  void addEventInfo() async {
    // use the name of the store to create the store. The store name should be unique
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    final documentId = generateRandomString(10);
    await databaseReference.collection("Liquor").doc(documentId).set({
      'storeId': uid,
      'docId': documentId,
      'liquorName': liquorNameController.text,
      'liquorVolume': liquorVolumeController.text,
      'liquorPrice': liquorPriceController.text,
      'active': _isSwitched,
      'imageUrl': _uploadedFileURL
    }).then((value) {
         Fluttertoast.showToast(
            msg: "Successfully Added to Your Store",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff16172a),
            textColor: Color(0xfff4f4f4),
            fontSize: 10.0);
    });
  }

// generate a random string to use as your document Id
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String generateRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Widget build(BuildContext context) {
    // check if the information was passed here, and if not show the default empty boxes
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppBar(
                        centerTitle: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0.0,
                        title: Text('Edit Liquor',
                            style: TextStyle(
                                color: Color(0xffe1e1e1),
                                fontSize: 20,
                                fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 120,
                            width: MediaQuery.of(context).size.width * 0.45,
                            decoration: BoxDecoration(
                              // color: Color(0xff37deed),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: _image == null
                                ? Center(
                                    child: Text('No image selected.',
                                        style: TextStyle(
                                            color: Color(0x5fe1e1e1),
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal)))
                                : Image.file(_image),
                          ),
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                  color: Color(0xffff8181),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                    child: Text('select photo',
                                        style: TextStyle(
                                            color: Color(0xffe1e1e1),
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal)))),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            width: MediaQuery.of(context).size.width * .45,
                            child: Text(
                              "If this switch is turned off, the Liquor won't be visible to customers viewing your store",
                              style: TextStyle(
                                  color: Color(0x5fe1e1e1), fontSize: 11),
                            )),
                        Switch(
                          value: _isSwitched,
                          onChanged: (value) {
                            setState(() {
                              _isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.blueGrey[100],
                          inactiveThumbColor: Colors.blueGrey[200],
                        ),
                      ],
                    ),
                    textinput(context, 'Name of Liquor', liquorNameController),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                margin: EdgeInsets.only(bottom: 6),
                                height: 50,
                                child: TextField(
                                  controller: liquorVolumeController,
                                  style: TextStyle(
                                      color: Color(0xffe1e1e1), fontSize: 13),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffff8181),
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffe1e1e1),
                                            width: 1.0),
                                      ),
                                      hintText: 'Volume in ml',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 11)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: 50,
                                margin: EdgeInsets.only(bottom: 6),
                                child: TextField(
                                  controller: liquorPriceController,
                                  style: TextStyle(
                                      color: Color(0xffe1e1e1), fontSize: 13),
                                  decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffff8181),
                                            width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffe1e1e1),
                                            width: 1.0),
                                      ),
                                      hintText: 'Price in kes',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                              child: bottombtn(
                                  Color(0xffff8181),
                                  Color(0xffe1e1e1),
                                  'Done',
                                  MediaQuery.of(context).size.width * 0.5,
                                  true,
                                  false,
                                  false),
                              onTap: () {
                                uploadEventImage();
                                Navigator.pop(context);
                              })
                        ])
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
