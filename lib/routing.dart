import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoder/geocoder.dart';
import 'main.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//  firebase plugins
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;

class OrderRoutingMap extends StatefulWidget {
  final orderLocation;
  const OrderRoutingMap({Key key, this.orderLocation}) : super(key: key);
  @override
  OrderRoutingMapState createState() => OrderRoutingMapState();
}

class OrderRoutingMapState extends State<OrderRoutingMap> {
  GoogleMapController controller1;

  static LatLng _center = LatLng(-15.4630239974464, 28.363397732282127);
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  final TextEditingController locationSearch = TextEditingController();
  bool _isSearch = false;
  bool searching = false;
  @override
  void initState() {
    super.initState();
    // _getUserLocation();
    getStoreLatLng();
    locationSearch.addListener(() {
      // final text = locationSearch.text.toLowerCase();
      // search location here
      print('initialized');
    });
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
  }

  _onMapCreated(GoogleMapController controller) {
    controller1 = controller;
    setState(() {
      // add markers
      // _markers.add(Marker(
      //     markerId: MarkerId("0"),
      //     position: LatLng(
      //       -1.2921,
      //       36.8219,
      //     ),
      //     infoWindow:
      //         InfoWindow(title: "Nairobi", snippet: "City Under The Sun")));
      _markers.add(Marker(
          markerId: MarkerId("0"),
          position: _initialPosition,
          infoWindow: InfoWindow(
              title: 'Your Store',
              snippet: 'This is the Selected Store Location')));
      _markers.add(Marker(
          markerId: MarkerId('1'),
          position: widget.orderLocation,
          infoWindow: InfoWindow(
              title: 'Delivery Location',
              snippet: 'This is the Set Delivery Location')));
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

  void _currentLocation(loc) async {
    final GoogleMapController controller = controller1;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: loc,
        zoom: 17.0,
      ),
    ));
  }

  convertToDouble(lat, step) {
    lat = lat.replaceAll('LatLng', '');
    lat = lat.replaceAll('(', '');
    lat = lat.replaceAll(')', '');
    lat.split(',');

    // turn this string to double
    return double.parse(lat.split(',')[step]);
  }

  getStoreLatLng() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('Stores').doc(uid).get();
    print(document.data()["location"]);
    var lat = convertToDouble(document.data()['location'], 0);
    var lng = convertToDouble(document.data()['location'], 1);
    setState(() {
      _initialPosition = LatLng(lat, lng);
    });
    if (_initialPosition == null) {
      _getUserLocation();
    }
    _currentLocation(_initialPosition);
  }

  void setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString('assets/mapstyle.json');
    controller1.setMapStyle(style);
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  // _onAddMarkerButtonPressed() {
  //   setState(() {
  //     _markers.add(Marker(
  //         markerId: MarkerId(_lastMapPosition.toString()),
  //         position: _lastMapPosition,
  //         infoWindow: InfoWindow(
  //             title: "Your Store",
  //             snippet: "this is the place you selected",
  //             onTap: () {}),
  //         onTap: () {},
  //         icon: BitmapDescriptor.defaultMarker));
  //     print('----------------------------------------------------------------');
  //     print(_initialPosition);
  //     print('----------------------------------------------------------------');
  //     print(_lastMapPosition);
  //     print('----------------------------------------------------------------');
  //     _initialPosition = _lastMapPosition;
  //   });
  // }

  _getSelectedLocation() {
    // use this function to update information to firebase about the store
  }
  moveMarkerToMyLocation() {
    final GoogleMapController controller = controller1;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: _initialPosition,
        zoom: 17.0,
      ),
    ));
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  addStoreLocation() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("Stores").doc(uid).set({
      'location': _initialPosition.toString(),
    }).then((value) {
      Navigator.pop(context);
    });
  }

  Widget mapButton(Function function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(10.0),
    );
  }

// Google Api Key
  static const kGoogleApiKey = "AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns";
// https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=NameOfPlace&inputtype=textquery&fields=place_id,name&key=YOUR_API_KEY
// after getting the place Id use it to get the lat lang so that you can place it in the map
// then search how to move map camera with flutter on google
  List location;
  List locdetails;
  LatLng newlocation;
  map_to_string(map) {
    return json.decode(json.encode(map));
  }

  Future fetchLocationJson() async {
    String name = locationSearch.text;
    // session token
    // var token = new google.maps.places.AutocompleteSessionToken();

    final response = await http.get(
        // 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$name&types=geocode&key=<AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns>' //&sessiontoken=1234567890'
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$name&inputtype=textquery&fields=geometry,name,place_id,formatted_address&radius=10000&key=AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns');

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      print(parsedJson);
      setState(() {
        location = parsedJson['candidates'];
//         List<dynamic> data = mymap["candidates"];
//   var feometry=data[0]["geometry"];
//   var my_map2 = map_to_string(feometry);
//   var my_map3 = my_map2['location'];
//   var my_map5 = map_to_string(my_map3);
// //   var ffeometry2=second[0]['lat'];
// print(my_map5['lat']);
//   print(my_map5['lng']);
      });
      return parsedJson;
    } else {
      throw Exception('Failed to load');
    }
  }

  fetchLatLong(data) {
    var my_map2 = map_to_string(data);
    var my_map3 = my_map2['location'];
    var my_map5 = map_to_string(my_map3);
//   var ffeometry2=second[0]['lat'];

    var lat = my_map5['lat'];
    var long = my_map5['lng'];
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(lat.toString(),
            style: TextStyle(color: Color(0xffcccccc), fontSize: 14)),
        Text(long.toString(),
            style: TextStyle(color: Color(0xffcccccc), fontSize: 14)),
      ],
    );
  }

  moveMapCamera(data) {
    var my_map2 = map_to_string(data);
    var my_map3 = my_map2['location'];
    var my_map5 = map_to_string(my_map3);
//   var ffeometry2=second[0]['lat'];

    var lat = my_map5['lat'];
    var lng = my_map5['lng'];
    setState(() {
      _initialPosition = LatLng(lat, lng);
      _isSearch = false;
    });
    _currentLocation(LatLng(lat, lng));
  }

// to get places detail (lat/lng)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff16172a),
        appBar: AppBar(
          // leading: new Container(),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xfff4f4f4)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Order Location'),

          // backgroundColor: Colors.black26,
          backgroundColor: Color(0xff16172a),
          elevation: 0.0,
        ),
        body: _initialPosition == null
            ? Container(
                child: Center(
                  child: SpinKitChasingDots(
                    color: Color(0xffff8181),
                    size: 50.0,
                    duration: Duration(milliseconds: 2000),
                  ),
                ),
              )
            : Container(
                child: Stack(children: <Widget>[
                  GoogleMap(
                    markers: _markers,
                    mapType: _currentMapType,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.4746,
                    ),
                    onMapCreated: _onMapCreated,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    onCameraMove: _onCameraMove,
                    myLocationEnabled: true,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                  Center(
                    child: Icon(
                      Icons.location_searching,
                      size: 45,
                      color: Color(0xffff8181),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            moveMarkerToMyLocation();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            margin:
                                EdgeInsets.only(top: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff16172a),
                              border: Border.all(
                                color: Color(0xffff8181),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.my_location,
                              size: 23,
                              color: Color(0xffff8181),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onMapTypeButtonPressed();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            margin:
                                EdgeInsets.only(top: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff16172a),
                              border: Border.all(
                                color: Color(0xffff8181),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.map,
                              size: 23,
                              color: Color(0xffff8181),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isSearch
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: new ListView.builder(
                            itemCount: location == null ? 0 : location.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  moveMapCamera(location[index]['geometry']);
                                },
                                child: new Card(
                                  color: Color(0xff16172a),
                                  elevation: 1.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                        child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 7.5),
                                            child: new Text(
                                                location[index]
                                                    ["formatted_address"],
                                                style: TextStyle(
                                                    color: Color(0xffcccccc),
                                                    fontSize: 14))),
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 7.5, bottom: 10),
                                            child: fetchLatLong(
                                                location[index]['geometry'])),
                                      ],
                                    )),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        // upload either the location selected or current location to firebase
                        print(_markers.length);

                        addStoreLocation();
                        // navigator pop
                      },
                      child: bottombtn(
                          Color(0xffff8181),
                          Color(0xffe1e1e1),
                          'Delivered',
                          MediaQuery.of(context).size.width * 0.5,
                          true,
                          false,
                          false),
                    ),
                  ),
                ]),
              ),
      ),
    );
  }
}

class UpdateMap extends StatefulWidget {
  final latlng;
  const UpdateMap({Key key, @required this.latlng}) : super(key: key);
  @override
  UpdateMapState createState() => UpdateMapState();
}

class UpdateMapState extends State<UpdateMap> {
  GoogleMapController controller1;

  static LatLng _center = LatLng(-15.4630239974464, 28.363397732282127);
  static LatLng _initialPosition;
  final Set<Marker> _markers = {};
  static LatLng _lastMapPosition = _initialPosition;
  final TextEditingController locationSearch = TextEditingController();
  bool _isSearch = false;
  bool searching = false;
  @override
  void initState() {
    super.initState();
    // _getUserLocation();
    getStoreLatLng();
    locationSearch.addListener(() {
      // final text = locationSearch.text.toLowerCase();
      // search location here
      print('initialized');
    });
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
  }

  _onMapCreated(GoogleMapController controller) {
    controller1 = controller;
    setState(() {
      // add markers
      // _markers.add(Marker(
      //     markerId: MarkerId("0"),
      //     position: LatLng(
      //       -1.2921,
      //       36.8219,
      //     ),
      //     infoWindow:
      //         InfoWindow(title: "Nairobi", snippet: "City Under The Sun")));
      _markers.add(Marker(
          markerId: MarkerId("0"),
          position: _initialPosition,
          infoWindow: InfoWindow(
              title: 'Your Store',
              snippet: 'This is the Selected Store Location')));
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

  void _currentLocation(loc) async {
    final GoogleMapController controller = controller1;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: loc,
        zoom: 17.0,
      ),
    ));
  }

  convertToDouble(lat, step) {
    lat = lat.replaceAll('LatLng', '');
    lat = lat.replaceAll('(', '');
    lat = lat.replaceAll(')', '');
    lat.split(',');

    // turn this string to double
    return double.parse(lat.split(',')[step]);
  }

  getStoreLatLng() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;
    DocumentSnapshot document =
        await FirebaseFirestore.instance.collection('Stores').doc(uid).get();
    print(document.data()["location"]);
    var lat = convertToDouble(document.data()['location'], 0);
    var lng = convertToDouble(document.data()['location'], 1);
    setState(() {
      _initialPosition = LatLng(lat, lng);
    });
    if (_initialPosition == null) {
      _getUserLocation();
    }
    _currentLocation(_initialPosition);
  }

  void setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString('assets/mapstyle.json');
    controller1.setMapStyle(style);
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
              title: "Your Store",
              snippet: "this is the place you selected",
              onTap: () {}),
          onTap: () {},
          icon: BitmapDescriptor.defaultMarker));
      print('----------------------------------------------------------------');
      print(_initialPosition);
      print('----------------------------------------------------------------');
      print(_lastMapPosition);
      print('----------------------------------------------------------------');
      _initialPosition = _lastMapPosition;
    });
  }

  _getSelectedLocation() {
    // use this function to update information to firebase about the store
  }
  moveMarkerToMyLocation() {
    final GoogleMapController controller = controller1;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: _initialPosition,
        zoom: 17.0,
      ),
    ));
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  addStoreLocation() async {
    final User user = auth.currentUser;
    final uid = user.uid;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("Stores").doc(uid).update({
      'location': _initialPosition.toString(),
    }).then((value) {
      Navigator.pop(context);
    });
  }

  Widget mapButton(Function function, Icon icon, Color color) {
    return RawMaterialButton(
      onPressed: function,
      child: icon,
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: color,
      padding: const EdgeInsets.all(10.0),
    );
  }

// Google Api Key
  static const kGoogleApiKey = "AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns";
// https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=NameOfPlace&inputtype=textquery&fields=place_id,name&key=YOUR_API_KEY
// after getting the place Id use it to get the lat lang so that you can place it in the map
// then search how to move map camera with flutter on google
  List location;
  List locdetails;
  LatLng newlocation;
  map_to_string(map) {
    return json.decode(json.encode(map));
  }

  Future fetchLocationJson() async {
    String name = locationSearch.text;
    // session token
    // var token = new google.maps.places.AutocompleteSessionToken();

    final response = await http.get(
        // 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$name&types=geocode&key=<AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns>' //&sessiontoken=1234567890'
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$name&inputtype=textquery&fields=geometry,name,place_id,formatted_address&radius=10000&key=AIzaSyAbXcm4JYs8TNbxHuuhABjiiecaLzgvtns');

    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      print(parsedJson);
      setState(() {
        location = parsedJson['candidates'];
//         List<dynamic> data = mymap["candidates"];
//   var feometry=data[0]["geometry"];
//   var my_map2 = map_to_string(feometry);
//   var my_map3 = my_map2['location'];
//   var my_map5 = map_to_string(my_map3);
// //   var ffeometry2=second[0]['lat'];
// print(my_map5['lat']);
//   print(my_map5['lng']);
      });
      return parsedJson;
    } else {
      throw Exception('Failed to load');
    }
  }

  fetchLatLong(data) {
    var my_map2 = map_to_string(data);
    var my_map3 = my_map2['location'];
    var my_map5 = map_to_string(my_map3);
//   var ffeometry2=second[0]['lat'];

    var lat = my_map5['lat'];
    var long = my_map5['lng'];
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(lat.toString(),
            style: TextStyle(color: Color(0xffcccccc), fontSize: 14)),
        Text(long.toString(),
            style: TextStyle(color: Color(0xffcccccc), fontSize: 14)),
      ],
    );
  }

  moveMapCamera(data) {
    var my_map2 = map_to_string(data);
    var my_map3 = my_map2['location'];
    var my_map5 = map_to_string(my_map3);
//   var ffeometry2=second[0]['lat'];

    var lat = my_map5['lat'];
    var lng = my_map5['lng'];
    setState(() {
      _initialPosition = LatLng(lat, lng);
      _isSearch = false;
    });
    _currentLocation(LatLng(lat, lng));
  }

// to get places detail (lat/lng)
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xff16172a),
        appBar: AppBar(
          // leading: new Container(),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xfff4f4f4)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: searching
              ? TextField(
                  controller: locationSearch,
                  autofocus: true,
                  cursorColor: Color(0xffff8181),
                  // maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xfff4f4f4),
                  ),
                  textInputAction: TextInputAction.search,
                  // buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,thi
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Location',
                      hintStyle:
                          TextStyle(color: Color(0xffcccccc), fontSize: 14)),
                  onSubmitted: (s) async {
                    // populate the list
                    fetchLocationJson();

                    // if it prints something you want
                    setState(() {
                      _isSearch = true;
                    });
                  })
              : Text('Select Location'),
          actions: [
            searching
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        // clear text inside search
                        _isSearch = false;
                        searching = false;
                        locationSearch.clear();
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Color(0xffff8181),
                      size: 25.0,
                      semanticLabel: 'close search',
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        // clear text inside search
                        _isSearch = false;
                        searching = true;
                        locationSearch.clear();
                        print(searching);
                      });
                    },
                    child: Icon(
                      Icons.search,
                      color: Color(0xfff4f4f4),
                      size: 25.0,
                      semanticLabel: 'open search',
                    ),
                  ),
            SizedBox(width: 15),
          ],
          // backgroundColor: Colors.black26,
          backgroundColor: Color(0xff16172a),
          elevation: 0.0,
        ),
        body: _initialPosition == null
            ? Container(
                child: Center(
                  child: SpinKitChasingDots(
                    color: Color(0xffff8181),
                    size: 50.0,
                    duration: Duration(milliseconds: 2000),
                  ),
                ),
              )
            : Container(
                child: Stack(children: <Widget>[
                  GoogleMap(
                    markers: _markers,
                    mapType: _currentMapType,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.4746,
                    ),
                    onMapCreated: _onMapCreated,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    onCameraMove: _onCameraMove,
                    myLocationEnabled: true,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                  Center(
                    child: Icon(
                      Icons.location_searching,
                      size: 45,
                      color: Color(0xffff8181),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            moveMarkerToMyLocation();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            margin:
                                EdgeInsets.only(top: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff16172a),
                              border: Border.all(
                                color: Color(0xffff8181),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.my_location,
                              size: 23,
                              color: Color(0xffff8181),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _onMapTypeButtonPressed();
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            margin:
                                EdgeInsets.only(top: 10, right: 10, bottom: 10),
                            decoration: BoxDecoration(
                              color: Color(0xff16172a),
                              border: Border.all(
                                color: Color(0xffff8181),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.map,
                              size: 23,
                              color: Color(0xffff8181),
                            ),
                          ),
                        ),
                        _markers.length == 0
                            ? GestureDetector(
                                onTap: () {
                                  _onAddMarkerButtonPressed();
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  margin: EdgeInsets.only(top: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xff16172a),
                                    border: Border.all(
                                      color: Color(0xffff8181),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 23,
                                    color: Color(0xffff8181),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _markers.clear();
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  margin: EdgeInsets.only(top: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xff16172a),
                                    border: Border.all(
                                      color: Color(0xffff8181),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.location_off,
                                    size: 23,
                                    color: Color(0xffff8181),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  _isSearch
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: new ListView.builder(
                            itemCount: location == null ? 0 : location.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  moveMapCamera(location[index]['geometry']);
                                },
                                child: new Card(
                                  color: Color(0xff16172a),
                                  elevation: 1.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                        child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 10, bottom: 7.5),
                                            child: new Text(
                                                location[index]
                                                    ["formatted_address"],
                                                style: TextStyle(
                                                    color: Color(0xffcccccc),
                                                    fontSize: 14))),
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 7.5, bottom: 10),
                                            child: fetchLatLong(
                                                location[index]['geometry'])),
                                      ],
                                    )),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _markers.length == 0
                        ? GestureDetector(
                            onTap: () {
                              // upload either the location selected or current location to firebase
                              print(_markers.length);
                              // addStoreLocation();
                              // navigator pop
                              // Navigator.pop(context);
                              _onAddMarkerButtonPressed();
                            },
                            child: bottombtn(
                                Color(0xffff8181),
                                Color(0xffe1e1e1),
                                'Select',
                                MediaQuery.of(context).size.width * 0.5,
                                true,
                                false,
                                false),
                          )
                        : GestureDetector(
                            onTap: () {
                              // upload either the location selected or current location to firebase
                              print(_markers.length);

                              addStoreLocation();
                              // navigator pop
                            },
                            child: bottombtn(
                                Color(0xffff8181),
                                Color(0xffe1e1e1),
                                'Done',
                                MediaQuery.of(context).size.width * 0.5,
                                true,
                                false,
                                false),
                          ),
                  ),
                ]),
              ),
      ),
    );
  }
}
