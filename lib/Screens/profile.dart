import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Auth/signin.dart';
import 'package:woolify/Widgets/Negotiationsacceptance.dart';
import 'package:woolify/Widgets/account.dart';
import 'package:woolify/Widgets/datanews.dart';
import 'package:woolify/Widgets/profilephoto.dart';
import 'package:woolify/Widgets/transactions.dart';

import '../main.dart';
import 'orders.dart';















class Settingss extends StatefulWidget {

  @override
  State<Settingss> createState() => _SettingssState();
}

class _SettingssState extends State<Settingss> {





// Retrieve all data from a single collection
  Future<List<Map<String, dynamic>>> getAllDataFromCollection(
      String collectionPath) async {
    final QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection(collectionPath).orderBy('date',descending: true).get();

    if (snapshot.docs.isNotEmpty) {
      // Create a list to hold the extracted data
      final List<Map<String, dynamic>> dataList = [];

      // Iterate through all documents in the collection
      snapshot.docs.forEach((doc) {
        // Extract the document data and add it to the list
        final data = doc.data();
        dataList.add(data as Map<String, dynamic>);
      });



      return dataList;
    } else {
      print('No data found in the collection.');
      return [];
    }
  }





  var profileimage2;
  // void updateProfilePhoto() {
  //   setState(() {
  //     profileimage2 = profilephoto;
  //   });
  // }
  var id;
  Future<List<Map<String, dynamic>>>? _futureData;


  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid');
      email = prefs.getString('mail')==null?usermail:prefs.getString('mail');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id= userid;
    print(id);

    fetchUserId();










    _futureData = getAllDataFromCollection('users');







    // loadProfilePhoto();

  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    // Replace 'your_collection' and 'your_document_id' with the appropriate values
    print('Getting data from Firestore'); // Add this line

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userid==null?firstuid:userid)
        .get();
    print(userid);
  }

  // var useridd;

  void loadProfilePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

// Reload the SharedPreferences instance to get the latest values
//     await prefs.reload();

// Get the updated value from SharedPreferences
    profileimage2 = prefs.getString('profilephoto');
    // useridd = prefs.getString('userid');
    print(profileimage2);

  }



  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        words[i] = word[0].toUpperCase() + word.substring(1);
      }
    }

    return words.join(' ');
  }


  final _auth = FirebaseAuth.instance;




// var profilephoto2;
  @override
  Widget build(BuildContext context) {

    // Navigator.pop(context);
    // updateProfilePhoto();

    loadProfilePhoto();

    Future<void> _refreshData() async {
      // Perform a refresh operation here, such as fetching new data from an API.
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _futureData;
      });
    }

    print(userid);


    return Scaffold(



      body: Container(
        // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02,left: MediaQuery.of(context).size.height*0.02,right: MediaQuery.of(context).size.height*0.02,),

        child: SingleChildScrollView(
          child: Column(
            children: [














              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getDataFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());

                  }
                  if (!snapshot.hasData || snapshot.data!.data()==null) {
                    return SizedBox();
                  }

                  print(id);

                  final data = snapshot.data!.data();
                  // final naam = data!['name'];
                  final mail = data!['email'];
                  final profile = data!['profilephotopath'];
                  final name =data!['name'];
                  final cardphone = data!['phone'];


                  return Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.height*0.01,),
                      Expanded(
                        child: Card(
                          elevation: 20,
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
                                                Text('$userid',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.02,color: Colors.white70, ),)

                                              ],),
                                            Container(
                                              alignment: Alignment.bottomLeft,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,

                                                    children: [
                                                      name==''?
                                                      Text('Your Name',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.grey, ),)
                                                          :Text(capitalize(name),style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.white70, ),)

                                                    ],),

                                                  cardphone==null?Text('+91 XXXXXXXXXX',style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.017,color: Colors.grey, ),)
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
                      ),
                      SizedBox(width: MediaQuery.of(context).size.height*0.01,),

                    ],
                  );

                },
              ),









              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02,left: MediaQuery.of(context).size.height*0.02,right: MediaQuery.of(context).size.height*0.02,),

                child: Column(children: [









                  Container(margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height*0.015),),
                  ListTile(
                    onTap: (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) {
                        return Account(); }));
                    },
                    // subtitle: Text('Change phone number, Transfer account, Delete account',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*4,color: Colors.grey),),
                    leading: Icon(CupertinoIcons.person_alt_circle,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Account',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),

                  ListTile(
                    leading: Icon(Icons.rocket_launch,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Items on sell',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),

                    onTap: (){
                      // setState(() {
                      //   selecteddrawertile=0;
                      //
                      // });

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>SellOrders()

                      ));
                    }

                  ),


                  ListTile(
                    leading: Icon(CupertinoIcons.cube_box_fill,size:MediaQuery.of(context).devicePixelRatio*10,),
                    title: Text('Orders',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),

                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) =>BuyOrders()));
                    },

                  ),

                  ListTile(
                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) {
                        return  NegotiationsAcceptance();

                          }));

                    },
                    leading: Icon(CupertinoIcons.sort_down_circle_fill,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Negotiations Requested',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),

                  // ListTile(
                  //   onTap: (){},
                  //   leading: Icon(CupertinoIcons.chat_bubble,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                  //   title: Text('Chats',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),

                  ListTile(
                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) {
                        return  Transactions();

                      }));
                    },
                    leading: Icon(CupertinoIcons.creditcard_fill,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Transactions',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),


                  // ListTile(
                  //   onTap: (){},
                  //   leading: Icon(CupertinoIcons.lock,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                  //   title: Text('Privacy',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),
                  //
                  //
                  // ListTile(
                  //   onTap: (){},
                  //   leading: Icon(CupertinoIcons.chart_pie,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                  //   title: Text('Data and Storage',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),

                  Container(margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height*0.015,),child: Divider(color: Colors.blueGrey,),),


                  ListTile(
                    onTap: (){

    Navigator.push(
    context, MaterialPageRoute(builder: (context)
    {
      return Newsscre();
    }
                      ));

                    },
                    leading: Icon(CupertinoIcons.question_circle_fill,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Help',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),

                  ListTile(
                    onTap: (){},
                    leading: Icon(CupertinoIcons.paperplane_fill,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Invite a friend',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),



                  Container(margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height*0.015,),child: Divider(color: Colors.blueGrey,),),


                  ListTile(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor:  Colors.black,
                              // backgroundColor: ,
                              // backgroundColor: Color(0xFFF062121),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              title: Text(
                                'Are you sure you want to log out?', style: TextStyle(color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.output,
                                color: Colors.white,
                              ),

                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _auth.signOut();

                                      SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      setState(() {
                                        prefs.remove('email');
                                        prefs.remove('userid');
                                        prefs.remove('name');
                                      });
                                      // Navigator.pushNamedAndRemoveUntil(
                                      //     context, '/signin', (route) => false);

                                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context){
                                        return Signin();
                                      }));

                                      Navigator.pop(context);

                                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context){
                                        return Signin();
                                      }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Color(0xFFF1e2324)),
                                          borderRadius: BorderRadius.all(Radius.circular(20))),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Yes',
                                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Color(0xFFF1e2324)),
                                          borderRadius: BorderRadius.all(Radius.circular(20))),
                                      backgroundColor: Colors.green,
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    leading: Icon(Icons.logout,size:MediaQuery.of(context).devicePixelRatio*10 ,),
                    title: Text('Logout',style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio*6),),),




                ],),
              )






            ],
          ),
        ),
      ),

    );
  }
}










//
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   double opacityLevel = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration(seconds: 1), () {
//       setState(() {
//         opacityLevel = 1.0;
//       });
//
//       Future.delayed(Duration(seconds: 2), () {
//         setState(() {
//           opacityLevel = 0.0;
//         });
//
//         Future.delayed(Duration(seconds: 1), () {
//           Navigator.of(context).pushReplacement(_customPageRoute(Transactions()));
//         });
//       });
//     });
//   }
//
//   PageRouteBuilder _customPageRoute(Widget page) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(position: offsetAnimation, child: child);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Hero(
//           tag: 'logo',
//           child: AnimatedOpacity(
//             opacity: opacityLevel,
//             duration: Duration(seconds: 1),
//             child: Image.asset('assets/images/logo.png'),
//           ),
//         ),
//       ),
//     );
//   }
// }
