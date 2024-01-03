import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woolify/Widgets/GraphScreen_PriceList.dart';

import '../main.dart';

class SellOrders extends StatefulWidget {
  const SellOrders({super.key});

  @override
  State<SellOrders> createState() => _SellOrdersState();
}

class _SellOrdersState extends State<SellOrders> {


  Stream<QuerySnapshot> getSellWoolStream() {
    return FirebaseFirestore.instance.collection('sellwool').where('sellerid', isEqualTo: userid).snapshots();
  }

  Stream<QuerySnapshot> getOrdersStream(String sellWoolDocId) {
    return FirebaseFirestore.instance.collection('sellwool').doc(sellWoolDocId).collection('orders').snapshots();
  }



  Future<void> deleteOrder(String sellWoolDocId, String orderId) async {
    await FirebaseFirestore.instance
        .collection('sellwool')
        .doc(sellWoolDocId)
        .collection('orders')
        .doc(orderId)
        .delete();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Items to sell'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getSellWoolStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot sellWoolDoc) {
              String sellWoolDocId = sellWoolDoc.id;

              return StreamBuilder<QuerySnapshot>(
                stream: getOrdersStream(sellWoolDocId),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> ordersSnapshot) {
                  if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // or any loading widget
                  }

                  if (ordersSnapshot.hasError) {
                    return Text('Error: ${ordersSnapshot.error}');
                  }

                  return Column(
                    children: ordersSnapshot.data!.docs.map((DocumentSnapshot orderDoc) {
                      Map<String, dynamic> data = orderDoc.data() as Map<String, dynamic>;
                      return Container(
                        width: double.infinity,
                        // padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05, horizontal: MediaQuery.of(context).size.width*0.04), // Adjust the margins as needed
                        child: GestureDetector(
                          onTap: (){

                          },
                          child: Card(
                            // elevation: 3, // Adjust the elevation as per your preference
                            margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width*0.06,vertical: MediaQuery.of(context).size.width*0.03,), // Adjust the margins as needed
                            child: Column(
                              children: [
                                Container(
                                    margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.03), // Adjust the margins as needed

                                    child: ListTile(
                                      title: Text('${data['typeofwool']}'),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text('₹${data['amount']}',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04),),
                                          Text('${data['quantity']} Kg',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.03)),
                                        ],
                                      ),
                                      selectedTileColor: Colors.black87,
                                      leading:  data['org']=='gov'?Image.asset('assets/images/lionindia.png',height: MediaQuery.of(context).size.width*0.07):Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset('assets/images/user.png',height: MediaQuery.of(context).size.width*0.07),
                                        ],
                                      ),

                                      subtitle: Container(
                                        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.03),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                // Icon(Icons.location_on_outlined,color: Colors.blueGrey,),
                                                data['city']==null?Expanded(child: Text('Not Specified')):Expanded(child: Text('${data['city']}',style: TextStyle(color:  Colors.blueGrey,overflow: TextOverflow.clip),)),

                                              ],
                                            ),

                                            data['ispricenego']?Text('Negotiable Price',style: TextStyle(color: Colors.green),):Text('Non Negotiable Price',style: TextStyle(color: Colors.red),)

                                            ,
                                            // SizedBox(height: MediaQuery.of(context).size.height*0.03,),


                                          ],),
                                      ),
                                    )
                                ),

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
                                          deleteOrder(sellWoolDocId, data['orderid']);
                                        }, child: Text('Delete Item')),
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
                                            }, child: Text('Edit Details')),
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width*0.05,),

                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),

    );
  }
}




class BuyOrders extends StatefulWidget {
  const BuyOrders({super.key});

  @override
  State<BuyOrders> createState() => _BuyOrdersState();
}

class _BuyOrdersState extends State<BuyOrders> {

  Stream<QuerySnapshot> getBuyWoolStream() {
    return FirebaseFirestore.instance.collection('buywool').doc(userid).collection('orders').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getBuyWoolStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot buyOrderDoc) {
              Map<String, dynamic> data = buyOrderDoc.data() as Map<String, dynamic>;
              return Container(
                width: double.infinity,
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.03),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('${data['typeofwool']}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('₹${data['amount']}', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04)),
                            Text('${data['quantity']} Kg', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03)),
                          ],
                        ),
                        leading: Image.asset('assets/images/user.png', height: MediaQuery.of(context).size.width * 0.07),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('${data['city']}', style: TextStyle(color: Colors.blueGrey, overflow: TextOverflow.clip))),
                              ],
                            ),
                            data['ispricenego'] ? Text('Negotiable Price', style: TextStyle(color: Colors.green)) : Text('Non Negotiable Price', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),

                      SizedBox(width: MediaQuery.of(context).size.width*0.1,),



                      Container(
                        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.03),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black
                                    ,foregroundColor: Colors.white
                                ),
                                onPressed: (){
                                  // deleteOrder(sellWoolDocId, data['orderid']);
                                }, child: Text('See Details')),

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
