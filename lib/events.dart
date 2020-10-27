import 'dart:io';

import 'package:flutter/material.dart';
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

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  bool _isSwitched = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final dateToController = TextEditingController();

  final dateFromController = TextEditingController();
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

  uploadEventImage() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('events/${_image.toString()}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    // await uploadTask.onComplete;
    print('File Uploaded');
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    // setState(() {
    //   _uploadedFileURL = dowurl.toString();
    // });
    print(dowurl.toString());
    addEventId(dowurl.toString());
    // url = dowurl.toString();
    // storageReference.getDownloadURL().then((fileURL) {
    //   setState(() {
    //     _uploadedFileURL = fileURL;
    //   });
    //   addEventId(fileURL);
    // });
  }

  addEventInfo(value) async {
    // use the name of the store to create the store. The store name should be unique
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    DocumentReference doc_ref =
        await databaseReference.collection("Events").add({
      'storeId': uid,
      'title': titleController.text,
      'description': descriptionController.text,
      'dateFrom': dateFromController.text,
      'dateTo': dateToController.text,
      'imageUrl': value,
      'active': _isSwitched,
      'timeStamp': Timestamp.now(),
    });
    return doc_ref;
  }

  void addEventId(value) async {
    DocumentReference myval = await addEventInfo(value);
    print(myval);
    DocumentSnapshot docSnap = await myval.get();
    var doc_id = docSnap.reference.id;
    print(doc_id);
    // upload the information about the document id now
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("Events").doc(doc_id).update({
      'docId': doc_id,
    });
  }

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
                        title: Text('Create an Event',
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
                                ? Center(child: Text('No image selected.',style: TextStyle(
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
                              "If this switch is turned off, the event won't show on customer's event tab",
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
                    textinput(context, 'Title', titleController),
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 6,
                        style:
                            TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffff8181), width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffe1e1e1), width: 1.0),
                            ),
                            hintText: 'Description',
                            hintStyle: TextStyle(
                                color: Color(0xffe1e1e1), fontSize: 13)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Select dates',
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                margin: EdgeInsets.only(top: 7, bottom: 6),
                                height: 50,
                                child: TextField(
                                  controller: dateFromController,
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
                                      hintText: 'From',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 13)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: 50,
                                margin: EdgeInsets.only(top: 7, bottom: 6),
                                child: TextField(
                                  controller: dateToController,
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
                                      hintText: 'To',
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 13)),
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

                                // print(_uploadedFileURL);
                                // show a toast that says 'event has been uploaded'
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

class EditEvent extends StatefulWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String description;
  final String imageUrl;
  final String eventID;
  final bool active;
  final String timestamp;
  const EditEvent(
      {Key key,
      @required this.title,
      @required this.startDate,
      @required this.endDate,
      @required this.description,
      @required this.eventID,
      @required this.active,
      @required this.timestamp,
      this.imageUrl})
      : super(key: key);
  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  bool _isSwitched = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final dateToController = TextEditingController();

  final dateFromController = TextEditingController();
  File _image;
  final picker = ImagePicker();
  void setThings() {
    setState(() {
      _isSwitched = widget.active;
    });
  }

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

  uploadEventImage() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('eventss/${_image.path}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    // await uploadTask.onComplete;
    print('File Uploaded');
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    // setState(() {
    //   _uploadedFileURL = dowurl.toString();
    // });
    print(dowurl.toString());
    updateEventInfo(dowurl.toString());
    // url = dowurl.toString();
  }

  void updateEventInfo(value) async {
    // use the name of the store to create the store. The store name should be unique
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("Events").doc(widget.eventID).update({
      'storeId': uid,
      'title':
          titleController.text != '' ? titleController.text : widget.title,
      'description': descriptionController.text != ''
          ? descriptionController.text
          : widget.description,
      'dateFrom': dateFromController.text != ''
          ? dateFromController.text
          : widget.startDate,
      'dateTo': dateToController.text != ''
          ? dateToController.text
          : widget.endDate,
      'imageUrl': value != null ? value : widget.imageUrl,
      'active': _isSwitched,
      'timeStamp': Timestamp.now(),
    });
  }

  Widget build(BuildContext context) {
    // check if the information was passed here, and if not show the default empty boxes
    setThings();
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
                        title: Text('Edit Event',
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
                              child: _image != null
                                  ? Image.file(_image)
                                  : widget.imageUrl == null
                                      ? Center(child: Text('No Image Selected'))
                                      : Image.network(widget.imageUrl)),
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
                              "If this switch is turned off, the event won't show on customer's event tab",
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
                    textinput(context, widget.title, titleController),
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 6,
                        style:
                            TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffff8181), width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xffe1e1e1), width: 1.0),
                            ),
                            hintText: widget.description,
                            hintStyle: TextStyle(
                                color: Color(0xffe1e1e1), fontSize: 13)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('Select dates',
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                margin: EdgeInsets.only(top: 7, bottom: 6),
                                height: 50,
                                child: TextField(
                                  controller: dateFromController,
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
                                      hintText: widget.startDate,
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 13)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: 50,
                                margin: EdgeInsets.only(top: 7, bottom: 6),
                                child: TextField(
                                  controller: dateToController,
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
                                      hintText: widget.endDate,
                                      hintStyle: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 13)),
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
                                if (_image != null) {
                                  uploadEventImage();
                                } else {
                                  updateEventInfo(null);
                                }

                                // show a toast that says 'event has been uploaded'
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
