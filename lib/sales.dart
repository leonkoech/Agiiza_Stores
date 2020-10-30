import 'package:flutter/material.dart';
import 'main.dart';

class SalesTab extends StatefulWidget {
  @override
  _SalesTabState createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      // child: Stats(),
      child: ListView(
        children: [
          StatsCard(
              maintitle: 'Lifetime Stats',
              ordersReceived: 0,
              amountEarned: 0,
              bottlesSold: 0,
              ordersCompleted: 0),
          StatsCard(
              maintitle: 'Today',
              ordersReceived: 0,
              amountEarned: 0,
              bottlesSold: 0,
              ordersCompleted: 0),
          StatsCard(
              maintitle: 'This Week',
              ordersReceived: 0,
              amountEarned: 0,
              bottlesSold: 0,
              ordersCompleted: 0),
          StatsCard(
              maintitle: 'This Month',
              ordersReceived: 0,
              amountEarned: 0,
              bottlesSold: 0,
              ordersCompleted: 0),
          SizedBox(height: 20)
        ],
      ),
    );
  }
}
