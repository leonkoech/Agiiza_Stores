import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'currentlocation.dart';
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
                  stream:  //orders received and not processed yet
                       FirebaseFirestore.instance
                          .collection('Orders')
                          .where('storeId', isEqualTo: storeId)
                          .where('status', isEqualTo: orderSelected)
                          .orderBy('timeStamp', descending: false)
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
                              const EdgeInsets.only(top: 68.0, bottom: 68.0),
                          child: new ListView(
                            scrollDirection: Axis.vertical,
                            children: snapshot.data.docs
                                .map((DocumentSnapshot document) {
                              if (snapshot.data.docs != null) {
                                return OrderCard(
                                  customerName: document.data()['contactName'],
                                  dateTime: document.data()['timestamp'],
                                  imageUrl: fetchImageUrl( document.data()['liquorId']),
                                  orderId: document.data()['orderId'],
                                  statusCode: document.data()['statusCode'],
                                  amountSpent: document.data()['totalAmount'],
                                  orderedItems: document.data()['liquorId'],
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
                      ? orderBtn(context, 'Received', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Received',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(0);
                            print('received');
                          },
                        ),
                  orderSelected == 1
                      ? orderBtn(context, 'Processing', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Processing',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(1);
                            print('Processing');
                          },
                        ),
                  orderSelected == 2 
                      ? orderBtn(context, 'Completed', Color(0xffe6f1ff),
                          Color(0xffff8181))
                      : GestureDetector(
                          child: orderBtnInactive(context, 'Completed',
                              Color(0xffff8181), Color(0xffff8181)),
                          onTap: () {
                            clicked(2);
                            print('Completed');
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

class OrderCard extends StatelessWidget {
  final customerName,
      dateTime,
      imageUrl,
      orderId,
      statusCode,
      amountSpent,
      orderedItems;
  const OrderCard({
    Key key,
    @required this.customerName,
    @required this.dateTime,
    @required this.imageUrl,
    @required this.orderId,
    @required this.statusCode,
    @required this.amountSpent,
    @required this.orderedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              orderId,
              style: TextStyle(
                  color: Color(0xff16172a),
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
            Text('12:33 am',
                style: TextStyle(
                  color: Color(0x3f16172a),
                  fontSize: 12,
                )),
            Text('09/09/2020',
                style: TextStyle(
                  color: Color(0x3f16172a),
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
                child: Image.network(imageUrl, height: 40, width: 40)),
            Flex(
              direction: Axis.horizontal,
              children: [
                Column(
                  children: [
                    Text('Amount',
                        style: TextStyle(
                          color: Color(0x3f16172a),
                          fontSize: 12,
                        )),
                    Text(amountSpent.toString() + 'KES',
                        style: TextStyle(
                          color: Color(0x3f16172a),
                          fontSize: 12,
                        ))
                  ],
                ),
                Column(
                  children: [
                    Text('Quantity',
                        style: TextStyle(
                          color: Color(0x3f16172a),
                          fontSize: 12,
                        )),
                    Text(amountSpent.toString() + 'KES',
                        style: TextStyle(
                          color: Color(0x3f16172a),
                          fontSize: 12,
                        ))
                  ],
                )
              ],
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
            Text('Ordered Items',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
                )),
            Text('2',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
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
            Text('Amount',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
                )),
            Text('2,400 KES',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
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
            Text('Status',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
                )),
            Text('Received',
                style: TextStyle(
                  color: Color(0xff16172a),
                  fontSize: 13,
                )),
          ],
        ),
      ]),
    );
  }
}

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Gj5dFfhG7',
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
                Text('12:33 am',
                    style: TextStyle(
                      color: Color(0x4fe1e1e1),
                      fontSize: 15,
                    )),
                Text('09/09/2020',
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
                Text("Leon Kipkoech",
                    style: TextStyle(
                        color: Color(0xffe1e1e1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    showAlertDialog(context, '0715856246', 0);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Color(0xffff8181)),
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text('Contact',
                            style: TextStyle(
                              color: Colors.white,
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
                Text('+254712345678',
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
                Text('2',
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
                Text('2,400 KES',
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
                  'Items Ordered',
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
                    orderListItem(context, "Gilbey's gin", '2', '750'),
                    orderListItem(context, "Chrome", '1', '750'),
                    orderListItem(context, "Red Label", '1', '750'),
                  ],
                )),
            SizedBox(height: 10),
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
                Text("Status",
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
                Text('Received',
                    style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 15,
                    )),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return OrderStatusPopup(
                              status: 1,
                              width: MediaQuery.of(context).size.width * 0.91);
                        });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: Color(0xffff8181)),
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
                  'Location',
                  style: TextStyle(
                      color: Color(0xffe1e1e1),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
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
                  width: MediaQuery.of(context).size.width - 20),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
