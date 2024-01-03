import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

String convertTimestampToTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  DateTime currentDate = DateTime.now();
  DateTime previousDate = currentDate.subtract(Duration(days: 1));

  if (dateTime.year == currentDate.year && dateTime.month == currentDate.month && dateTime.day == currentDate.day) {
    DateFormat outputFormat = DateFormat("h:mm a");
    String formattedTime = outputFormat.format(dateTime);
    return formattedTime;
  } else if (dateTime.year == previousDate.year && dateTime.month == previousDate.month && dateTime.day == previousDate.day) {
    return "Yesterday";
  } else {
    DateFormat outputFormat = DateFormat("h:mm a, d MMMM yyyy");
    String formattedTime = outputFormat.format(dateTime);
    return formattedTime;
  }
}

class AllNotifications extends StatefulWidget {
  const AllNotifications({super.key});

  @override
  State<AllNotifications> createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Container(child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userid).collection('notifications').orderBy('timestamp', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // or a loading indicator
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: Column(

                  children: [
                    ListTile(
                      title:  data['type']=='nego'?Text('Negotiation request',style: TextStyle(fontWeight: FontWeight.w500)):data['type']=='buycon'?Text('Order Placed',style: TextStyle(fontWeight: FontWeight.w500)):data['type']=='sellcon'?Text('Item updated to market',style: TextStyle(fontWeight: FontWeight.w500),):Text('Notification',style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Column(
                        children: [
                          data['type']=='buycon'?Text('Order for ${data['wooltype']} has been placed',style: TextStyle(color: Colors.grey)):data['type']=='sellcon'?Text('${data['wooltype']} for amount ₹${data['amount']} for ${data['quantity']}Kg has been updated to market',style: TextStyle(color: Colors.grey)):Text('${data['name']} has requested to negotiate price of ${data['wooltype']}',style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      // Add more information as needed

                      trailing: Text('${convertTimestampToTime(data['timestamp'])}'),
                    ),
                    Divider(),
                    // Divider(),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),),
    );
  }
}