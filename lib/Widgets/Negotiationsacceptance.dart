import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:woolify/Widgets/allnotifications.dart';

import '../main.dart';

class NegotiationsAcceptance extends StatefulWidget {
  const NegotiationsAcceptance({super.key});

  @override
  State<NegotiationsAcceptance> createState() => _NegotiationsAcceptanceState();
}

class _NegotiationsAcceptanceState extends State<NegotiationsAcceptance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Negotiation Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userid) // Replace with actual sellerId
            .collection('negotiations')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              Map<String, dynamic> timestamps = data['Timestamp'];
              String timestamp = document.id;
              int actualamount = timestamps['actualPrice']; // Access amount from timestamps map
              int negotiatedamount = timestamps['negotiatedPrice']; // Access amount from timestamps map
              int actualquantity = timestamps['actualQuantity']; // Access amount from timestamps map
              int adjustedquantity = timestamps['adjustedQuantity']; // Access amount from timestamps map
              int negotiatedquantity = timestamps['actualPrice']; // Access amount from timestamps map
              String woolType = timestamps['woolType']; // Access woolType from timestamps map
              String buyermail = timestamps['buyerName']; // Access woolType from timestamps map
              String buyerid = timestamps['buyerId']; // Access woolType from timestamps map
              Timestamp time = timestamps['time']; // Access woolType from timestamps map

              return Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.01),
                child: Card(
                  child: Column(
                    children: [

                      ListTile(
                        title:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(CupertinoIcons.question_diamond_fill),
                                Text('  $woolType'),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                            Row(
                              children: [
                                Icon(CupertinoIcons.calendar_circle_fill),
                                Text('  ${convertTimestampToTime(time)}'),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                            Row(
                              children: [
                                Icon(Icons.mail),
                                Expanded(child: Text('  $buyermail',style: TextStyle(overflow: TextOverflow.ellipsis),)),
                              ],
                            ),


                            SizedBox(height: MediaQuery.of(context).size.height*0.04,),

                          ],
                        ),

                        subtitle: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Text(''),
                                SizedBox(width: MediaQuery.of(context).size.width*0.33,),

                                Text('Actual',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(width: MediaQuery.of(context).size.width*0.15,),

                                Text('Negotiated',style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                SizedBox(width: MediaQuery.of(context).size.width*0.05,),

                                Text('Amount:'),
                                SizedBox(width: MediaQuery.of(context).size.width*0.15,),

                                Text('₹${actualamount.toString()}'),
                                SizedBox(width: MediaQuery.of(context).size.width*0.15,),

                                Text('₹${negotiatedamount.toString()}'),
                              ],
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  SizedBox(width: MediaQuery.of(context).size.width*0.05,),

                                  Text('Quantity:'),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.15,),

                                  Text('${actualquantity.toString()} Kg'),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.15,),

                                  Text('${adjustedquantity.toString()} Kg'),
                                ],
                              ),

                          ],
                        ),

                        // Add more fields as needed
                      ),


                // Center(
                // child: Table(
                // border: TableBorder.all(), // Add a border around the table
                // children: [
                // TableRow(
                // children: [
                // TableCell(child: Center(child: Text('Amount'))),
                // TableCell(child: Center(child: Text('Quantity'))),
                // ],
                // ),
                // TableRow(
                // children: [
                // TableCell(child: Center(child: Text('Row 1, Cell 1'))),
                // TableCell(child: Center(child: Text('Row 1, Cell 2'))),
                // ],
                // ),
                //   TableRow(
                // children: [
                // TableCell(child: Center(child: Text('Row 1, Cell 1'))),
                // TableCell(child: Center(child: Text('Row 1, Cell 2'))),
                // ],
                // ),
                //
                // ],
                // )),



                      Container(
                        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: MediaQuery.of(context).size.width*0.05,),

                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red
                                      ,foregroundColor: Colors.white
                                  ),
                                  onPressed: (){

                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userid) // Replace with actual sellerId
                                        .collection('negotiations')
                                        .doc(buyerid) // Assuming document.id is the negotiation document's ID
                                        .delete();
                                    // deleteOrder(sellWoolDocId, data['orderid']);
                                  }, child: Text('Reject')),
                            ),

                            SizedBox(width: MediaQuery.of(context).size.width*0.1,),



                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black
                                      ,foregroundColor: Colors.white
                                  ),
                                  onPressed: (){
                                    // deleteOrder(sellWoolDocId, data['orderid']);
                                  }, child: Text('Accept')),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.05,),

                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
