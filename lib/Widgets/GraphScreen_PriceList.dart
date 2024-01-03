// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// String selectedwoolforgraph= 'Angora Wool';
// class WoolPriceListWidget extends StatefulWidget {
//   @override
//   State<WoolPriceListWidget> createState() => _WoolPriceListWidgetState();
// }
//
// class _WoolPriceListWidgetState extends State<WoolPriceListWidget> {
//   final CollectionReference woolCollection =
//   FirebaseFirestore.instance.collection('wool');
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: woolCollection.snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'),
//           );
//         }
//
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//
//         List<Future<DocumentSnapshot>> futureList = snapshot.data!.docs.map((DocumentSnapshot document) {
//           String woolName = document.id;
//           List<String> timestamps =
//           List<String>.from(document['timestamps']);
//           String latestTimestamp = timestamps.last;
//
//           return woolCollection
//               .doc(woolName)
//               .collection('pricemap')
//               .doc(latestTimestamp)
//               .get();
//         }).toList();
//
//         return FutureBuilder(
//           future: Future.wait(futureList),
//           builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             }
//
//             List<ListTile> tiles = [];
//
//             for (int i = 0; i < snapshot.data!.length; i++) {
//               String woolName = snapshot.data![i].reference.parent.parent!.id;
//               Map<String, dynamic> latestPriceData = snapshot.data![i].data() as Map<String, dynamic>;
//               String latestPrice = latestPriceData['price'].toString();
//               var latestTime = latestPriceData['time'];
//               DateTime dateTime = DateTime.parse(latestTime);
//
//               String formattedDate = DateFormat('d MMM').format(dateTime);
//               String formattedTime = DateFormat.jm().format(dateTime);
//
//               String formattedString = '$formattedDate at $formattedTime';
//
//               tiles.add(
//                 ListTile(
//                   onTap: (){
//
//                     setState(() {
//                       selectedwoolforgraph=woolName;
//
//                     });
//
//
//                   },
//
//
//                   title: Text(woolName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: MediaQuery.devicePixelRatioOf(context)*6),),
//                   trailing: Text('₹$latestPrice',style: TextStyle(fontWeight: FontWeight.bold,fontSize: MediaQuery.devicePixelRatioOf(context)*7),),
//                   subtitle: Text('$formattedString'),
//                 ),
//               );
//             }
//
//             return ListView(
//               children: tiles,
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
