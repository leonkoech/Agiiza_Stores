import 'dart:io';

import 'package:agiiza_stores/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'location.dart';
import 'events.dart';
import 'store.dart';
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

class OrderTab extends StatefulWidget {
  @override
  _OrderTabState createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  int orderSelected;
  FirebaseAuth auth = FirebaseAuth.instance;
  var storeId;
  @override
  void initState() {
    super.initState();
    orderSelected = 0;

    final User user = auth.currentUser;

    storeId = user.uid;
  }

  clicked(numb) {
    setState(() {
      orderSelected = numb;
    });
  }

  fetchImageUrl(liquorId) async {
    await FirebaseFirestore.instance
        .collection('Liquors')
        .where('liquorId', isEqualTo: liquorId)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        return value.docs[0].data()['imageUrl'];
      }
    });
  }

  fetchLiquorName(liquorId) async {
    await FirebaseFirestore.instance
        .collection('Liquors')
        .where('liquorId', isEqualTo: liquorId)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        return value.docs[0].data()['liquorName'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                // child: OrderList(status: '0'),
                child: StreamBuilder<QuerySnapshot>(
                  stream: orderSelected == 0
                      ? FirebaseFirestore.instance
                          .collection('Orders')
                          .where('storeId', isEqualTo: storeId)
                          .where('statusCode', isEqualTo: 0)
                          .orderBy('orderPlaced', descending: true)
                          .snapshots()
                      : orderSelected == 1
                          ? FirebaseFirestore.instance
                              .collection('Orders')
                              .where('storeId', isEqualTo: storeId)
                              .where('statusCode', isGreaterThanOrEqualTo: 1)
                              .where('statusCode', isLessThanOrEqualTo: 2)
                              .orderBy('orderPlaced', descending: true)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection('Orders')
                              .where('storeId', isEqualTo: storeId)
                              .where('statusCode', isGreaterThanOrEqualTo: 3)
                              .orderBy('orderPlaced', descending: true)
                              .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    if (!snapshot.hasData)
                      return Center(
                          child: new Text(
                        'No Orders Made yet',
                        textAlign: TextAlign.center,
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
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 68.0),
                          child: new ListView(
                            scrollDirection: Axis.vertical,
                            children: snapshot.data.docs
                                .map((DocumentSnapshot document) {
                              if (snapshot.data.docs != null) {
                                return OrderCard(
                                  customerName: document.data()['contactName'],
                                  dateTime: document.data()['orderPlaced'],
                                  liquorId: document.data()['liquorId'],
                                  orderId: document.data()['orderId'],
                                  statusCode: document.data()['statusCode'],
                                  amountSpent:
                                      document.data()['totalAmount'].toString(),
                                  orderedItems:
                                      document.data()['totalQty'].toString(),
                                  imageUrl: document.data()['imageUrl'],
                                  liquorName: document.data()['liquorName'],
                                  liquorVlm: document.data()['liquorQty'],
                                  storeName: document.data()['storeName'],
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
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              color: Color(0xff16172A),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  orderSelected == 0
                      ? orderBtn(context, 'Placed', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Placed',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(0);
                            print('Placed');
                          },
                        ),
                  orderSelected == 1
                      ? orderBtn(context, 'Dispatched', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Dispatched',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(1);
                            print('Dipoatched');
                          },
                        ),
                  orderSelected == 2
                      ? orderBtn(context, 'Delivered', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Delivered',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(2);
                            print('Delivered');
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// appbar(context, btn1, btn2, btn3) {
//   return
// }

orderBtn(context, text, txtcolor, bgcolor) {
  return Container(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.28,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Center(
          child: Text(
        text,
        style: TextStyle(fontSize: 10, color: Color(0xffe6f1ff)),
      )));
}

orderBtnInactive(context, text, txtcolor, bgcolor) {
  return Container(
    height: 40,
    width: MediaQuery.of(context).size.width * 0.28,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: bgcolor,
      ),
      borderRadius: BorderRadius.circular(6.0),
    ),
    child: Center(
        child: Text(text, style: TextStyle(fontSize: 10, color: txtcolor))),
  );
}

class OrderCard extends StatefulWidget {
  final customerName,
      dateTime,
      liquorId,
      orderId,
      statusCode,
      amountSpent,
      storeName,
      liquorName,
      liquorVlm,
      orderedItems,
      imageUrl;
  const OrderCard(
      {Key key,
      this.customerName,
      this.dateTime,
      this.liquorId,
      this.orderId,
      this.statusCode,
      this.amountSpent,
      this.orderedItems,
      this.imageUrl,
      this.liquorName,
      this.liquorVlm,
      this.storeName})
      : super(key: key);
  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  var imageUrl, _orderDate, _orderTime;

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
  }

  fetchImageUrl() async {
    await FirebaseFirestore.instance
        .collection('Liquors')
        .where('liquorId', isEqualTo: widget.liquorId)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        setState(() {
          imageUrl = value.docs[0].data()['imageUrl'];
          DateTime myDateTime = (widget.dateTime).toDate();
          _orderDate = DateFormat.yMMMd().format(myDateTime).toString();
          _orderTime = DateFormat.jm().format(myDateTime).toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetails(
                      orderId: widget.orderId,
                    )));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xfff4f4f4),
          ),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          // this color will be determined by an order's state.ie, processing, cancelled, completed, received
          //  light red - #ffe6e6
          // light blue - #e6f1ff
          // light yellow - #fffde6
          // light green - #e7ffe6
          color: Colors.transparent,
        ),
        margin: EdgeInsets.only(top: 10, bottom: 10),
        padding: EdgeInsets.all(15),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                widget.orderId,
                style: TextStyle(
                    color: Color(0xfff4f4f4),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                  DateFormat.yMMMd()
                      .format(
                          DateTime.parse(widget.dateTime.toDate().toString()))
                      .toString(),
                  style: TextStyle(
                    color: Color(0xfff4f4f4),
                    fontSize: 12,
                  )),
              Text(
                  DateFormat.jm()
                      .format(
                          DateTime.parse(widget.dateTime.toDate().toString()))
                      .toString(),
                  style: TextStyle(
                    color: Color(0xfff4f4f4),
                    fontSize: 12,
                  )),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: widget.imageUrl != null
                    ? Image.network(widget.imageUrl,
                        fit: BoxFit.cover, height: 120, width: 100)
                    : Container(),
              ),
              Column(
                // crossAxisAlignment: Cro,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Ordered Items',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(widget.orderedItems,
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Amount',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(widget.amountSpent + ' Kes',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Store Name',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(widget.storeName,
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Liquor Name',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(widget.liquorName,
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Quantity',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(widget.liquorVlm.toString() + ' ml',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Status',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                        Text(
                            widget.statusCode == 0
                                ? 'Order Placed'
                                : widget.statusCode == 1
                                    ? 'Processing'
                                    : widget.statusCode == 2
                                        ? 'Dispatched'
                                        : widget.statusCode == 3
                                            ? 'Delivered'
                                            : widget.statusCode == 4
                                                ? 'Cancelled by Customer'
                                                : 'Cancelled by Store',
                            style: TextStyle(
                              color: Color(0xfff4f4f4),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }
}

class OrderDetails extends StatefulWidget {
  final orderId;
  const OrderDetails({Key key, this.orderId}) : super(key: key);
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  GoogleMapController _controller;
  final Set<Marker> _markers = {};
  bool _isLoading;
  var _orderDate,
      _orderTime,
      _customerName,
      _orderLocation,
      _timeStamp,
      _imageUrl,
      _liquorId,
      _liquorName,
      _liquorVolume,
      _liquorPrice,
      _customerPhone,
      _liquorQty,
      _totalAmt,
      _orderStatus;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  _onMapCreated(GoogleMapController controller1) {
    _controller = controller1;
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("0"),
          position: LatLng(convertToDouble(_orderLocation, 0),
              convertToDouble(_orderLocation, 1)),
          infoWindow: InfoWindow(
              title: 'Delivery Location',
              snippet: 'This is the Selected Delivery Location')));
    });
    _setMapStyle();
  }

  _setMapStyle() async {
    String style =
        await DefaultAssetBundle.of(context).loadString('assets/mapstyle.json');
    _controller.setMapStyle(style);
  }

  _orderMap() {
    return GoogleMap(
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(convertToDouble(_orderLocation, 0),
              convertToDouble(_orderLocation, 1)),
          zoom: 14.4746,
        ),
        onMapCreated: _onMapCreated,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        // onCameraMove: _onCameraMove,
        myLocationEnabled: true,
        compassEnabled: false,
        myLocationButtonEnabled: false,
        onTap: (_) {
         });
  }

  convertToDouble(lat, step) {
    lat = lat.replaceAll('LatLng', '');
    lat = lat.replaceAll('(', '');
    lat = lat.replaceAll(')', '');
    lat.split(',');

    // turn this string to double
    return double.parse(lat.split(',')[step]);
  }

  fetchOrderDetails() {
    _isLoading = true;
    FirebaseFirestore.instance
        .collection('Orders')
        .where('orderId', isEqualTo: widget.orderId)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        setState(() {
          _customerName = value.docs[0].data()['contactName'];
          _customerPhone = value.docs[0].data()['phoneNumber'];
          _orderLocation = value.docs[0].data()['location'];
          _timeStamp = value.docs[0].data()['orderPlaced'];
          _liquorId = value.docs[0].data()['liquorId'];
          _liquorQty = value.docs[0].data()['totalQty'];
          _totalAmt = value.docs[0].data()['totalAmount'];
          _orderStatus = value.docs[0].data()['statusCode'];
           _imageUrl = value.docs[0].data()['imageUrl'];
          _liquorName = value.docs[0].data()['liquorName'];
          _liquorPrice = value.docs[0].data()['liquorPrice'];
          _liquorVolume = value.docs[0].data()['liquorQty'];
          _isLoading = false;
        });

        DateTime myDateTime = (_timeStamp).toDate();
        _orderDate = DateFormat.yMMMd().format(myDateTime).toString();
        _orderTime = DateFormat.jm().format(myDateTime).toString();

        // fetchLiquorDetails();
      }
    });
  }

  fetchLiquorDetails() {
    _isLoading = true;
    FirebaseFirestore.instance
        .collection('Liquor')
        .where('docId', isEqualTo: _liquorId)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        setState(() {
          _imageUrl = value.docs[0].data()['contactName'];
          _liquorName = value.docs[0].data()['liquorName'];
          _liquorPrice = value.docs[0].data()['liquorPrice'];
          _liquorVolume = value.docs[0].data()['liquorVolume'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?
        Scaffold(
          body:Center(
            child: SpinKitChasingDots(
              color: Color(0xffff8181),
              size: 50.0,
              duration: Duration(milliseconds: 2000),
            )
          )
        )
        :Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(widget.orderId,
            style: TextStyle(
                color: Color(0xfff4f4f4),
                fontSize: 30,
                fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                    DateFormat.yMMMd()
                        .format(DateTime.parse(_timeStamp.toDate().toString()))
                        .toString(),
                    style: TextStyle(
                      color: Color(0x4fe1e1e1),
                      fontSize: 15,
                    )),
                Text(
                    DateFormat.jm()
                        .format(DateTime.parse(_timeStamp.toDate().toString()))
                        .toString(),
                    style: TextStyle(
                      color: Color(0x4fe1e1e1),
                      fontSize: 15,
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Order Status',
                  style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [

                Text(
                    _orderStatus == 0
                        ? 'Order Placed'
                        : _orderStatus == 1
                            ? 'Processing'
                            : _orderStatus == 2
                                ? 'Dispatched'
                                : _orderStatus == 3
                                    ? 'Delivered'
                                    : _orderStatus == 4
                                        ? 'Cancelled by Customer'
                                        : 'Cancelled by Store',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                    )),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return OrderStatusPopup(
                              status: _orderStatus,
                              orderId: widget.orderId,
                              width: MediaQuery.of(context).size.width * 0.91);
                        });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffff8181),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text('Change status',
                            style: TextStyle(
                              color: Color(0xffe1e1e1),
                              fontSize: 13,
                            )),
                      )),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Order Details',
                  style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(_customerName,
                    style: TextStyle(
                        color: Color(0xffe1e1e1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    showAlertDialog(context, _customerPhone, 0);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffff8181)),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text('Contact',
                            style: TextStyle(
                              color: Color(0xffff8181),
                              fontSize: 13,
                            )),
                      )),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Phone Number',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
                Text(_customerPhone,
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Ordered Items',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
                Text(_liquorQty.toString(),
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Amount',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
                Text(_totalAmt.toString() + ' KES',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Liquor Ordered',
                  style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    top: BorderSide(width: 1.0, color: Color(0xffe1e1e1)),
                    bottom: BorderSide(width: 1.0, color: Color(0xffe1e1e1)),
                  ),
                ),
                child: Column(
                  children: [
                    orderListItem(context, _liquorName, _liquorQty.toString(),
                        _liquorVolume.toString(), _liquorPrice.toString(),),
                  ],
                )),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(_customerName,
                    style: TextStyle(
                        color: Color(0xffe1e1e1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderRoutingMap(
                              orderLocation: LatLng(
                                  convertToDouble(_orderLocation, 0),
                                  convertToDouble(_orderLocation, 1)),
                      )));
        

                  },
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffff8181)),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text('View Location',
                            style: TextStyle(
                              color: Color(0xffff8181),
                              fontSize: 13,
                            )),
                      )),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: Color(0xffe1e1e1),
                ),
                height: 140,
                width: MediaQuery.of(context).size.width - 20,
                child: _orderMap(),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget orderListItem(context, liquorname, qty, litres, price) {
  return Container(
    margin: EdgeInsets.only(top: 10, bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(liquorname,
              style: TextStyle(
                color: Color(0xffe1e1e1),
                fontSize: 15,
              )),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Center(
            child: Text(qty,
                style: TextStyle(
                  color: Color(0xffe1e1e1),
                  fontSize: 15,
                )),
          ),
        ),
        Text(litres + " ml",
            style: TextStyle(
              color: Color(0xffe1e1e1),
              fontSize: 15,
            )),
        Text(price + " KES",
            style: TextStyle(
              color: Color(0xffe1e1e1),
              fontSize: 15,
            )),
      ],
    ),
  );
}

class OrderStatusPopup extends StatefulWidget {
  final int status;
  final double width;
  final orderId;
  const OrderStatusPopup({Key key, @required this.status, @required this.width,@required this.orderId})
      : super(key: key);
  @override
  _OrderStatusPopupState createState() => _OrderStatusPopupState();
}

class _OrderStatusPopupState extends State<OrderStatusPopup> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      backgroundColor: Color(0xff16172a),
      elevation: 10,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        width: widget.width,
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Order number",
              style: TextStyle(
                  fontSize: 30,
                  color: Color(0xffe1e1e1),
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Change Order Status",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0x9fe1e1e1)),
            ),
            GestureDetector(
              onTap: () => setState(() => _value = 0),
              child: Container(
                height: 56,
                width: widget.width,
                decoration: BoxDecoration(
                  color: _value == 0 ? Color(0xffffea81) : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                      color:
                          _value == 0 ? Color(0xffffea81) : Color(0xfff4f4f4),
                      width: 1.0),
                ),
                child: Center(
                    child: Text('Received',
                        style: TextStyle(
                            color: _value == 0
                                ? Color(0xff16172a)
                                : Color(0xfff4f4f4)))),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _value = 2),
              child: Container(
                height: 56,
                width: widget.width,
                decoration: BoxDecoration(
                  color: _value == 2 ? Color(0xff81c6ff) : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                      color:
                          _value == 2 ? Color(0xff81c6ff) : Color(0xfff4f4f4),
                      width: 1.0),
                ),
                child: Center(
                    child: Text('Processing',
                        style: TextStyle(color: Color(0xfff4f4f4)))),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _value = 1),
              child: Container(
                height: 56,
                width: widget.width,
                decoration: BoxDecoration(
                  color: _value == 1 ? Color(0xff92ff81) : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                      color:
                          _value == 1 ? Color(0xff92ff81) : Color(0xfff4f4f4),
                      width: 1.0),
                ),
                child: Center(
                    child: Text('Completed',
                        style: TextStyle(
                            color: _value == 1
                                ? Color(0xff16172a)
                                : Color(0xfff4f4f4)))),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _value = 3),
              child: Container(
                height: 56,
                width: widget.width,
                decoration: BoxDecoration(
                  color: _value == 3 ? Color(0xffff8181) : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                      color:
                          _value == 3 ? Color(0xffff8181) : Color(0xfff4f4f4),
                      width: 1.0),
                ),
                child: Center(
                    child: Text('Cancelled',
                        style: TextStyle(color: Color(0xfff4f4f4)))),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Color(0xfff4f4f4), fontSize: 12))),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Color(0xffff8181)),
                  child: Center(
                      child: Text('Confirm',
                          style: TextStyle(
                              color: Color(0xfff4f4f4), fontSize: 12))),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
