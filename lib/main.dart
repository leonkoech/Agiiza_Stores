import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';
import 'location.dart';
import 'events.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'order.dart';
import 'store.dart';
import 'liquor.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
// add firebase to the project now

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xff16172a),
      title: 'Agiiza Stores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(0xff16172A),
      ),
      home: Loadingpage(),
    );
  }
}

class Loadingpage extends StatefulWidget {
  @override
  _LoadingpageState createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  var email1, password1;

  @override
  void initState() {
    super.initState();
    isLoggedIn();
  }

  void isLoggedIn() {
    doesFileExist().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
      value
          ? logUserIn()
          : Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LandingPage()),
              (Route<dynamic> route) => false);
    });
  }

  void logUserIn() async {
    await readEmailAuthDetails().then((fetchedEmail) async {
      await readPasswordAuthDetails().then((fetchedPassword) {
        setState(() {
          email1 = fetchedEmail;
          password1 = fetchedPassword;
        });
        print(fetchedEmail);

        print(email1);
        signUserIn();
      });
    });
  }

  void signUserIn() async {
    print(email1);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email1, password: password1)
          .then((value) {
        setState(() {
          _isLoading = false;
          print(_isLoading);
        });

        Fluttertoast.showToast(
            msg: "Successfully logged in",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff16172a),
            textColor: Color(0xfff4f4f4),
            fontSize: 10.0);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      }).catchError((err) {
        print(err);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff16172a),
      body: Container(
        child: Center(
          child: SpinKitChasingDots(
            color: Color(0xffff8181),
            size: 50.0,
            duration: Duration(milliseconds: 2000),
          ),
        ),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.8;
    return Scaffold(
        appBar: null,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: height,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.2),
                child: Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      Container(
                          child:   ClipRect(
                    
                              child: new Image.asset('assets/images/AgiizaLogo.png',width:100,height:100),
                              ),
                              ),
                      Text('Agiiza Stores',
                          style: TextStyle(
                              fontSize: 30,
                              color: Color(0xffff8181),
                              fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: normalbtn(context, Color(0xffff8181),
                            Color(0xffe1e1e1), 'Sign In'),
                      ),
                      Text('or',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xffe1e1e1),
                              fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        },
                        child: borderbtn(context, Color(0xffff8181),
                            Color(0xffff8181), 'Create Account'),
                      ),
                    ])),
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Terms and conditions',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xffe6f1ff))),
                    Text('About us',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xffee6f1ff)))
                  ])
            ],
          ),
        ));
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.7;
    double halfwidth = MediaQuery.of(context).size.width * 0.5;
    double childscrollviewheight = MediaQuery.of(context).size.height;

    load() {
      setState(() {
        _isLoading = !_isLoading;
      });
    }

    loginUser() async {
      load();
      try {
        if (emailLoginController.text != '' &&
            passwordLoginController.text != '') {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: emailLoginController.text,
                  password: passwordLoginController.text)
              .then((value) {
            setState(() {
              _isLoading = false;
              print(_isLoading);
            });

            Fluttertoast.showToast(
                msg: "Successfully logged in",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Color(0xff16172a),
                textColor: Color(0xfff4f4f4),
                fontSize: 10.0);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomePage()),
                (Route<dynamic> route) => false);
          }).catchError((err) {
            load();
            Fluttertoast.showToast(
                msg: err,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Color(0xff16172a),
                textColor: Color(0xfff4f4f4),
                fontSize: 10.0);
          });
        }
      } catch (e) {
        var message;
        if (Platform.isAndroid) {
          setState(() {
            _isLoading = false;
          });
          print(e);
          Fluttertoast.showToast(
              msg: e.message,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xffff8181),
              textColor: Color(0xfff4f4f4),
              fontSize: 10.0);
        }
      }
    }

    return Scaffold(
      //  backgroundColor: Color(0xffe3eaf4),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: childscrollviewheight,
          child: Center(
              child: Container(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 100, bottom: 10),
                // child: Image(
                //   image: AssetImage('assets/images/liquor.png'),
                //   height: 70,
                // ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 6),
                  child: Text('Agiiza Stores',
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffe1e1e1)))),
              Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 6),
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          width: c_width,
                          child: Text(
                            'Welcome back to Agiiza',
                            style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.normal,
                                color: Color(0x5ff4f4f4)),
                            textAlign: TextAlign.center,
                          )))),

              Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 6),
                  child: Text('Please Sign in with your email and password',
                      style:
                          TextStyle(fontSize: 18, color: Color(0x4fe1e1e1)))),
              // text entry box for email
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                margin: EdgeInsets.only(top: 7, bottom: 6),
                child: TextField(
                  controller: emailLoginController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffff8181), width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffe1e1e1), width: 1.0),
                      ),
                      hintText: 'Email',
                      hintStyle:
                          TextStyle(color: Color(0xffe1e1e1), fontSize: 11)),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                margin: EdgeInsets.only(top: 7, bottom: 6),
                child: TextField(
                  controller: passwordLoginController,
                  obscureText: true,
                  style: TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffff8181), width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xffe1e1e1), width: 1.0),
                      ),
                      hintText: 'Password',
                      hintStyle:
                          TextStyle(color: Color(0xffe1e1e1), fontSize: 11)),
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                  onTap: () {
                    loginUser();
                  },
                  child: normalbtn(context, Color(0xffff8181),
                      Color(0xffe1e1e1), 'Continue')),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: GestureDetector(
                        child: bottombtn(Color(0xff16172a), Color(0xffe1e1e1),
                            'Back', halfwidth, false, true, false),
                        onTap: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ),
            ],
          ))),
        ),
      ),
    );
  }
}

Widget normalbtn(
  BuildContext context,
  Color bgcolor,
  Color txtcolor,
  String btntext,
) {
  return ButtonTheme(
      height: 50,
      minWidth: MediaQuery.of(context).size.width - 40,
      child: FlatButton(
          onPressed: null,
          child: Text(btntext),
          textColor: txtcolor,
          color: bgcolor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          disabledTextColor: txtcolor,
          padding: EdgeInsets.only(left: 120, right: 120, top: 20, bottom: 20),
          disabledColor: bgcolor));
}

Widget borderbtn(
  BuildContext context,
  Color bgcolor,
  Color txtcolor,
  String btntext,
) {
  return Container(
    height: 50,
    width: MediaQuery.of(context).size.width - 40,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: bgcolor,
      ),
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Center(child: Text(btntext, style: TextStyle(color: txtcolor))),
  );
}

Widget bottombtn(Color bgcolor, Color txtcolor, String btntext, double btnwidth,
    bool topleft, bool topright, bool arrow) {
  // double c_width = MediaQuery.of(context).size.width*0.5;
  Widget mywidget;
  if (topleft == true && arrow == false) {
    mywidget = ButtonTheme(
        height: 50,
        minWidth: btnwidth,
        child: FlatButton(
            onPressed: null,
            child: Text(btntext),
            textColor: txtcolor,
            color: bgcolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            disabledTextColor: txtcolor,
            disabledColor: bgcolor));
  } else if (topright == true && arrow == false) {
    mywidget = ButtonTheme(
        height: 50,
        minWidth: btnwidth,
        child: FlatButton(
            onPressed: null,
            child: Text(btntext),
            textColor: txtcolor,
            color: bgcolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            disabledTextColor: txtcolor,
            disabledColor: bgcolor));
  }
  if (topleft == true && arrow == true) {
    mywidget = Container(
      height: 50,
      width: btnwidth,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
      ),
      child: Padding(
          padding: EdgeInsets.only(left: 40, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: Text(
                  btntext,
                  style: TextStyle(
                    color: txtcolor,
                  ),
                ),
              )),
              // Image(
              //     image: AssetImage('assets/images/arrowwhite.png'),
              //     height: 26),
            ],
          )),
    );
  } else if (topright == true && arrow == true) {
    mywidget = Container(
      height: 50,
      width: btnwidth,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
      ),
      child: Padding(
          padding: EdgeInsets.only(left: 20, right: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Transform.rotate(
                angle: -47.12,
                // child: Image(
                //     image: AssetImage('assets/images/arrowwhite.png'),
                //     height: 26),
              ),
              Center(
                  child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: Text(
                  btntext,
                  style: TextStyle(
                    color: txtcolor,
                  ),
                ),
              )),
            ],
          )),
    );
  }
  return mywidget;
}

Widget textinput(BuildContext context, String hinttext,
    TextEditingController thecontroller) {
  //  @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   thecontroller.dispose();
  // }
  return Container(
    width: MediaQuery.of(context).size.width - 40,
    height: 50,
    margin: EdgeInsets.only(top: 7, bottom: 6),
    child: TextField(
      controller: thecontroller,
      style: TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffff8181), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffe1e1e1), width: 1.0),
          ),
          hintText: hinttext,
          hintStyle: TextStyle(color: Color(0xffe1e1e1), fontSize: 11)),
    ),
  );
}

Widget numberinput(BuildContext context, String hinttext,
    TextEditingController thecontroller) {
  //  @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   thecontroller.dispose();
  // }
  return Container(
    width: MediaQuery.of(context).size.width - 40,
    height: 50,
    margin: EdgeInsets.only(top: 7, bottom: 6),
    child: TextField(
      keyboardType: TextInputType.number,
      controller: thecontroller,
      style: TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffff8181), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffe1e1e1), width: 1.0),
          ),
          hintText: hinttext,
          hintStyle: TextStyle(color: Color(0xffe1e1e1), fontSize: 11)),
    ),
  );
}

Widget backbtn(Color bgcolor, Color txtcolor, String btntext, double btnwidth,
    bool topleft, bool topright, bool arrow) {
  return Container(
    height: 50,
    width: btnwidth,
    decoration: BoxDecoration(
      color: bgcolor,
      borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
    ),
    child: Padding(
        padding: EdgeInsets.only(left: 30, right: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Transform.rotate(
              angle: -47.12,
              child: Image(
                  image: AssetImage('assets/images/arrow.png'), height: 26),
            ),
            Center(
                child: Padding(
              padding: EdgeInsets.only(left: 0, right: 0),
              child: Text(
                btntext,
                style: TextStyle(
                  color: txtcolor,
                ),
              ),
            )),
          ],
        )),
  );
}

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // controllers for the texts
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final locationController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String _password;
  int steps = 0;
  // firebase stuff

  FirebaseAuth auth = FirebaseAuth.instance;
  // Initially password is obscure

  // Toggles the password show status
  @override
  void initState() {
    super.initState();
    // _getUserLocation();
    getStoreLatLng();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void checkUser() {
    auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  load() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<bool> createUser() async {
    bool results;
    // check if passwords match
    load();
    if (passwordController.text == confirmPasswordController.text) {
      // run the normal code
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((value) {
          // go to the next page
          load();
          results = true;
        }).catchError((value) {
          load();
          print(value);
          results = false;
          Fluttertoast.showToast(
              msg: "The Password entered is too weak",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xff16172a),
              textColor: Color(0xfff4f4f4),
              fontSize: 10.0);
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          // put toast here. Also, check if it matches with confirm password
          print('The password provided is too weak.');
          Fluttertoast.showToast(
              msg: "The Password entered is too weak",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xff16172a),
              textColor: Color(0xfff4f4f4),
              fontSize: 10.0);
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
          Fluttertoast.showToast(
              msg: "That Email is Taken",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xff16172a),
              textColor: Color(0xfff4f4f4),
              fontSize: 10.0);
        }
        results = false;
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg: e,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff16172a),
            textColor: Color(0xfff4f4f4),
            fontSize: 10.0);
        results = false;
      }
    } else {
      results = false;
      print('the passwords do not match');
      Fluttertoast.showToast(
          msg: "The Password do not Match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff16172a),
          textColor: Color(0xfff4f4f4),
          fontSize: 10.0);
    }
    return results;
  }

  checkStore() {
    FirebaseAuth auth = FirebaseAuth.instance;
    load();
    final User user = auth.currentUser;
    final uid = user.uid;
    FirebaseFirestore.instance
        .collection('Stores')
        .where('storeId', isEqualTo: uid)
        .limit(1)
        .get()
        .then((value) {
      addUserInfo();
    }).catchError((onError) {
      print('this is the error my king');
      Fluttertoast.showToast(
          msg: "No Location Selected",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff16172a),
          textColor: Color(0xfff4f4f4),
          fontSize: 10.0);
      load();
    });
  }

  void addUserInfo() async {
    // use the name of the store to create the store. The store name should be unique

    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;

    await databaseReference.collection("Stores").doc(uid).update({
      'storeName': nameController.text,
      'storeId': uid,
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'phoneNumber': phoneNumberController.text,
    }).then((value) {
      writeAuthDetails(emailController.text, passwordController.text)
          .then((value) {
        load();
        nextStep();
        Fluttertoast.showToast(
            msg: "Store has been created",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xff16172a),
            textColor: Color(0xfff4f4f4),
            fontSize: 10.0);
      });
    }).catchError((err) {
      load();
      Fluttertoast.showToast(
          msg: "No Location Selected",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xff16172a),
          textColor: Color(0xfff4f4f4),
          fontSize: 10.0);
    });
  }

  void nextStep() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      steps++;
    });
  }

  void prevStep() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      steps--;
    });
  }

// for the maps functionality
  GoogleMapController controller1;

  static LatLng _center = LatLng(-15.4630239974464, 28.363397732282127);
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _getUserLocation() async {
    // ignore: deprecated_member_use
    geo.Position position = await geo.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    // List<Placemark> placemark = await Geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      // print('${placemark[0].name}');
    });
    print(_initialPosition);
  }

  _onMapCreated(GoogleMapController controller) {
    controller1 = controller;
    // getStoreLatLng();

    setState(() {
      // add markers
      // _markers.add(Marker(
      //     markerId: MarkerId("0"),
      //     position: _initialPosition,
      //     infoWindow:
      //         InfoWindow(title: nameController.text, snippet: 'This is the current location of your store')));
    });
    setMapStyle();
  }

  fetchStoreName() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('Stores').doc(uid).get();
    print(document.data()["location"]);
    return document.data()['storeName'];
  }

  getStoreLatLng() async {
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
          var storeName = nameController.text;
          _markers.clear();
          _markers.add(Marker(
              markerId: MarkerId("0"),
              position: _initialPosition,
              infoWindow: InfoWindow(
                  title: storeName == '' ? 'Your Store' : storeName,
                  snippet: 'This is the current location of your store')));
        });
        _currentLocation(_initialPosition);
        print(_initialPosition);
        if (_initialPosition == null) {
          _getUserLocation();
        }
      }).catchError((onError) {
        print(onError);
        _getUserLocation();
      });
    } else {
      print('location not found');
      _getUserLocation();
    }
  }

  void setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString('assets/mapstyle.json');
    controller1.setMapStyle(style);
  }

  convertToDouble(lat, step) {
    lat = lat.replaceAll('LatLng', '');
    lat = lat.replaceAll('(', '');
    lat = lat.replaceAll(')', '');
    lat.split(',');

    // turn this string to double
    return double.parse(lat.split(',')[step]);
  }

  void _currentLocation(x) async {
    // final GoogleMapController controller = controller1;

    controller1.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: x,
        zoom: 17.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double halfwidth = MediaQuery.of(context).size.width * 0.5;
    double childscrollviewheight = MediaQuery.of(context).size.height - 50;
    return _isLoading
        ? Scaffold(
            backgroundColor: Color(0xff16172a),
            body: Container(
              child: Center(
                child: SpinKitChasingDots(
                  color: Color(0xffff8181),
                  size: 50.0,
                  duration: Duration(milliseconds: 2000),
                ),
              ),
            ),
          )
        : steps == 0
            ? Scaffold(
                backgroundColor: Color(0xff16172a),
                body: Container(
                  // height: childscrollviewheight,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 50),
                    child: SizedBox(
                      height: childscrollviewheight,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // // crossAxisAlignment: CrossAxisAlignment.center,
                        //  crossAxisAlignment: CrossAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            width: 320,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('Create account',
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            width: 320,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('Step 1 of 3',
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 24)),
                              ],
                            ),
                          ),

                          SizedBox(height: 15),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Container(
                              width: 180,
                              child: Text('Basic Information',
                                  style: TextStyle(
                                      color: Color(0xffe1e1e1), fontSize: 18)),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: textinput(
                                context, 'Email Address', emailController),
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: textinput(
                                context, 'Name of Store', nameController),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                              child: passwordInput(
                                  context, 'Password', passwordController)),
                          //  Padding(                     //   padding: EdgeInsets.only(left:45),
                          //     child: Container(

                          //     child:Text(
                          //     'Password is too short',
                          //     style:TextStyle(fontFamily:'Amiko',fontSize:16,color: Color(  0xffff8181))
                          //   ),
                          //   ),
                          // ),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: passwordInput(context, 'Confirm Password',
                                confirmPasswordController),
                          ),
                          Spacer(),
                          Row(children: <Widget>[
                            GestureDetector(
                                child: bottombtn(
                                    Color(0x002f3542),
                                    Color(0xffe1e1e1),
                                    'Back',
                                    halfwidth,
                                    false,
                                    true,
                                    false),
                                onTap: () {
                                  Navigator.pop(context);
                                }),
                            GestureDetector(
                                child: bottombtn(
                                    Color(0xffff8181),
                                    Color(0xffe1e1e1),
                                    'Next',
                                    halfwidth,
                                    true,
                                    false,
                                    false),
                                onTap: () {
                                  // void signUpUser() async {
                                  //   // ignore: await_only_futures
                                  //   var val = await createUser;
                                  //   if (val == true) {
                                  //     // proceed
                                  //     nextStep();
                                  //     print(val);
                                  //   } else {
                                  //     // do nothing per say
                                  //     print(val);
                                  //   }
                                  // }

                                  // signUpUser();
                                  createUser();
                                  nextStep();
                                })
                          ])
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : steps == 1
                ? Scaffold(
                    backgroundColor: Color(0xff16172a),
                    body: Container(
                      // height: childscrollviewheight,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 50),
                        child: SizedBox(
                          height: childscrollviewheight,
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // // crossAxisAlignment: CrossAxisAlignment.center,
                            //  crossAxisAlignment: CrossAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                width: 320,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Create account',
                                        style: TextStyle(
                                            color: Color(0xffe1e1e1),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                padding: EdgeInsets.only(left: 20),
                                width: 320,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Step 2 of 3',
                                        style: TextStyle(
                                            color: Color(0xffe1e1e1),
                                            fontSize: 24)),
                                  ],
                                ),
                              ),

                              SizedBox(height: 15),

                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Container(
                                  width: 180,
                                  child: Text('Contact Person Details',
                                      style: TextStyle(
                                          color: Color(0xffe1e1e1),
                                          fontSize: 18)),
                                ),
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: textinput(
                                    context, 'First Name', firstNameController),
                              ),

                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: textinput(
                                    context, 'Last Name', lastNameController),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                  child: numberinput(context, 'Phone Number',
                                      phoneNumberController)),
                              //  Padding(
                              //   padding: EdgeInsets.only(left:45),
                              //     child: Container(

                              //     child:Text(
                              //     'Password is too short',
                              //     style:TextStyle(fontFamily:'Amiko',fontSize:16,color: Color(  0xffff8181))
                              //   ),
                              //   ),
                              // ),
                              SizedBox(
                                height: 15,
                              ),

                              Spacer(),
                              Row(children: <Widget>[
                                GestureDetector(
                                    child: bottombtn(
                                        Color(0x002f3542),
                                        Color(0xffe1e1e1),
                                        'Back',
                                        halfwidth,
                                        false,
                                        true,
                                        false),
                                    onTap: () {
                                      prevStep();
                                    }),
                                GestureDetector(
                                    child: bottombtn(
                                        Color(0xffff8181),
                                        Color(0xffe1e1e1),
                                        'Next',
                                        halfwidth,
                                        true,
                                        false,
                                        false),
                                    onTap: () {
                                      // load map
                                      getStoreLatLng();
                                      nextStep();
                                    })
                              ])
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : steps == 2
                    ? Scaffold(
                        backgroundColor: Color(0xff16172a),
                        body: Container(
                          // height: childscrollviewheight,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 50),
                            child: SizedBox(
                              height: childscrollviewheight,
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                // // crossAxisAlignment: CrossAxisAlignment.center,
                                //  crossAxisAlignment: CrossAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    width: 320,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Create account',
                                            style: TextStyle(
                                                color: Color(0xffe1e1e1),
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding: EdgeInsets.only(left: 20),
                                    width: 320,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Step 3 of 3',
                                            style: TextStyle(
                                                color: Color(0xffe1e1e1),
                                                fontSize: 24)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      child: Text('Where is your store located',
                                          style: TextStyle(
                                              color: Color(0xffe1e1e1),
                                              fontSize: 18)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 15, left: 20),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      child: Text(
                                          'Click on the map to select location',
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Color(0x5fe1e1e1),
                                              fontSize: 14)),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Maps()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xffe1e1e1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        height: 280,
                                        margin:
                                            EdgeInsets.only(top: 7, bottom: 6),
                                        child: _initialPosition == null
                                            ? Container(
                                                color: Color(0xff16172a),
                                                child: Center(
                                                  // INTRODUCE A LOADER HERE
                                                  child: Center(
                                                    child: SpinKitChasingDots(
                                                      color: Color(0xffff8181),
                                                      size: 30.0,
                                                      duration: Duration(
                                                          milliseconds: 2000),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : GoogleMap(
                                                markers: _markers,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: _initialPosition,
                                                  zoom: 14.4746,
                                                ),
                                                onMapCreated: _onMapCreated,
                                                zoomGesturesEnabled: false,
                                                zoomControlsEnabled: false,
                                                myLocationEnabled: true,
                                                compassEnabled: false,
                                                myLocationButtonEnabled: false,
                                                onTap: (_) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Maps()));
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Spacer(),
                                  Row(children: <Widget>[
                                    GestureDetector(
                                        child: bottombtn(
                                            Color(0x002f3542),
                                            Color(0xffe1e1e1),
                                            'Back',
                                            halfwidth,
                                            false,
                                            true,
                                            false),
                                        onTap: () {
                                          prevStep();
                                        }),
                                    GestureDetector(
                                        child: bottombtn(
                                            Color(0xffff8181),
                                            Color(0xffe1e1e1),
                                            'Done',
                                            halfwidth,
                                            true,
                                            false,
                                            false),
                                        onTap: () {
                                          // load();
                                          // addUserInfo();
                                          checkStore();
                                        })
                                  ])
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Scaffold(
                        appBar: null,
                        body: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('YOU ARE DONE\nCREATING YOUR STORE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Color(0xffe1e1e1),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 30,
                                ),
                                Text('Add the liquor you sell now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 18)),
                                SizedBox(
                                  height: 25,
                                ),
                                Center(
                                    child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => AddLiquor()),
                                        (Route<dynamic> route) => false);
                                  },
                                  child: normalbtn(context, Color(0xffff8181),
                                      Color(0xffe1e1e1), 'Add Liquor'),
                                )),
                                SizedBox(
                                  height: 25,
                                ),
                                Text('or',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color(0xffe1e1e1),
                                        fontSize: 18)),
                                SizedBox(
                                  height: 25,
                                ),
                                Center(
                                    child: GestureDetector(
                                  child: borderbtn(context, Color(0xffff8181),
                                      Color(0xffff8181), 'Skip For Now'),
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false);
                                  },
                                )),
                              ],
                            ),
                          ),
                        ));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearch = false;
  final TextEditingController orderSearch = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId;
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
 

  void firebaseCloudMessagingListeners() {
     final User user = auth.currentUser;
    final uid = user.uid;
    _firebaseMessaging.subscribeToTopic(uid);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        setState(() {
          // _firebaseMessaging.getToken().then((token) {
          //   print("token is: " + token);
          // });
          // when the notification is clicked open the page that contains the data
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
  @override
  void initState() {
    super.initState();
    getUserId();
      firebaseCloudMessagingListeners();

  }

  getUserId() {
    final User user = auth.currentUser;
    final uid = user.uid;
    setState(() {
      userId = uid;
    });
    return uid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: new Container(),
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: _isSearch == false
              ? Text('AGIIZA STORES',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold))
              : TextField(
                  controller: orderSearch,
                  autofocus: true,
                  cursorColor: Color(0xffff8181),
                  // maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xffcccccc),
                    letterSpacing: 0.7,
                  ),
                  textInputAction: TextInputAction.search,
                  // buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,thi
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Orders',
                      hintStyle:
                          TextStyle(color: Color(0xffcccccc), fontSize: 13)),
                ),
          actions: [
            _isSearch == false
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearch = true;
                      });
                    },
                    child: Icon(
                      Icons.search,
                      color: Color(0xffcccccc),
                      size: 25.0,
                      semanticLabel: 'Search For An Order',
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearch = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Color(0xffff8181),
                      size: 25.0,
                      semanticLabel: 'Search For An Order',
                    ),
                  ),
            SizedBox(width: 15),
          ],
          // backgroundColor: Colors.black26,
          backgroundColor: Color(0xff16172a),
          elevation: 0.0,
          bottom: _isSearch == false
              ? TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Color(0xffff8181),
                  // indicatorPadding: EdgeInsets.fromLTRB(10, 0, 10, 12),
                  // indicatorWeight: 2,
                  labelColor: Color(0xffff8181),
                  labelStyle:
                      const TextStyle(color: Color(0xffff8181), fontSize: 12),
                  unselectedLabelColor: Colors.white,
                  unselectedLabelStyle:
                      const TextStyle(color: Colors.white, fontSize: 12),
                  isScrollable: false,
                  labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  tabs: [
                      Tab(
                          child: Container(
                              child: Center(
                        child: Text(
                          'Orders',
                          textAlign: TextAlign.center,
                        ),
                      ))),
                      Tab(
                          child: Container(
                              child: Center(
                        child: Text(
                          'Liquors',
                          textAlign: TextAlign.center,
                        ),
                      ))),
                      Tab(
                          child: Container(
                              child: Center(
                        child: Text(
                          'Events',
                          textAlign: TextAlign.center,
                        ),
                      ))),
                      Tab(
                          child: Container(
                              child: Center(
                        child: Text(
                          'Sales',
                          textAlign: TextAlign.center,
                        ),
                      ))),
                      Tab(
                          child: Container(
                              child: Center(
                        child: Text(
                          'Store',
                          textAlign: TextAlign.center,
                        ),
                      ))),
                    ])
              : null,
        ),
        body: _isSearch == false
            ? TabBarView(children: [
                OrderTab(),
                Stack(children: [
                  Align(
                    alignment: Alignment.center,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Liquor')
                          .where("storeId", isEqualTo: userId)
                          // .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        if (!snapshot.hasData)
                          return Center(
                              child: new Text(
                            'No Liquors\nClick the button below to Add liquor',
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
                                children: snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                                  if (snapshot.data.docs != null) {
                                    return LiquorItem(
                                      imageUrl: document.data()['imageUrl'],
                                      liquorId: document.data()['docId'],
                                      liquorName: document.data()['liquorName'],
                                      liquorPrice: document.data()['liquorPrice'].toString(),
                                      liquorQty: document.data()['liquorVolume'].toString(),
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
                                child: Text(
                                    'Click here to add any liquor to your store',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0x6fe1e1e1)))),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddLiquor()));
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
                                            fontSize: 12,
                                            color: Color(0xffe1e1e1)))),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    // child: Stats(),
                    child: Events()),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  // child: Stats(),
                  child: ListView(
                    children: [
                      StatsCard(
                          maintitle: 'Lifetime Stats',
                          ordersReceived: 12,
                          amountEarned: 65000,
                          bottlesSold: 42,
                          ordersCompleted: 12),
                      StatsCard(
                          maintitle: 'Today',
                          ordersReceived: 12,
                          amountEarned: 65000,
                          bottlesSold: 42,
                          ordersCompleted: 12),
                      StatsCard(
                          maintitle: 'This Week',
                          ordersReceived: 12,
                          amountEarned: 65000,
                          bottlesSold: 42,
                          ordersCompleted: 12),
                      StatsCard(
                          maintitle: 'This Month',
                          ordersReceived: 12,
                          amountEarned: 65000,
                          bottlesSold: 42,
                          ordersCompleted: 12),
                      SizedBox(height: 20)
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    // child: Stats(),
                    child: ListView(
                      children: [MyStore()],
                    )),
              ])
            : Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                // child: SearchList(orderId: orderSearch.text),
              ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String maintitle;
  final int ordersReceived;
  final int amountEarned;
  final int bottlesSold;
  final int ordersCompleted;
  const StatsCard(
      {Key key,
      this.maintitle,
      this.ordersReceived,
      this.bottlesSold,
      this.ordersCompleted,
      this.amountEarned})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(maintitle,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffe1e1e1)))
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orders Received',
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
              Text(ordersReceived.toString(),
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount Earned',
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
              Text(changeCurrency(amountEarned),
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bottles Sold',
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
              Text(bottlesSold.toString(),
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orders Completed',
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
              Text(ordersCompleted.toString(),
                  style: TextStyle(fontSize: 13, color: Color(0xffe1e1e1))),
            ],
          ),
        ],
      ),
    );
  }
}

String changeCurrency(amount) {
  //this function changes the currency to commas and KES at the end
  final oCcy = new NumberFormat("#,##0.00", "en_US");
  return oCcy.format(amount) + " KES";
}

showAlertDialog(BuildContext context, String contact, int action) {
  // set up the buttons
  Widget cancelButton = action == 0
      ? FlatButton(
          child: Container(
              width: 50,
              child: Text("Cancel",
                  style: TextStyle(fontSize: 12, color: Color(0xffff8181)))),
          onPressed: () {
            Navigator
                // .of(context, rootNavigator: true)
                .pop(context);
          },
        )
      : FlatButton(
          child: Container(
              width: 70,
              child: Text("Cancel",
                  style: TextStyle(fontSize: 12, color: Color(0xffff8181)))),
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
                style: TextStyle(fontSize: 12, color: Colors.white)))),
    onPressed: () {
      // _openAlert("tel:" + contact);
    },
  );
  Widget messageButton = FlatButton(
    textColor: Color(0xffcccccc),
    color: Color(0xff202020),
    child: Container(width: 50, child: Center(child: Text("call"))),
    onPressed: () {
      // _openAlert("tel:" + contact);
    },
  );
  Widget textButton = FlatButton(
    child: Container(width: 50, child: Text("message")),
    onPressed: () {
      // _openAlert("sms:" + contact);
    },
  );
  final newController = TextEditingController();
  final oldController = TextEditingController();
  Widget inputone = textinput(context, 'Old  $contact', oldController);
  Widget inputtwo = textinput(context, 'New  $contact', newController);

  // set up the AlertDialog
  AlertDialog alert = action == 0
      ? AlertDialog(
          title: Text("Contact"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text("Do you wish to contact \n"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(contact, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(" ?")
                ],
              ),
            ],
          ),
          actions: [cancelButton, textButton, messageButton],
          actionsOverflowButtonSpacing: 20.0,
        )
      : AlertDialog(
          backgroundColor: Color(0xff16172a),
          title: Text("Change $contact", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [inputone, inputtwo],
          ),
          actions: [cancelButton, submitButton],
          actionsOverflowButtonSpacing: 20.0,
        );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// _openAlert(url) async {
//   // const url = 'tel:0776069961';
//   if (await canLaunch(url)) {
//     await launch(url);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
Widget passwordInput(BuildContext context, String hinttext,
    TextEditingController thecontroller) {
  //  @override
  // void dispose() {
  //   // Clean up the controller when the widget is disposed.
  //   thecontroller.dispose();
  // }
  return Container(
    width: MediaQuery.of(context).size.width - 40,
    height: 50,
    margin: EdgeInsets.only(top: 7, bottom: 6),
    child: TextField(
      controller: thecontroller,
      obscureText: true,
      style: TextStyle(color: Color(0xffe1e1e1), fontSize: 13),
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffff8181), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffe1e1e1), width: 1.0),
          ),
          hintText: hinttext,
          hintStyle: TextStyle(color: Color(0xffe1e1e1), fontSize: 11)),
    ),
  );
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/credentials.txt');
}

Future<File> writeAuthDetails(email, password) async {
  final file = await _localFile;
    String objText = '{"email": "$email", "password": "$password"}';

  // Write the file.
  return file.writeAsString(objText);
}

Future<bool> doesFileExist() async {
  bool mybool = false;
  try {
    final file = await _localFile;

    // Read the file.
    String contents = await file.readAsString();
    if (contents != null || contents != '') {
      mybool = true;
    } else {
      mybool = false;
    }
  } catch (e) {
    // If encountering an error, return 0.
    print(e);
    mybool = false;
  }

  return mybool;
}

Future<String> readEmailAuthDetails() async {
  var mystring;
  try {
    final file = await _localFile;

    // Read the file.
    String contents = await file.readAsString();
    var data = json.decode(contents);
    mystring = data['email'].toString();
  } catch (e) {
    // If encountering an error, return 0.
    print(e);
    mystring = null;
  }
  return mystring;
}

Future<String> readPasswordAuthDetails() async {
  var mystring;
  try {
    final file = await _localFile;

    // Read the file.
    String contents = await file.readAsString();
    var data = json.decode(contents);
    print(data['password']);

    mystring = data['password'];
  } catch (e) {
    print(e);
    // If encountering an error, return 0.
    mystring = null;
  }
  return mystring;
}

Future<bool> deleteCredentials() async {
  bool mybool;
  try {
    final file = await _localFile;

    await file.delete();
    mybool = true;
  } catch (e) {
    mybool = false;
  }
  return mybool;
}
