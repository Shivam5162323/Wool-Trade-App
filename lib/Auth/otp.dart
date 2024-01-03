import 'dart:async';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Home/home.dart';
import 'auth.dart';

final random = Random();
var o = random.nextInt(90000) + 10000;


var verifyotp;




class OTPScreen extends StatefulWidget {
  final mailid;
  final pass;
  final name;
  final otp;
  final result;
  final phone;
  OTPScreen(this.mailid,this.pass,this.name,this.otp,this.result,this.phone);
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {


  final OTP = OtpFieldController();

  var otptosend;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      otptosend=widget.otp;
    });

  }

  final AuthService _auth = AuthService();

  EmailOTP myauth = EmailOTP();




















  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  late String documentId;
  Future<void> addUsertoDatabase() async {



    // String documentId = generateDocumentId(email);
    DocumentReference users = FirebaseFirestore.instance.collection('users').doc();
    documentId = users.id;
    // userid = documentId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('userid', users.id);
      prefs.setString('email', widget.mailid);
      prefs.setString('name', widget.name);
    });

    print('User id======= $users.id');


    setState(() {

      // prefs.setString('userid', documentId);
    });



    return users
        .set({
      'name': widget.name,
      'email':widget.mailid,
      'id': users.id,
      'pass': widget.pass,
      'time': DateTime.now(),
      'profilephoto': 'assets/images/noprofile.png'



    })
        .then((value) => print("user Added"))
        .catchError((error) => print("Failed to add user: $error"));

    print('User id======= $users.id');

  }


  @override
  Widget build(BuildContext context) {
    int length = widget.mailid.toString().length;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Image.asset(
                'assets/images/plane.png',
                color: Colors.black,
              )),
          Text(
            'OTP Verification',
            style: TextStyle(fontSize: 36,color: Colors.black),
          ),
          Text(
            '* * * * *',
            style: TextStyle(fontSize: 36),
          ),

          Text('Check '+
            '${widget.mailid}'+ ' for OTP',
            style: TextStyle(color: Colors.purple, fontSize: MediaQuery.textScaleFactorOf(context)*15),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 37),
            child: OTPTextField(
                controller: OTP,
                length: 5,
                outlineBorderRadius: 36,
                fieldWidth: 47,
                otpFieldStyle: OtpFieldStyle(
                  backgroundColor: Color(0xFFF062121),
                  focusBorderColor: Colors.purple,
                  borderColor: Colors.black,
                  enabledBorderColor: Colors.black,
                ),
                width: MediaQuery.of(context).size.width,
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.box,
                onChanged: (String code) {
                  print(code);
                  setState(() {
                    verifyotp=code;
                  });
                },
                onCompleted: (String verificationCode) {
                }
            ),
          ),
          ElevatedButton(
              onPressed: () async {

                print(verifyotp);




                if (verifyotp.toString() == otptosend) {



                  dynamic result = await _auth.registerEmailPassword(
                      LoginUser(
                          email: widget.mailid, password: widget.pass));



                  addUsertoDatabase();

                  SharedPreferences prefs = await SharedPreferences.getInstance();







                  setState(() {
                    prefs.setString('email', widget.mailid);
                    prefs.setString('userid', documentId);
                    prefs.setString('name', widget.name);
                    prefs.setString('profilephoto', 'assets/images/noprofile.png');

                  });

                  print(documentId);
                  //
                  // prefs.setString('userid', documentId);
                  // setState(() {
                  //
                  // });
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFFF062121),
                          title: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Wrong OTP",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          content: Text(
                            'Check code and try once again!',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      });
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).devicePixelRatio*10,vertical: MediaQuery.of(context).devicePixelRatio*5),
                  child: Text('Verify OTP'))),

          TextButton(
            child: Text(
              '''Didn\'t receive OTP?''',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {

              // String result = await sendOtpToEmail();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(widget.result),
              ));
            },
          ),

        ],
      ),
    );
  }
}
