import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final userid;
  const OrderTab({Key key, @required this.userid}) : super(key: key);
  @override
  _OrderTabState createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  int orderSelected;
  @override
  void initState() {
    super.initState();
    orderSelected = 0;
  }

  clicked(numb) {
    setState(() {
      orderSelected = numb;
    });
  }

  receivedOrdersBtn() {
    if (orderSelected == 0) {
      return orderBtn(
          context, 'Received', Color(0xffe6f1ff), Color(0xffff8181));
    } else {
      return GestureDetector(
        child: orderBtnInactive(
            context, 'Received', Color(0xffff8181), Color(0xffff8181)),
        onTap: () {
          clicked(0);
          print('clicked');
        },
      );
    }
  }

  processingOrdersBtn() {
    if (orderSelected == 1) {
      return orderBtn(
          context, 'Processing', Color(0xffe6f1ff), Color(0xffff8181));
    } else {
      return orderBtnInactive(
          context, 'Processing', Color(0xffff8181), Color(0xffff8181));
    }
  }

  completedOrdersBtn() {
    if (orderSelected == 2) {
      return orderBtn(
        context,
        'Complete',
        Color(0xffe6f1ff),
        Color(0xffff8181),
      );
    } else {
      return orderBtnInactive(
        context,
        'Complete',
        Color(0xffff8181),
        Color(0xffff8181),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: orderSelected == 0
                ? Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    // child: OrderList(status: '0'),
                    child: ListView(
                      children: [
                        GestureDetector(
                          child: OrderCard(),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderDetails()));
                          },
                        ),
                        OrderCard(),
                        OrderCard(),
                      ],
                    ),
                  )
                : orderSelected == 1
                    ? Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        // child: OrderList(status: '1'),
                        child: ListView(
                          children: [
                            GestureDetector(
                              child: OrderCard(),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderDetails()));
                              },
                            ),
                            OrderCard(),
                            OrderCard(),
                          ],
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        // child: WebMessage(),
                        child: ListView(
                          children: [
                            GestureDetector(
                              child: OrderCard(),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderDetails()));
                              },
                            ),
                            OrderCard(),
                            OrderCard(),
                          ],
                        ),
                      ),
          ),
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
