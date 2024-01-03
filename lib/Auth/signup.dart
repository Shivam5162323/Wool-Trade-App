import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Auth/signin.dart';

import '../Screens/buy.dart';
import 'auth.dart';
import 'otp.dart';




String generateFiveDigitNumber() {
  Random random = Random();
  return (random.nextInt(90000) + 10000).toString(); // Generates a random number between 10000 and 99999
}


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

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
      String username = 'Your Gmail id'; // Your Gmail username
      String password = 'Your gmail password'; // Your Gmail password

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
      prefs.setString('email', email.text);
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














  var cardphone = '';
  var cardname = '';


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



  Future<String?> getUserIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
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

      body: Container(



        width: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.09,left: MediaQuery.of(context).size.width*0.09,right: MediaQuery.of(context).size.width*0.09),



        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                // height: MediaQuery.of(context).size.height,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.23),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [






                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),






                    Text('Sign Up',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*11, fontWeight: FontWeight.w400),),
                    Container(margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),),
                    Form(

                        key: _formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: Container(
                          height:       MediaQuery.of(context).size.height,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [





                            //
                            // Row(
                            //   children: [
                            //     Icon(CupertinoIcons.person_fill),
                            //     Text('  Name',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.021,fontWeight: FontWeight.w400),),
                            //   ],
                            // ),
                            Container(
                              // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07,vertical:MediaQuery.of(context).size.height*0.009 ),

                              child: TextFormField(
                                controller: name,
                                onChanged: (_){

                                  setState(() {
                                    cardname=name.text;
                                  });

                                },


                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  icon: Icon(
                                    Icons.person_2,
                                    color: Colors.black87,
                                  ),
                                  labelStyle:
                                  TextStyle(color: Colors.black87, fontSize: 18),
                                  errorStyle: TextStyle(
                                    color: Colors.black,),
                                  // border: InputBorder.none,

                                  // alignLabelWithHint: true,
                                    // label: Text('name'),
                                    contentPadding: EdgeInsets.all(0),
                                    isDense: true,




                                  hintText: 'Name',

                                  hintStyle: TextStyle(color: Colors.black26),

                                ),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    overflow: TextOverflow.visible),
                                keyboardType: TextInputType.name,
                                // validator: (value) {
                                //   if (value!.isEmpty) {
                                //     return 'Username can\'t be null';
                                //   }
                                //   return null;
                                // },
                              ),
                            ),










                              Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),






                              // Row(
                              //   children: [
                              //     Icon(Icons.mail),
                              //
                              //     Text('  Email',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.021,fontWeight: FontWeight.w400),),
                              //   ],
                              // ),
                              Container(
                                // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07,vertical:MediaQuery.of(context).size.height*0.009 ),

                                child: TextFormField(
                                  controller: email,
                                  onChanged: (_){

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




                                    hintText: 'abc@gmail.com',
                                    // helperText: 'sd',
                                    // floatingLabelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height*0.06),
                                    hintStyle: TextStyle(color: Colors.black26),


                                  ),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      overflow: TextOverflow.visible),
                                  keyboardType: TextInputType.emailAddress,

                                  // validator: (value) {
                                  //   if (value == null || !value.contains('@') || !value.endsWith('gmail.com') || !value.endsWith('.gov.in')) {
                                  //     return 'Enter a valid Gmail address';
                                  //   }
                                  //   return null;
                                  // },
                                ),
                              ),



























                              Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),






                              // Row(
                              //   children: [
                              //     Icon(Icons.numbers),
                              //     Text('  Contact No',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.021,fontWeight: FontWeight.w400),),
                              //   ],
                              // ),
                              Container(
                                // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07,vertical:MediaQuery.of(context).size.height*0.009 ),

                                child: TextFormField(
                                  controller: phoneno,
                                  onChanged: (_) {
                                    setState(() {
                                      cardphone=phoneno.text;
                                    });
                                  },
                                  decoration: InputDecoration(

                                    // border: InputBorder.none,

                                    labelText: 'Contact Number',
                                    icon: Icon(
                                      Icons.phone,
                                      color: Colors.black87,
                                    ),
                                    labelStyle:
                                    TextStyle(color: Colors.black87, fontSize: 18),
                                    errorStyle: TextStyle(
                                      color: Colors.black,),

                                    contentPadding: EdgeInsets.all(0),
                                    isDense: true,
                                    hintText: '+91 XXXXXXXXXX',
                                    hintStyle: TextStyle(color: Colors.black26,fontSize: MediaQuery.of(context).size.height*0.017),
                                  ),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    overflow: TextOverflow.visible,
                                  ),
                                  keyboardType: TextInputType.phone, // Set keyboard type to accept phone numbers
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10), // Limit input to 10 characters
                                  ],
                                  // validator: (value) {
                                  //   if (value == null || value.trim().isEmpty) {
                                  //     return 'This field is required';
                                  //   }
                                  //
                                  //   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                  //     return 'Please enter a valid phone number';
                                  //   }
                                  //
                                  //   if (value.length != 10) {
                                  //     return 'Phone number must be 10 digits long';
                                  //   }
                                  //
                                  //   return null;
                                  // },
                                ),
                              ),









                              Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),






                              // Row(
                              //   children: [
                              //     Icon(Icons.password),
                              //
                              //     Text('  Password',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.021,fontWeight: FontWeight.w400),),
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

                                    labelText: 'Password',
                                    icon: Icon(
                                      Icons.security_outlined,
                                      color: Colors.black87,
                                    ),
                                    labelStyle:
                                    TextStyle(color: Colors.black87, fontSize: 18),
                                    errorStyle: TextStyle(
                                      color: Colors.black,),
                                    // border: InputBorder.none,

                                    contentPadding: EdgeInsets.all(0),
                                    isDense: true,








                                    hintText: '* * * * * * *',

                                    hintStyle: TextStyle(color: Colors.black26),

                                  ),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      overflow: TextOverflow.visible),
                                  keyboardType: TextInputType.name,
                                  // validator: (value) {
                                  //   if (value == null || value.trim().isEmpty) {
                                  //     return 'This field is required';
                                  //   }
                                  //   if (value.trim().length < 8) {
                                  //     return 'Password must be at least 8 characters in length';
                                  //   }
                                  //   return null;
                                  // },
                                ),
                              ),



                              // Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.textScaleFactorOf(context)*10),),









                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height * 0.06),
                                  child: ElevatedButton(
                                    onPressed: () async {

                                      if (_formKey.currentState!.validate()){



                                       if (name.text == '' ) {
                                        final snackBar = SnackBar(
                                          content: Text('Name Can\'t be Empty'),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                      }

                                      else if (email.text == '' || !(email.text.contains('@gmail.com') || email.text.endsWith('.gov.in'))) {
                                          final snackBar = SnackBar(
                                            content: Text('Enter a valid Gmail address or a .gov.in address'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }


                                        else if (phoneno.text == null || phoneno.text.trim().isEmpty) {
                                          final snackBar = SnackBar(
                                            content: Text('Please enter a valid phone number'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }

                                        else if (!RegExp(r'^[0-9]+$').hasMatch(phoneno.text)) {
                                          final snackBar = SnackBar(
                                            content: Text('Please enter a valid phone number'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }



                                        else if (phoneno.text.length != 10) {
                                          final snackBar = SnackBar(
                                            content: Text('Phone number must be 10 digits long'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        }



                                        else if (password.text == '' || password.text.trim().isEmpty) {
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


                                         dynamic result = await _auth.signInEmailPassword(LoginUser(email: email.text,password: password.text));


                                      if(  result.uid !=null) {
                                        print(result.code);
                                        print(result.uid);
                                        // print('abc');


                                        final snackBar = result.uid==''?
                                        SnackBar(
                                          content:     Text(capitalize(result.code))):
                                          SnackBar(
                                            content:     Text(capitalize('User Already Exists')))  ;


                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);




                                      }
                                         else if(result.code == 'user-not-found' || result.code == 'INVALID_LOGIN_CREDENTIALS'  ){
                                        String? userId = await getUserIdByEmail(email.text);
                                        print(userId);

                                        if(userId!=null){

                                          final snackBar = SnackBar(
                                            content: Text('Email Linked with Different Account'),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                        }
                                        else{
                                          print(result.uid);


                                          otpresult = await sendOtpToEmail();
                                          print(otpresult);



                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>OTPScreen(email.text,password.text,name.text,otptosend,otpresult,phoneno.text)));



                                        }
                                           // getUserIdByEmail(email.text);


                                         }



                                       }





                                      }





                                    },
                                    style: ElevatedButton.styleFrom(
                                        // primary: Colors.black,
                                      backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: StadiumBorder(side: BorderSide(width: 0.1)),
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width * 0.95,
                                            MediaQuery.of(context).size.height * 0.063)),
                                    child: Text('Create Account',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.016),),



                                  ),
                                ),
                              ),




                              // SizedBox(height: MediaQuery.of(context).size.height*0.02,),

                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(

                                  margin: EdgeInsets.only(top: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.01),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                            CupertinoPageRoute(
                                                builder: (context) => Signin()));
                                      },
                                      child: Text('Sign in into a existing account',
                                        style: TextStyle(
                                            fontSize: 16),
                                      ),

                                    ),

                                  ),
                                ),
                              ),























                            ],),
                        )

                    )


                  ],
                ),
              ),
            ),








































            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01,),
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,

                                            children: [
                                              cardname==''?
                                              Text('Your Name',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.grey, ),)
                                                  :Text(capitalize(cardname),style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.white70, ),)

                                            ],),

                                          cardphone==''?Text('+91 XXXXXXXXXX',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.grey, ),)
                                              :Text('+91 $cardphone',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.white70, ),)


                                        ],
                                      ),
                                    )
                                  ],),

                              )
                            ],
                          ),
                        )),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

