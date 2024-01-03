import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Auth/signup.dart';
// import 'package:woolify/Screens/buy.dart';

import '../Home/home.dart';
import 'auth.dart';
import 'otp.dart';

var firstmail;
var firstuid;

var usermail;
var username;



String generateFiveDigitNumber() {
  Random random = Random();
  return (random.nextInt(90000) + 10000).toString(); // Generates a random number between 10000 and 99999
}


class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SignupState();
}

class _SignupState extends State<Signin> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final ConfirmPass = TextEditingController();
  final phoneno = TextEditingController();


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();












  late String documentId;

  var otptosend= generateFiveDigitNumber();











  Future<String> sendOtpToEmail() async {
    try {
      String username = 'vendvl.0@gmail.com'; // Your Gmail username
      String password = 'bteavjdkzosenaen'; // Your Gmail password

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'VenDvl')
        ..recipients.add(email.text) // Replace with the user's email address
        ..subject = otptosend
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
            height: 100vh; /* Use full viewport height */
            margin: 0;
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
        .white-text {
            color: white;
        }
    </style>

    <style>
        @media (min-width: 768px) {
            .container {
                background-image: url('https://c4.wallpaperflare.com/wallpaper/843/66/529/illustration-mountains-low-poly-minimalism-wallpaper-preview.jpg');
            }
            /* Apply white text for larger screens */
            .white-text {
                color: white;
            }
        }

        @media (max-width: 767px) {
            .container {
                background-image: url('https://c4.wallpaperflare.com/wallpaper/535/845/69/digital-art-artwork-fantasy-art-planet-sun-hd-wallpaper-thumb.jpg');
            }
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="bold-text white-text">Ink Link</div>
        <img src="http://ven.epizy.com/image/output-onlinegiftools.gif" alt="GIF" width="200" height="200">
        <div class="otp-container white-text">
            $otptosend
        </div>
        <div class="white-text">Here is your verification code</div>
        <div class="info-text white-text">Please do not share this code with anyone for security reasons.</div>
    </div>
</body>

</html>





        '''
        ..text = 'Your OTP code is: '+ otptosend; // Replace with the generated OTP

      await send(message, smtpServer);

      return 'OTP sent successfully!';
    } catch (e) {
      return 'Failed to send OTP. Error: $e';
    }
  }

  var otpresult;








  Future<void> addUsertoDatabase() async {



    // String documentId = generateDocumentId(email);
    DocumentReference users = FirebaseFirestore.instance.collection('users').doc();
    documentId = users.id;
    // userid = documentId;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {

      prefs.setString('userid', documentId);
    });


    // print(_drivelink);
    // Call the user's CollectionReference to add a new user
    return users
        .set({
      'phone': phoneno.text,
      'name': name.text ,
      'email':email.text,
      'pass': password.text,
      'time': DateTime.now(),
      'id': documentId

    })
        .then((value) => print("user Added"))
        .catchError((error) => print("Failed to add user: $error"));

  }


  Future<void> checkAndDefineNotifCount(String userId) async {
    try {
      // Get a reference to the Firestore collection 'users'
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Run a transaction
      await FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
        DocumentReference userDocRef = users.doc(userId);

        // Get the document snapshot
        DocumentSnapshot snapshot = await transaction.get(userDocRef);

        // Check if 'notifcount' exists in the document
        final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data == null || data['notifcount'] == null) {
          // If 'notifcount' is not present, set it to 0
          transaction.set(userDocRef, {'notifcount': 0}, SetOptions(merge: true));
        }
      });

      print('Notifcount checked and defined successfully.');
    } catch (e) {
      print('Error: $e');
    }
  }



  Future<Map<String, dynamic>> getUserData(String userEmail) async {
    try {
      // Reference to the Firestore collection 'users'
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Query the Firestore collection to get the user document based on email
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: userEmail).get();

      // Check if a user document with the provided email exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (there should be only one matching email)
        DocumentSnapshot userData = querySnapshot.docs.first;

        // Extract the data you need (name, id, profile photo path)
        Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;

        // Return the user data
        return userDataMap;
      } else {
        // Handle the case where the user document does not exist
        return {};
      }
    } catch (e) {
      // Handle any errors that may occur during the data fetching process
      print('Error fetching user data: $e');
      return {};
    }
  }



  var cardmail = '';


  String capitalizeAndRemoveEmail(String input) {
    // Remove @gmail.com if found
    input = input.replaceAll('@gmail.com', '');

    // Capitalize the first letter
    if (input.isNotEmpty) {
      input = input.substring(0, 1).toUpperCase() + input.substring(1);
    }

    return input;
  }


  var cardno1='';
  var cardno2='';

  String generateRandomAlphanumeric() {
    const String chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    String result = '';

    for (int i = 0; i < 4; i++) {
      int index = random.nextInt(chars.length);
      result += chars[index];
    }

    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardno1=generateRandomAlphanumeric();
    cardno2=generateRandomAlphanumeric();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Container(
          //
          //   alignment: Alignment.topCenter,
          //   height: double.infinity,
          //   padding: EdgeInsets.all(20),
          //   color: Color(0xFFFe8ebf2),
          //   child: Column(
          //     children: [
          //       // Image.asset('assets/images/sheep1.gif',height: MediaQuery.of(context).size.height*0.2),
          //       Container(
          //         // decoration: BoxDecoration(
          //         //
          //         //   image: DecorationImage(image: AssetImage('assets/images/bs1.png'),alignment: Alignment.centerRight)
          //         // ),
          //           alignment: Alignment.centerLeft,
          //           margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.037),
          //           child: Image.asset('assets/images/sheep1.gif',height: MediaQuery.of(context).size.height*0.25)),
          //
          //     ],
          //   ),
          // ),
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  // color: Colors.white,
                  // borderRadius: BorderRadius.vertical(top: Radius.circular(27))
              ),
              width: double.infinity,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.09),
              // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.3),


              // height: MediaQuery.of(context).size.height*0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),


                  Card(
                    elevation: 48,
                    child: Container(

                      height:  MediaQuery.of(context).size.height*0.227,
                      decoration: BoxDecoration(image:DecorationImage(image: AssetImage('assets/images/privateuser.jpg',),fit: BoxFit.fill)

                      ,
                        borderRadius: BorderRadius.all(Radius.circular(17)),

                      ),


                      // elevation: 28,
                      child: ClipRRect(
                          // borderRadius: BorderRadius.all(Radius.circular(17)),

                          child: Container(

                          child: Stack(

                              children: [
                                // Image.asset('assets/images/privateuser.jpg',fit: BoxFit.fitHeight,),
                                Container(

                                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.06,vertical: MediaQuery.of(context).size.height*0.017),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                    children: [
                                    Row(
                                      // crossAxisAlignment:CrossAxisAlignment.end,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(70)),


                                            child: Image.asset('assets/images/logo.png',height: MediaQuery.of(context).size.height*0.04)),

                                        Column(children: [
                                          Text('  Woolify',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400))

                                        ],)

                                      ],
                                    ),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                        Text('$cardno1  XXXX  XXXX  $cardno2',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.02,color: Colors.white70, ),)

                                      ],),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,

                                        children: [
                                        cardmail==''?
                                        Text('Your Mail',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.grey, ),)
                                        :Text(cardmail,style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.white70, ),)

                                        ],),
                                    )
                                  ],),

                                )
                              ],
                            ),
                          )),),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                  Text('Sign In',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*15, fontWeight: FontWeight.w400),),
                  Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),
                  Form(

                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [











                          Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.007),),






                          // Row(
                          //   children: [
                          //     Icon(Icons.mail),
                          //     Text('  Email',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.023,fontWeight: FontWeight.w400),),
                          //   ],
                          // ),
                          Container(
                            // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),

                            child: Container(
                              // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07,vertical:MediaQuery.of(context).size.height*0.009 ),


                              // margin: EdgeInsets,
                              child: TextFormField(
                                controller: email,
                                onChanged: (_){

                                  setState(() {
                                    cardmail = email.text;
                                    cardmail= capitalizeAndRemoveEmail(email.text);

                                  });
                                },
                                decoration: InputDecoration(
                                  // border: InputBorder.none,
                                  labelText: 'Email',
                                  icon: Icon(
                                    Icons.mail,
                                    color: Colors.black87,
                                  ),
                                  labelStyle:
                                  TextStyle(color: Colors.black87, fontSize: 18),
                                  errorStyle: TextStyle(
                                    color: Colors.black,),



                                  contentPadding: EdgeInsets.all(0),
                                  isDense: true,




                                  hintText: 'Email',
                                  // helperText: 'sd',
                                  // floatingLabelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height*0.06),
                                  hintStyle: TextStyle(color: Colors.black26),


                                ),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    overflow: TextOverflow.visible),
                                keyboardType: TextInputType.emailAddress,
                                //
                                // validator: (value) {
                                //
                                //   //
                                //   // if (value == null || !(value.contains('@gmail.com') || value.endsWith('.gov.in'))) {
                                //   //   return 'Enter a valid Gmail address or a .gov.in address';
                                //   // }
                                //
                                //
                                //   return null;
                                // },
                              ),
                            ),
                          ),









                          SizedBox(height: MediaQuery.of(context).size.height*0.01,),




















                          Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),






                          // Row(
                          //   children: [
                          //     Icon(Icons.password),
                          //
                          //     Text('  Password',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.023,fontWeight: FontWeight.w400),),
                          //   ],
                          // ),
                          Container(
                            // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07,vertical:MediaQuery.of(context).size.height*0.009 ),

                            child: TextFormField(
                              controller: password,
                              onChanged: (_){

                              },
                              obscureText: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                isDense: true,
                                // border: InputBorder.none,


                                labelText: 'Password',
                                icon: Icon(
                                  Icons.security,
                                  color: Colors.black87,
                                ),
                                labelStyle:
                                TextStyle(color: Colors.black87, fontSize: 18),
                                errorStyle: TextStyle(
                                  color: Colors.black,),







                                hintText: '* * * * * * *',

                                hintStyle: TextStyle(color: Colors.black26),

                              ),
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  overflow: TextOverflow.visible),
                              keyboardType: TextInputType.name,

                            ),
                          ),



                          Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),









                          Center(
                            child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    top: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.06),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {



                                      if (email.text == null || !(email.text.contains('@gmail.com') || email.text.endsWith('.gov.in'))) {
                                        final snackBar = SnackBar(
                                          content: Text('Enter a valid Gmail address or a .gov.in address'),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }

                                        else if (password.text == null || password.text.trim().isEmpty) {
                                          final snackBar = SnackBar(
                                            content: Text('Password must be at least 8 characters in length'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                        }
                                        else if (password.text.trim().length < 8) {
                                          final snackBar = SnackBar(
                                            content: Text('Password must be at least 8 characters in length'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }
                                        else{




                                        dynamic result = await _auth
                                            .signInEmailPassword(LoginUser(
                                            email: email.text,
                                            password: password.text));
                                        if (result.uid == null) {
                                          // Handle the case where the user does not exist or the password is incorrect
                                          final snackBar = SnackBar(
                                            content: Text('User does not exist or wrong password!'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        } else {

                                          print(result.code);
                                          // Sign-in was successful

                                          Map<String, dynamic> userData = await getUserData(email.text);
                                          // var profilephoto;
                                          var name;
                                          var userid;
                                          // var email;
                                          if (userData != null) {
                                            // User data is available, you can access it like this:
                                            // name = userData['name'];

                                            // profilephoto = userData['profilePhotoPath'];

                                            setState(() {
                                              userid = userData['id'];
                                              username =userData['name'];
                                              usermail =userData['email'];


                                            });
                                            print(userid);
                                            print(username);
                                            print(usermail);






                                            SharedPreferences prefs = await SharedPreferences.getInstance();



                                            setState(() {
                                              prefs.setString('email', usermail);
                                              prefs.setString('userid', userid);
                                               prefs.setString('name', username);
                                              firstmail=email.text;
                                              firstuid=userid;
                                              userid = prefs.setString('userid', userid);
                                              // prefs.setString('profilephoto', profilephoto);

                                            });


                                            // checkAndDefineNotifCount(userid);



                                            // Do something with the user data
                                          } else {
                                            // Handle the case where the user document does not exist
                                            print('User data not found.');
                                          }






                                          //
                                          // setState(() {
                                          //   prefs.setString('email', email.text);
                                          //   prefs.setString('userid', userid);
                                          //   username = prefs.setString('name', name);
                                          //   firstmail=email.text;
                                          //   firstuid=userid;
                                          //   userid = prefs.setString('userid', userid);
                                          //   // prefs.setString('profilephoto', profilephoto);
                                          //
                                          // });
                                          //
                                          //
                                          // checkAndDefineNotifCount(userid);
                                          //
                                          Navigator.pushReplacement(context, MaterialPageRoute(
                                            builder: (context) => Home(),
                                          ));






                                        }








                                      }

                                    }

                                  },
                                  style: ElevatedButton.styleFrom(
                                      // primary: Colors.black,
                                    backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,

                                      shape:
                                      StadiumBorder(
                                          side: BorderSide(width: 0.1)),
                                      minimumSize: Size(
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.95,
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height * 0.063)),
                                  child: Text('Sign in me'),
                                )),
                          ),









                          Container(
                            margin: EdgeInsets.only(top: MediaQuery
                                .of(context)
                                .size
                                .height * 0.03),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                      CupertinoPageRoute(
                                          builder: (context) => Signup()));
                                },
                                child: Text('Create  an account',
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 16),
                                ),

                              ),

                            ),
                          ),













                        ],)

                  )


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}









