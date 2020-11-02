import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'location.dart';
import 'events.dart';
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

class MyStore extends StatefulWidget {
  @override
  _MyStoreState createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  String storeName;
  String contactPhone;
  String contactName;
  String emailAddress;
  String password;
  bool _isLoading = false;
  // for the maps functionality
  GoogleMapController controller1;

  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();
    getStoreLatLng();
  }

  load() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    controller1 = controller;
    setMapStyle();
    getStoreLatLng();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: _initialPosition,
        zoom: 15.0,
      ),
    ));
    setState(() {
      // add markers
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId("0"),
          position: _initialPosition,
          infoWindow: InfoWindow(
              title: fetchStoreName().toString(),
              snippet: fetchStoreName().toString())));
    });
  }

  void setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString('assets/mapstyle.json');
    controller1.setMapStyle(style);
  }

// function to convert the location string to latlng
  convertToDouble(lat, step) {
    lat = lat.replaceAll('LatLng', '');
    lat = lat.replaceAll('(', '');
    lat = lat.replaceAll(')', '');
    lat.split(',');

    // turn this string to double
    return double.parse(lat.split(',')[step]);
  }

  getContactFirstName() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;

    return new 
    StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Stores')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Center(
              child: SpinKitChasingDots(
                color: Color(0xffff8181),
                size: 10.0,
                duration: Duration(milliseconds: 2000),
              ),
            );
          }
          var userDocument = snapshot.data;
          return new Text(userDocument["firstName"],
              style: TextStyle(
                color: Color(0xffe1e1e1),
                fontSize: 13,
              ));
        });
  }

  getContactLastName() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;

    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Stores')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Center(
              child: SpinKitChasingDots(
                color: Color(0xffff8181),
                size: 10.0,
                duration: Duration(milliseconds: 2000),
              ),
            );
          }
          var userDocument = snapshot.data;
          return new Text(userDocument["lastName"],
              style: TextStyle(
                color: Color(0xffe1e1e1),
                fontSize: 13,
              ));
        });
  }

  getStoreName() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;

    return uid != null
        ? new StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Stores')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Center(
                  child: SpinKitChasingDots(
                    color: Color(0xffff8181),
                    size: 10.0,
                    duration: Duration(milliseconds: 2000),
                  ),
                );
              }
              var userDocument = snapshot.data;
              print(userDocument["storeName"]);
              return new Text(userDocument["storeName"],
                  style: TextStyle(
                    color: Color(0xffe1e1e1),
                    fontSize: 13,
                  ));
            })
        : new Text('Add Store Name');
  }

  getStorePhone() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;

    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Stores')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Center(
              child: SpinKitChasingDots(
                color: Color(0xffff8181),
                size: 10.0,
                duration: Duration(milliseconds: 2000),
              ),
            );
          }
          var userDocument = snapshot.data;
          return new Text(userDocument["phoneNumber"],
              style: TextStyle(
                color: Color(0xffe1e1e1),
                fontSize: 13,
              ));
        });
  }

  getStoreLatLng() async {
    load();
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('Stores')
          .doc(uid)
          .get()
          .then((value) {
        print(value.data()["location"]);
        var lat = convertToDouble(value.data()['location'], 0);
        var lng = convertToDouble(value.data()['location'], 1);
        setState(() {
          _initialPosition = LatLng(lat, lng);
          var storeName = '';
          _markers.clear();
          _markers.add(Marker(
              markerId: MarkerId("0"),
              position: _initialPosition,
              infoWindow: InfoWindow(
                  title: storeName == '' ? 'Your Store' : storeName,
                  snippet: 'This is the current location of your store')));
        });
        _currentLocation(LatLng(lat, lng));
        print('--------------------------');
        print(_initialPosition);
        print('--------------------------');
      }).catchError((onError) {
        print(onError);
      });
    } else {
      print('location not found');
    }
    load();
  }

  fetchStoreName() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('Stores').doc(uid).get();
    return document.data()['storeName'];
  }

  void _currentLocation(loc) async {
    final GoogleMapController controller = controller1;

    try {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: loc,
          zoom: 15.0,
        ),
      ));
    } catch (e) {
      // no such method error occurred
      print(e);
    }
  }

  editStoreLocation() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    FirebaseFirestore.instance
        .collection('Stores')
        .doc(uid)
        .get()
        .then((userDocument) {
      return LatLng(convertToDouble(userDocument['location'], 0),
          convertToDouble(userDocument['location'], 1));
    });
  }

// account details
  getAccountEmail() {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    return user.email;
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Container(
              child: Center(
                child: SpinKitChasingDots(
                  color: Color(0xffff8181),
                  size: 50.0,
                  duration: Duration(milliseconds: 2000),
                ),
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Store Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffe1e1e1)))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Name',
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      showStoreAlertDialog(context, 'Name', 0);
                    },
                    child: Text('Edit',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  getStoreName(),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Contact Phone',
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      showStoreAlertDialog(context, 'Contact Phone', 1);
                    },
                    child: Text('Edit',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [getStorePhone()],
              ),

              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("Contact's First Name",
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      showStoreAlertDialog(context, "Contact's First Name", 2);
                    },
                    child: Text('Edit',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  getContactFirstName(),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("Contact's Last Name",
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      showStoreAlertDialog(context, "Contact's Last Name", 3);
                    },
                    child: Text('Edit',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  getContactLastName(),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Location',
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UpdateMap(latlng: editStoreLocation())));
                    },
                    child: Text('Edit',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              // maps should here
              Center(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Color(0x5f8289ff),
                    ),
                    child: _initialPosition == null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6)),
                              color: Color(0x5f8289ff),
                            ),
                            child: Center(
                              child: SpinKitChasingDots(
                                color: Color(0xffff8181),
                                size: 50.0,
                                duration: Duration(milliseconds: 2000),
                              ),
                            ))
                        : GoogleMap(
                            markers: _markers,
                            initialCameraPosition: CameraPosition(
                              target: _initialPosition,
                              zoom: 14.4746,
                            ),
                            onMapCreated: _onMapCreated,
                            zoomGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            compassEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                    height: 120,
                    width: MediaQuery.of(context).size.width - 20),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Account Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffe1e1e1)))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Email Address',
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(getAccountEmail(),
                      style: TextStyle(
                        color: Color(0xffe1e1e1),
                        fontSize: 13,
                      )),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Password',
                      style: TextStyle(
                          color: Color(0x9fe1e1e1),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      showStoreAlertDialog(context, 'Password', 4);
                    },
                    child: Text('Change',
                        style: TextStyle(
                          color: Color(0xffff8181),
                          fontSize: 13,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('**********',
                      style: TextStyle(
                        color: Color(0xffe1e1e1),
                        fontSize: 13,
                      )),
                ],
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () async {
                  load();
                  //Create an instance of the current user.
                  FirebaseAuth auth = FirebaseAuth.instance;

                  final User user = auth.currentUser;
                  await auth.signOut().then((value) async {
                    await deleteCredentials().then((value) {
                      Fluttertoast.showToast(
                          msg: "Successfully Signed Out",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Color(0xff16172a),
                          textColor: Color(0xfff4f4f4),
                          fontSize: 13.0);
                      load();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LandingPage()),
                          (Route<dynamic> route) => false);
                    });
                  });
                },
                child: borderbtn(
                    context, Color(0xffff8181), Color(0xffff8181), 'Sign Out'),
              ),
              SizedBox(height: 15),
            ]),
          );
  }
}

showStoreAlertDialog(BuildContext context, String contact, int action) {
  bool load = false;
  // function to update tha name of the store
  _changeDetails(String newItem, detail) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("Stores").doc(uid).update({
      detail: newItem,
    }).then((value) {
      load = false;
    });
  }

  // function to update password
  void _changePassword(String password) async {
    //Create an instance of the current user.
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      print("Succesfull changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
    load = false;
  }

  final newController = TextEditingController();
  final oldController = TextEditingController();
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Container(
        width: 70,
        child: Text("Cancel",
            style: TextStyle(fontSize: 10, color: Color(0xffff8181)))),
    onPressed: () {
      Navigator
          // .of(context, rootNavigator: true)
          .pop(context);
    },
  );
  Widget submitButton = FlatButton(
    textColor: Colors.white,
    color: Color(0xffff8181),
    disabledColor: Color(0xffff8181),
    child: Container(
        width: 70,
        child: Center(
            child: Text("Confirm",
                style: TextStyle(fontSize: 10, color: Color(0xfff4f4f4))))),
    onPressed: () {
      // _openAlert("tel:" + contact);
      // make this perform functions it should perform
      switch (action) {
        case 0:
          load = true;
          _changeDetails(newController.text, 'storeName');
          Navigator.pop(context);
          // clear the controller
          break;
        case 1:
          load = true;
          _changeDetails(newController.text, 'phoneNumber');
          Navigator.pop(context);
          break;
        case 2:
          load = true;
          _changeDetails(newController.text, 'firstName');
          Navigator.pop(context);
          break;
        case 3:
          load = true;
          _changeDetails(newController.text, 'lastName');
          Navigator.pop(context);
          break;
        case 4:
          load = true;
          _changePassword(newController.text);
          Navigator.pop(context);
          break;

        default:
      }
    },
  );

  Widget inputtwo = textinput(context, 'New  $contact', newController);

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Color(0xff16172a),
    title: Text("Change $contact", style: TextStyle(color: Colors.white)),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [inputtwo],
    ),
    actions: [cancelButton, submitButton],
    actionsOverflowButtonSpacing: 20.0,
  );
  AlertDialog loadr = AlertDialog(
      backgroundColor: Color(0xff16172a),
      title: null,
      content: Center(
        child: SpinKitChasingDots(
          color: Color(0xffff8181),
          size: 30.0,
          duration: Duration(milliseconds: 2000),
        ),
      ));
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return load ? loadr : alert;
    },
  );
}
