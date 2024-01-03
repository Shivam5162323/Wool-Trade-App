import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:woolify/Screens/Sell.dart';
import 'package:woolify/Widgets/verifybuyinginfo.dart';

import '../Widgets/GraphScreen_PriceList.dart';
import '../main.dart';





String generateUniqueOrderId()  {

  // Fetch the list of order IDs for the specified user


  String randomOrderId;


  // Generate a random 11-digit number
  randomOrderId = (1000000000 + Random().nextInt(900000000)).toString();
  // Keep generating until it's unique

  return randomOrderId;
}

String capitalize(String input) {
  List<String> words = input.split(' ');
  List<String> capitalizedWords = [];

  for (String word in words) {
    String capitalizedWord = word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '';
    capitalizedWords.add(capitalizedWord);
  }

  return capitalizedWords.join(' ');
}
class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {



  Stream<QuerySnapshot> getSellWoolStream() {
    // return FirebaseFirestore.instance.collection('sellwool').snapshots();
    return FirebaseFirestore.instance.collection('sellwool').where('sellerid', isNotEqualTo: userid).snapshots();
  }

  Stream<QuerySnapshot> getOrdersStream(String sellWoolDocId) {
    return FirebaseFirestore.instance.collection('sellwool').doc(sellWoolDocId).collection('orders').snapshots();
  }









  // final address;
  //   final landmark;
  //   final state;
  //   final city;
  //   final orderid;
  //   final sellerid;
  //   final selleraddress;
  //   final sellername;


  void _openBottomSheet(String wooltype, var Amount, int quantity,String address, String state, String city, var org, var sellername, bool nego,String sellerid
      ) {





    showModalBottomSheet(


      context: context,
      builder: (_) => buynowmodalsheet(wooltype, Amount, quantity, city,state, address, org, sellername, nego, sellerid),
    );
  }



  //  _openNegoBottomSheet(data['typeofwool'], data['amount'],data['quantity']
  //       ,data['address'],data['city'],data['state'],data['org']='pr', data['name'], data['ispricenego'],data['id']);
  void _openNegoBottomSheet(String wooltype, var Amount, int quantity,String address, String city, String state, var org, var sellername, bool nego,String sellerid
      ) {




    showModalBottomSheet(
      context: context,
      builder: (_) => Negomodalsheet(wooltype, Amount, quantity, city,state, address, org, sellername, nego, sellerid),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Buy Wool'),
          centerTitle: true,
        ),
        body:StreamBuilder<QuerySnapshot>(
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
                              margin: EdgeInsets.symmetric( horizontal: MediaQuery.of(context).size.width*0.06,vertical: MediaQuery.of(context).size.width*0.03), // Adjust the margins as needed
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
                                      selectedTileColor: Colors.deepPurple,
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
                                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04, vertical:  MediaQuery.of(context).size.height*0.01),
                                    child: Row(

                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,


                                      children: [
                                        data['ispricenego']?Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black
                                                  ,
                                                  foregroundColor: Colors.white
                                              ),
                                              onPressed: (){

                                                _openNegoBottomSheet(data['typeofwool'], data['amount'],data['quantity']
                                                    ,data['address'],data['city'],data['state'],data['org'], data['name'], data['ispricenego'],data['sellerid']);




                                              }, child: Text('Negotiate',style: TextStyle(color: Colors.white),)),
                                        ):SizedBox(),
                                        data['ispricenego']?SizedBox(width:  MediaQuery.of(context).size.width*0.07,):SizedBox(),
                                        Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white

                                              ),

                                              onPressed: (){

                                                _openBottomSheet(data['typeofwool'], data['amount'],data['quantity']
                                                    ,data['address'],data['city'],
                                                    data['state'],data['org'],
                                                    data['name'], data['ispricenego'],data['sellerid']);



                                              }, child: Text('Buy Now')),
                                        )
                                      ],),
                                  )
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
        )


    );
  }
}


//Text(
//                                     'Type of Wool: ${data['typeofwool']}',
//                                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                                   ),
//                                   SizedBox(height: 8), // Add some spacing between the text elements
//                                   Text('Quantity: ${data['quantity']}'),
//                                   Text('Amount: ${data['amount']}'),
//                                   Text('Amount: ${data['city']}'),
//                                   Text('Amount: ${data['state']}'),




// class buynowmodelsheet
// BuildContext context,String wooltype, var Amount, int quantity, String city,String address, var org, var sellername, bool nego
class buynowmodalsheet extends StatefulWidget {

  final wooltype;
  final amount;
  int quantity;
  final city;
  final state;
  final address;
  final org;
  final sellername;
  final nego;
  final sellerid;
  //       builder: (_) => buynowmodalsheet(wooltype, Amount, quantity, city,state, address, org, sellername, nego, sellerid),
  buynowmodalsheet(this.wooltype,this.amount,this.quantity,this.city,this.state,this.address,this.org,this.sellername,this.nego,this.sellerid);
  @override
  State<buynowmodalsheet> createState() => _buynowmodalsheetState();
}

class _buynowmodalsheetState extends State<buynowmodalsheet> {
  late int quantityofwooltosell;
  bool paycharges=false;
  late int adjustedprice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantityofwooltosell=widget.quantity;
    adjustedprice= ((widget.amount/widget.quantity)*quantityofwooltosell).toInt();
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
        height:  MediaQuery.of(context).size.height*0.6,
        // Adjust the height as needed
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08,vertical:  MediaQuery.of(context).size.height*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Row(
                      children: [
                        widget.org=='gov'?Image.asset('assets/images/lionindia.png',height: MediaQuery.of(context).size.width*0.07):Image.asset('assets/images/user.png',height: MediaQuery.of(context).size.width*0.07),

                        widget.org=='gov'?Text('   Government Of India',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05)):Text('   ${capitalize(widget.sellername)}',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05)),
                      ],
                    ),


                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,color: Colors.blueGrey,),
                        widget.city==null?Text('  Not Specified'):Expanded(child: Text('  ${widget.address}',style: TextStyle(color:  Colors.blueGrey,overflow: TextOverflow.clip),)),

                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.03,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.wooltype,style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05),),
                        Text('₹${widget.amount.toString()}',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05))
                      ],
                    ),


                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                    Text('${widget.quantity} Kg',style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04),),

                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),











              // int priceforselectedquantity = ;

                    adjustedprice!=widget.amount?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price for Adjusted Quantity : '),
                        Text('₹${((widget.amount/widget.quantity)*quantityofwooltosell).toInt()}'),
                      ],
                    ):SizedBox(),

                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Adjust Quantity')),
                        Card(
                            elevation: 3,



                            child: Container(

                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(onPressed: (){

                                      setState(() {
                                        if(quantityofwooltosell!=0){
                                          quantityofwooltosell=quantityofwooltosell-1;
                                          // quantitytextfield.text=quantityofwooltosell.toString();
                                          adjustedprice = ((widget.amount/widget.quantity)*quantityofwooltosell).toInt();



                                        }

                                      });



                                    }, icon: Icon(CupertinoIcons.minus)),

                                    Container(
                                      alignment: Alignment.center,
                                      // margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                      width: quantityofwooltosell<10?MediaQuery.of(context).size.width*0.03:quantityofwooltosell<999?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.2,


                                      // width: quantitytextfield.text.length<8?quantitytextfield.text.length<5? quantitytextfield.text.length<2?MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.1:quantitytextfield.text.length.toDouble() *10: MediaQuery.of(context).size.width*0.2,
                                      // child: TextFormField(
                                      //   onChanged: (_){
                                      //     setState(() {
                                      //       if(quantitytextfield.text==''){
                                      //         quantitytextfield.text='0';
                                      //       }else if (quantitytextfield.text.startsWith('0') &&  quantitytextfield.text.length>1) {
                                      //         quantitytextfield.text = quantitytextfield.text.substring(1,quantitytextfield.text.length); // Clear the text field if '0' is the only input
                                      //       }
                                      //       quantityofwooltosell=int.parse(quantitytextfield.text);
                                      //       print(quantitytextfield.text);
                                      //       print(quantityofwooltosell);
                                      //     });
                                      //   },
                                      //   controller: quantitytextfield,
                                      //   keyboardType: TextInputType.number,
                                      //   textAlign: TextAlign.center,
                                      //   inputFormatters: [
                                      //     FilteringTextInputFormatter.digitsOnly,
                                      //     LengthLimitingTextInputFormatter(7), // Limit to 7 digits
                                      //   ],
                                      //
                                      //   decoration: InputDecoration(border: InputBorder.none,
                                      //
                                      //   ),
                                      //
                                      // ),
                                      child: Text(quantityofwooltosell.toString()),
                                    ),
                                    IconButton(onPressed: (){
                                      print(quantityofwooltosell);

                                      if(quantityofwooltosell<widget.quantity){
                                        setState(() {
                                          quantityofwooltosell=quantityofwooltosell+1;
                                          adjustedprice = ((widget.amount/widget.quantity)*quantityofwooltosell).toInt();


                                        });
                                      }

                                      // quantitytextfield.text=quantityofwooltosell.toString();


                                    }, icon: Icon(Icons.add),),

                                  ]
                              ),
                            )),






                      ],
                    ),





                    // Text(nego?'Negotiable Price':'Non Negotiable Price')
                  ],),

                SizedBox(height: MediaQuery.of(context).size.height*0.02,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pay Transportation Charges? '),
                      // Text('(see our transportation charges below)')
                    ],
                  ),

                  Checkbox(value: paycharges, onChanged: (_){
                    setState(() {
                      paycharges=!paycharges;
                    });
                  })
                ],),

                SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    widget.nego?TextButton(onPressed: (){







                    }, child: Text('Negotiate')):SizedBox(),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white
                        ),


                        onPressed: (){

                         if(quantityofwooltosell!=0){
                           var orderid = generateUniqueOrderId();



                           int priceforselectedquantity = ((widget.amount/widget.quantity)*quantityofwooltosell).toInt();
                           print(
                               widget.nego
                             // ,widget.wooltype,
                             // quantityofwooltosell,
                             // priceforselectedquantity,
                             // widget.address,
                             // widget.state,
                             // widget.city,
                             // orderid,
                             // widget.sellerid,
                             // widget.address,
                             // widget.sellername
                             // ,paycharges
                           );
                           Navigator.pushReplacement(
                               context, MaterialPageRoute(builder: (context) {
                             return  verifyBuyingInfo(widget.nego,widget.wooltype,quantityofwooltosell,priceforselectedquantity,widget.address,widget.state,widget.city,orderid,widget.sellerid,widget.address,widget.sellername,paycharges);
                           }));
                         }else{
                           final snackBar = SnackBar(
                             content: Text('Quantity Can\'t be Zero!!'),);


                           ScaffoldMessenger.of(context).showSnackBar(snackBar);

                         }

                        }, child: Text('Buy Now'))

                  ],)
              ],
            ),
          ),
        ),
      ),
    );
  }
}


































class Negomodalsheet extends StatefulWidget {

  final wooltype;
  final amount;
  int quantity;
  final city;
  final state;
  final address;
  final org;
  final sellername;
  final nego;
  final sellerid;

  // > Negomodalsheet(wooltype, Amount, quantity, city,state, address, org, sellername, nego, sellerid),
  Negomodalsheet(this.wooltype,this.amount,this.quantity,this.city,this.state,this.address,this.org,this.sellername,this.nego,this.sellerid);
  @override
  State<Negomodalsheet> createState() => _NegomodalsheetState();
}

class _NegomodalsheetState extends State<Negomodalsheet> {
  late int quantityofwooltosell;
  bool paycharges = false;
  late int adjustedprice;

  TextEditingController amounttextfield = TextEditingController();

  late int amountofwooltosell;



  Future<void> uploadUserData({
    // required String amount,
    required String woolType,
    required int negotiatedPrice,
    required int actualPrice,
    required int actualQuantity,
    required String sellerId,
    // required String buyerName,
    required int adjustedQuanitity,
  }) async {
    try {
      // Reference to the Firestore collection
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Reference to the user document
      DocumentReference userDocument = usersCollection.doc(sellerId);

      // Create a map with the specified data
      Map<String, dynamic> userData = {
        // 'amount': amount,
        'woolType': woolType,
        'negotiatedPrice': negotiatedPrice,
        'actualPrice': actualPrice,
        'actualQuantity': actualQuantity,
        'adjustedQuantity':adjustedQuanitity,
        'sellerId': sellerId,
        'buyerName': email,
        'buyerId': userid,
        'time':DateTime.now()

      };

      // Add the data to the user document
      await userDocument.set(userData, SetOptions(merge: true));

      // Reference to the negotiations subcollection
      CollectionReference negotiationsCollection = userDocument.collection('negotiations');

      // Reference to the document with the buyerId
      DocumentReference buyerDocument = negotiationsCollection.doc(userid);

      // Create a map with data according to timestamp (replace 'timestamp' with actual timestamp)
      Map<String, dynamic> timestampData = {
        'Timestamp': {
          // 'amount': actualPrice,
          'woolType': woolType,
          'negotiatedPrice': negotiatedPrice,
          'actualPrice': actualPrice,
          'actualQuantity': actualQuantity,
          'adjustedQuantity':adjustedQuanitity,
          'sellerId': sellerId,
          'buyerName': email,
          'buyerId':userid,
          'time':DateTime.now()
        },
      };

      // Add the timestampData to the buyer document
      await buyerDocument.set(timestampData, SetOptions(merge: true));

      print('Data uploaded successfully!');
    } catch (e) {
      print('Error uploading data: $e');
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantityofwooltosell = widget.quantity;
    amountofwooltosell = widget.amount;
    adjustedprice =
        ((widget.amount / widget.quantity) * quantityofwooltosell).toInt();
    amounttextfield =
        TextEditingController(text: amountofwooltosell.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
      height: MediaQuery
          .of(context)
          .size
          .height * 0.6,
      // Adjust the height as needed
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery
                .of(context)
                .size
                .width * 0.09, vertical: MediaQuery
                .of(context)
                .size
                .height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      Row(
                        children: [
                          widget.org == 'gov' ? Image.asset(
                              'assets/images/lionindia.png', height: MediaQuery
                              .of(context)
                              .size
                              .width * 0.07) : Image.asset(
                              'assets/images/user.png', height: MediaQuery
                              .of(context)
                              .size
                              .width * 0.07),

                          widget.org == 'gov' ? Text('   Government Of India',
                              style: TextStyle(fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.05)) : Text('   ${capitalize(widget
                              .sellername)}',
                              style: TextStyle(fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.05)),
                        ],
                      ),


                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined, color: Colors.blueGrey,),
                          widget.city == null
                              ? Text('  Not Specified')
                              : Expanded(child: Text('  ${widget.address}',
                            style: TextStyle(color: Colors.blueGrey,
                                overflow: TextOverflow.clip),)),

                        ],
                      ),

                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.03,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.wooltype, style: TextStyle(fontSize: MediaQuery
                              .of(context)
                              .size
                              .width * 0.05),),
                          Text('₹${widget.amount.toString()}',
                              style: TextStyle(fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.05))
                        ],
                      ),


                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.01,),

                      Text('${widget.quantity} Kg',
                        style: TextStyle(fontSize: MediaQuery
                            .of(context)
                            .size
                            .width * 0.04),),

                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02,),


                      // int priceforselectedquantity = ;

                      adjustedprice != widget.amount ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Actual Price for Adjusted Quantity : '),
                          Text('₹${((widget.amount / widget.quantity) *
                              quantityofwooltosell).toInt()}'),
                        ],
                      ) : SizedBox(),

                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.017,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('Adjust Quantity')),
                          Card(
                              elevation: 3,


                              child: Container(

                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      IconButton(onPressed: () {
                                        setState(() {
                                          if (quantityofwooltosell != 0) {
                                            quantityofwooltosell =
                                                quantityofwooltosell - 1;
                                            // quantitytextfield.text=quantityofwooltosell.toString();
                                            adjustedprice = ((widget.amount /
                                                widget.quantity) *
                                                quantityofwooltosell).toInt();

                                            amountofwooltosell = adjustedprice;
                                            amounttextfield.text =
                                                adjustedprice.toString();
                                          }
                                        });
                                      }, icon: Icon(CupertinoIcons.minus)),

                                      Container(
                                        alignment: Alignment.center,
                                        // margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                        width: quantityofwooltosell < 10
                                            ? MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.03
                                            : quantityofwooltosell < 999
                                            ? MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.1
                                            : MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.2,


                                        // width: quantitytextfield.text.length<8?quantitytextfield.text.length<5? quantitytextfield.text.length<2?MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.1:quantitytextfield.text.length.toDouble() *10: MediaQuery.of(context).size.width*0.2,
                                        // child: TextFormField(
                                        //   onChanged: (_){
                                        //     setState(() {
                                        //       if(quantitytextfield.text==''){
                                        //         quantitytextfield.text='0';
                                        //       }else if (quantitytextfield.text.startsWith('0') &&  quantitytextfield.text.length>1) {
                                        //         quantitytextfield.text = quantitytextfield.text.substring(1,quantitytextfield.text.length); // Clear the text field if '0' is the only input
                                        //       }
                                        //       quantityofwooltosell=int.parse(quantitytextfield.text);
                                        //       print(quantitytextfield.text);
                                        //       print(quantityofwooltosell);
                                        //     });
                                        //   },
                                        //   controller: quantitytextfield,
                                        //   keyboardType: TextInputType.number,
                                        //   textAlign: TextAlign.center,
                                        //   inputFormatters: [
                                        //     FilteringTextInputFormatter.digitsOnly,
                                        //     LengthLimitingTextInputFormatter(7), // Limit to 7 digits
                                        //   ],
                                        //
                                        //   decoration: InputDecoration(border: InputBorder.none,
                                        //
                                        //   ),
                                        //
                                        // ),
                                        child: Text(
                                            quantityofwooltosell.toString()),
                                      ),
                                      IconButton(onPressed: () {
                                        print(quantityofwooltosell);

                                        if (quantityofwooltosell <
                                            widget.quantity) {
                                          setState(() {
                                            quantityofwooltosell =
                                                quantityofwooltosell + 1;
                                            adjustedprice = ((widget.amount /
                                                widget.quantity) *
                                                quantityofwooltosell).toInt();
                                            amountofwooltosell = adjustedprice;
                                            amounttextfield.text =
                                                adjustedprice.toString();
                                          });
                                        }

                                        // quantitytextfield.text=quantityofwooltosell.toString();


                                      }, icon: Icon(Icons.add),),

                                    ]
                                ),
                              )),


                        ],
                      ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Amount (₹)"),
                          Card(
                            elevation: 2,


                              child: Container(

                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      IconButton(onPressed: () {
                                        setState(() {
                                          if (amountofwooltosell != 0) {
                                            amountofwooltosell =
                                                amountofwooltosell - 1;
                                            amounttextfield.text =
                                                amountofwooltosell.toString();
                                          }
                                        });
                                      }, icon: Icon(CupertinoIcons.minus)),

                                      Container(
                                        // margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),


                                        width: amounttextfield.text.length < 8
                                            ? amounttextfield.text.length < 5
                                            ? amounttextfield.text.length < 2
                                            ? MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.03
                                            : MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.1
                                            : amounttextfield.text.length
                                            .toDouble() * 10
                                            : MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.2,
                                        child: TextFormField(
                                          onChanged: (_) {
                                            setState(() {
                                              if (amounttextfield.text == '') {
                                                amounttextfield.text = '0';
                                              } else
                                              if (amounttextfield.text.startsWith(
                                                  '0') &&
                                                  amounttextfield.text.length >
                                                      1) {
                                                amounttextfield.text =
                                                    amounttextfield.text
                                                        .substring(1,
                                                        amounttextfield.text
                                                            .length); // Clear the text field if '0' is the only input
                                              }
                                              amountofwooltosell =
                                                  int.parse(amounttextfield.text);
                                              print(amounttextfield.text);
                                              print(amountofwooltosell);
                                            });
                                          },
                                          controller: amounttextfield,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(8),
                                            // Limit to 7 digits
                                          ],

                                          decoration: InputDecoration(
                                            border: InputBorder.none,

                                          ),

                                        ),
                                      ),
                                      IconButton(onPressed: () {
                                        setState(() {
                                          print(amountofwooltosell);

                                          if (adjustedprice >
                                              amountofwooltosell) {
                                            amountofwooltosell =
                                                amountofwooltosell + 1;
                                            amounttextfield.text =
                                                amountofwooltosell.toString();
                                          }
                                        });
                                      }, icon: Icon(Icons.add),),


                                    ]
                                ),
                              )),


                        ],
                      )


                      // Text(nego?'Negotiable Price':'Non Negotiable Price')
                    ],),
                ),

                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.02,),


                // SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                // SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text('Pay Transportation Charges? '),
                //         Text('(see our transportation charges below)')
                //       ],
                //     ),
                //
                //     Checkbox(value: paycharges, onChanged: (_){
                //       setState(() {
                //         paycharges=!paycharges;
                //       });
                //     })
                //   ],),
                //
                // SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // widget.nego?TextButton(onPressed: (){}, child: Text('Negotiate')):SizedBox(),

                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white
                        ),


                        onPressed: () {
                          if (quantityofwooltosell != 0) {
                            var orderid = generateUniqueOrderId();


                            int priceforselectedquantity = ((widget.amount /
                                widget.quantity) * quantityofwooltosell).toInt();


                            addNegoIteminNotifcation(widget.sellerid);
                            addNegoReqSentIteminNotifcation(widget.sellerid);

                            uploadUserData(woolType: widget.wooltype, negotiatedPrice: adjustedprice, actualPrice: widget.amount, actualQuantity: widget.quantity, sellerId: widget.sellerid, adjustedQuanitity: quantityofwooltosell);

                          Navigator.pop(context);

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    // backgroundColor:  Colors.black,
                                    // backgroundColor: ,
                                    // backgroundColor: Color(0xFFF062121),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    title: Text(
                                      'Negotiation Request Sent Successfully!', style: TextStyle(color: Colors.black),
                                    ),
                                    icon: Icon(
                                      Icons.rocket_launch,
                                      color: Colors.green,
                                    ),

                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [





                                      ],
                                    ),
                                  );
                                });
                            //  CircularProgressIndicator();


                            // Navigator.pushReplacement(
                            //     context, MaterialPageRoute(builder: (context) {
                            //   return  verifyBuyingInfo(widget.nego,widget.wooltype,quantityofwooltosell,priceforselectedquantity,widget.address,widget.state,widget.city,orderid,widget.sellerid,widget.address,widget.sellername,paycharges);
                            // }));
                          } else {
                            final snackBar = SnackBar(
                              content: Text('Quantity Can\'t be Zero!!'),);


                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        }, child: Text('Negotiate Now'))

                  ],)
              ],
            ),
          ),
        ),
      ),
    );
  }


  void addNegoIteminNotifcation(String sellerid) async {
    try {
      // Get a reference to the Firestore collection 'users'
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Get a reference to the user's document
      DocumentReference userDocRef = users.doc(sellerid);

      // Check if the document exists
      bool userExists = (await userDocRef.get()).exists;

      // If not, create the document with notifcount initialized to 0
      if (!userExists) {
        await userDocRef.set({'notifcount': 0});
      }

      // Get a reference to the subcollection 'notifications' inside the user's document
      CollectionReference notifications = userDocRef.collection(
          'notifications');

      // Get the current timestamp
      Timestamp timestamp = Timestamp.now();

      // Create a document inside 'notifications' with the timestamp as the document ID
      await notifications.doc(timestamp.toString()).set({

        'negoname': name,
        'type': 'nego',
        'wooltype': widget.wooltype,
        'negoid': userid,
        'amount': widget.amount,
        'quantity': widget.quantity,
        'adjustedmaxprice': adjustedprice,
        'adjustedmaxquantity': quantityofwooltosell,
        'timestamp': timestamp,
        'negoprice': amountofwooltosell,
        'willipaytranscharges': false
      });

      // Increment the notifcount variable
      await userDocRef.update({'notifcount': FieldValue.increment(1)});

      print('Item added to cart and notification created successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }

  void addNegoReqSentIteminNotifcation(String sellerid) async {
    try {
      // Get a reference to the Firestore collection 'users'
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Get a reference to the user's document
      DocumentReference userDocRef = users.doc(userid);

      // Check if the document exists
      bool userExists = (await userDocRef.get()).exists;

      // If not, create the document with notifcount initialized to 0
      if (!userExists) {
        await userDocRef.set({'notifcount': 0});
      }

      // Get a reference to the subcollection 'notifications' inside the user's document
      CollectionReference notifications = userDocRef.collection(
          'notifications');

      // Get the current timestamp
      Timestamp timestamp = Timestamp.now();

      // Create a document inside 'notifications' with the timestamp as the document ID
      await notifications.doc(timestamp.toString()).set({

        'negoname': name,
        'type': 'negosent',
        'wooltype': widget.wooltype,
        'negoid': userid,
        'amount': widget.amount,
        'quantity': widget.quantity,
        'adjustedmaxprice': adjustedprice,
        'adjustedmaxquantity': quantityofwooltosell,
        'timestamp': timestamp,
        'negoprice': amountofwooltosell,
        'willipaytranscharges': false
      });

      // Increment the notifcount variable
      await userDocRef.update({'notifcount': FieldValue.increment(1)});

      print('Item added to cart and notification created successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }
}


