import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Auth/signin.dart';
import 'package:woolify/Home/home.dart';
import 'package:woolify/main.dart';

class verifySellingInfo extends StatefulWidget {
  final verifymail;
  final ispricenegotiable;
  final selectedwooltosell;
  final quantityofwool;
  final amountofwool;
  final amountuserwillget;
  final platformamount;
  final address;
  final landmark;
  final state;
  final city;
  final orderid;
  final sellerid;

  verifySellingInfo(this.verifymail, this.ispricenegotiable,this.selectedwooltosell,this.quantityofwool,this.amountofwool,this.amountuserwillget,this.platformamount,this.address,this.landmark,this.state,this.city,this.orderid,this.sellerid);

  @override
  State<verifySellingInfo> createState() => _verifySellingInfoState();
}

class _verifySellingInfoState extends State<verifySellingInfo> {



  // var orderid;
  void fetchEmail() async {
    // Get a reference to the Firestore collection 'users'
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get a reference to the user's document using the userid
    DocumentReference userDocRef = users.doc(userid);

    try {
      // Get the user's document
      DocumentSnapshot userSnapshot = await userDocRef.get();

      // Check if the document exists and contains an email field
      if (userSnapshot.exists && userSnapshot.data() != null) {
        // Access the email field if it exists
        dynamic userData = userSnapshot.data();
        if (userData != null && userData['email'] != null) {
          setState(() {
            email = userData['email'];
            name = userData['name'];
            print(email);
            print(name);
          });
        }
      }
      // If email is null or not found, you can handle it here

    } catch (e) {
      print('Error: $e');

    }
  }

  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid');
      email = email==null?usermail:email;
    });
  }




  void uploadDataToFirestore({

    required String typeofwool,
    required int quantity,
    required int amount,
    required double amountuserwillget,
    required double platformfees,
    required String orderid,
    required String address,
    required bool ispricenego,
    required String sellerid
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    print(email);
    print(usermail);

    // Create a map with the data to be uploaded
    Map<String, dynamic> sellWoolData = {
      'name': name,
      'sellerid': userid,
      'time':DateTime.now(),
      'typeofwool': typeofwool,
      'quantity': quantity,
      'amount': amount,
      'amountuserwillget': amountuserwillget,
      'platformfees': platformfees,
      'orderid': orderid,
      'address': address,
      'ispricenego': ispricenego,
      'city':widget.city,
      'state':widget.state,
      'sellerid': userid,
      // 'org':email==''?firstmail.endsWith('.gov.in')?'gov':'Private':email.endsWith('.gov.in')?'gov':'Private',
      'org':email==null?usermail.endsWith('.gov.in')?'gov':'Private':email.endsWith('.gov.in')?'gov':'Private',
      'comb': '${widget.city} ${widget.state}'

    };

    // Upload data to the 'sellwool' collection with userId as document id
    await firestore.collection('sellwool').doc(userid).set(sellWoolData);

    // Append orderid to the list in 'sellwool' collection
    await firestore.collection('sellwool').doc(userid).update({
      'allorderids': FieldValue.arrayUnion([orderid]),
    });

    // Also, store details in 'orders' collection
    await firestore
        .collection('sellwool')
        .doc(userid)
        .collection('orders')
        .doc(orderid)
        .set({
      'name': name,
      'sellerid': userid,
      'time':DateTime.now(),
      'amount': amount,
      'amountuserwillget': amountuserwillget,
      'platformfees': platformfees,
      'orderid': orderid,
      'address': address,
      'ispricenego': ispricenego,
      'quantity': quantity,
      'typeofwool': typeofwool,
      'city':widget.city,
      'state':widget.state,
      'sellerid': widget.sellerid,
      'org':email==null?usermail.endsWith('.gov.in')?'gov':'Private':email.endsWith('.gov.in')?'gov':'Private',

      'comb': '${widget.city} ${widget.state}'


    });


    // Upload data to 'orders' collection with orderid as document id
    // await firestore.collection('orders').doc(orderid).set(orderData);
  }








  void addSelledIteminNotifcation() async {
    try {
      // Get a reference to the Firestore collection 'users'
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Get a reference to the user's document
      DocumentReference userDocRef = users.doc(userid);

      // Check if the document exists
      bool userExists = (await userDocRef.get()).exists;

      // If not, create the document with notifcount initialized to 0
      if (!userExists) {
        await userDocRef.set({'notifcount': 0});
      }

      // Get a reference to the subcollection 'notifications' inside the user's document
      CollectionReference notifications = userDocRef.collection('notifications');

      // Get the current timestamp
      Timestamp timestamp = Timestamp.now();

      // Increment the notifcount variable
      await userDocRef.update({'notifcount': FieldValue.increment(1)});

      // Create a document inside 'notifications' with the timestamp as the document ID
      await notifications.doc(timestamp.toString()).set({
        'type': 'sellcon',
        'wooltype': widget.selectedwooltosell,
        'orderid': widget.orderid,
        'amount': widget.amountofwool,
        'quantity': widget.quantityofwool,
        'timestamp': timestamp,
        // 'willipaytranscharges':widget.
      });

      print('Item added to cart and notification created successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }




  Future<String> generateUniqueOrderId() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the list of order IDs for the specified user
    DocumentSnapshot userDoc = await firestore.collection('sellwool').doc(userid).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    List<dynamic> orderIds = userData?['allorderids'] ?? [];
    String randomOrderId;

    do {
      // Generate a random 11-digit number
      randomOrderId = (1000000000 + Random().nextInt(900000000)).toString();
    } while (orderIds!.contains(randomOrderId)); // Keep generating until it's unique

    return randomOrderId;
  }






















  Future<String> sendOtpToEmail() async {
    try {
      String username = 'vendvl.0@gmail.com'; // Your Gmail username
      String password = 'tyutpoxywxwaxmle'; // Your Gmail password

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Woolify')
        ..recipients.add(email==null?firstmail:email) // Replace with the user's email address
        ..subject = 'Order Placed'
        ..html= '''
     <!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verification Code</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            display: flex;
            justify-content: center; /* Center horizontally */
            align-items: center; /* Center vertically */
            height: 0.7vh; /* Use full viewport height */
            margin: 0;
        }
        img {
            display: block;
            margin: 0 auto; /* Center the image */
            margin-bottom: 30px; /* Add margin of 0.2% of viewport height */
        }

        .container {
            display: table;
            margin: 0 auto;
            border-radius: 10px;
            padding: 20px;
            text-align: center; /* Align OTP to center */
            max-width: 100%; /* Set a maximum width for the container */
            box-sizing: border-box; /* Ensure padding is included in width */
            background-size: cover; /* Ensure the background image covers the container */
            background-position: center; /* Center the background image */
        }

        .bold-text {
            font-weight: bold;
            font-size: 24px;
            text-align: center;
        }

        .otp-container {
            letter-spacing: 1em;
            font-size: 32px;
        }

        img {
            display: block;
            margin: 0 auto; /* Center the image */
        }

        .info-text {
            margin-top: 20px;
            font-size: 14px;
            color: #777;
        }

        /* Add a class for white text */
        .dark-text {
            color: black;
        }
    </style>

    <style>
       
            .container {
            background-color: #DDDDDD
                  background-image: url('https://i.ibb.co/8z7c2bB/Picture1.png');

               
            }
            /* Apply white text for larger screens */
            .white-text {
                color: white;
            }
        

        
    </style>
</head>

<body>
    <div class="container">
        <div class="bold-text white-text">Woolify</div>
        <img src="https://i.ibb.co/mvgs5hx/13Q5NYt.png"  width="270" height="200">
        
        
       
        <div class="dark-text">Your Order Has Been Placed </div>
        <div class="dark-text bold-text">Order Summary</div>
        <div class="info-text dark-text">You will be notified when we find a buyer for your order.</div>
    </div>
</body>

</html>





        '''
        // ..text = 'Your order id is: '; // Replace with the generated OTP

          ; // Replace with the generated OTP

      await send(message, smtpServer);

      return 'OTP sent successfully!';
    } catch (e) {
      return 'Failed to send OTP. Error: $e';
    }
  }








  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    fetchUserId();
    fetchEmail();
    // orderid= await generateUniqueOrderId();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Verify Your Details'),centerTitle: true,),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.height* 0.02),


          child: Column(children: [

            SizedBox(height: MediaQuery.of(context).size.height*0.04,),

            Row(
              children: [
                Text('Order Id: ',style: TextStyle(fontWeight: FontWeight.bold),),
                Text('#${widget.orderid.toString()}')
                // Expanded(
                //   child: FutureBuilder<String>(
                //     future: generateUniqueOrderId(),
                //     builder: (context, snapshot) {
                //       if (snapshot.connectionState == ConnectionState.waiting) {
                //         return CircularProgressIndicator(); // Show loading indicator
                //       } else if (snapshot.hasError) {
                //         return Text('Error: ${snapshot.error}');
                //       } else {
                //         return Text('  #${snapshot.data}',style: TextStyle(fontWeight: FontWeight.bold),);
                //       }
                //
                //
                //     },
                //   ),
                // )
              ],
            ),

            Image.asset('assets/images/working.png',height: MediaQuery.of(context).size.height*0.3,),
            SizedBox(height: MediaQuery.of(context).size.height*0.04,),

            Card(


              child: Container(
                margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.03,vertical: MediaQuery.of(context).size.height*0.03 ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Wool Type: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        Text(widget.selectedwooltosell),

                      ],
                    ),


                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),




                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Quantity: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        Text('${widget.quantityofwool.toString()} Kg'),


                      ],
                    ),



                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Amount: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        Text('₹${widget.amountofwool.toString()}'),

                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Platform fees: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        Text('₹${(widget.amountofwool*0.1).toStringAsFixed(2)}'),

                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Amount You will get: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        Text('₹${(widget.amountofwool- widget.amountofwool*0.1).toStringAsFixed(2)}'),

                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Text('Is Price negotiable: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        widget.ispricenegotiable?Text('Yes'):Text('No'),

                      ],
                    ),


                    SizedBox(height: MediaQuery.of(context).size.height*0.017,),




                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup Address: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.height*0.02),),
                        SizedBox(width: MediaQuery.of(context).size.width*0.027,),

                        Expanded(

                          child: Align(
                              alignment: Alignment.centerRight,

                              child: Text('${widget.address}, ${widget.city}, ${widget.state}',style: TextStyle(overflow: TextOverflow.clip),)),),

                      ],
                    ),
                  ],
                ),
              ),
            ),



            SizedBox(height: MediaQuery.of(context).size.height*0.017,),

            Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white
                    ),
                    onPressed: ()  async {


                       sendOtpToEmail();
                      // print(res);



                      uploadDataToFirestore(
                          typeofwool: widget.selectedwooltosell,
                          quantity: widget.quantityofwool,
                          amount: widget.amountofwool,
                          amountuserwillget: widget.amountuserwillget,
                          platformfees: widget.platformamount,
                          orderid: widget.orderid,
                          address: widget.address,
                          ispricenego: widget.ispricenegotiable,
                          sellerid: widget.sellerid==null?firstmail:widget.sellerid

                      );


                      addSelledIteminNotifcation();
                      print(firstmail);
                      print(email);






                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) {
                        return  sellingorderplaced(widget.orderid,widget.amountofwool);
                      }

                      ));


                    }, child: Text('Place order')))












          ],),
        ),
      ),
    );
  }
}





















class sellingorderplaced extends StatefulWidget {
  final orderid;
  final amount;

  sellingorderplaced(this.orderid,this.amount);
  @override
  State<sellingorderplaced> createState() => _sellingorderplacedState();
}

class _sellingorderplacedState extends State<sellingorderplaced> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.1,left: MediaQuery.of(context).size.height*0.03,right: MediaQuery.of(context).size.height*0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                // alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.height*0.01),
                width: MediaQuery.of(context).size.height*0.22,
                height: MediaQuery.of(context).size.height*0.22,
                child: Image.asset('assets/images/grateful.png',height: MediaQuery.of(context).size.height*0.3,),
              ),

              Container(
                margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.03,left: MediaQuery.of(context).size.height*0),
                child: Column(
                  children: [
                    Text('Your order has been placed.',
                      style: TextStyle(
                        fontSize: 30,fontWeight: FontWeight.w500,
                      ),),
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                      child: Text('An email with payment information has been sent to your email $email',
                        style: TextStyle(
                            fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black45
                        ),),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.06),
                      child: Row(
                        children: [
                          Text('Order Details',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,fontSize: 20
                            ),),
                          Spacer(),
                          Text('View Details',
                            style: TextStyle(
                                fontSize: 16,fontWeight: FontWeight.w400,color: Color(0xFFF797db0)
                            ),)
                        ],
                      ),
                    ),


                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.045),
                      child: Row(
                        children: [
                          Text('Total Amount',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,fontSize: 18,color: Colors.black54
                            ),),
                          Spacer(),
                          Text('₹${widget.amount.toString()}',
                            style: TextStyle(
                                fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87
                            ),)
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.035),
                      child: Row(
                        children: [
                          Text('Order Number',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,fontSize: 18,color: Colors.black54
                            ),),
                          Spacer(),
                          Text('#${widget.orderid}',
                            style: TextStyle(
                                fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87
                            ),)
                        ],
                      ),
                    ),


                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.06),
                      child: ElevatedButton(onPressed: (){


                        setState(() {
                          selectedIndex=2;
                        });

                        // Navigator.pop(context);


                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (context) => Home()));


                      },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: StadiumBorder(
                                  side: BorderSide(width: 0.1)
                              ),
                              minimumSize: Size(MediaQuery.of(context).size.width * 0.55, MediaQuery.of(context).size.height * 0.063)
                          ),
                          child: Text('Continue Exploring',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: Colors.white),)),

                    )






                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}