import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Home/home.dart';

import '../Screens/profile.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


Future<List<Map<String, dynamic>>> getAllDataFromCollection(
    String collectionPath) async {
  final QuerySnapshot snapshot =
  await FirebaseFirestore.instance.collection(collectionPath).orderBy('time',descending: true).get();

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




class _ProfileScreenState extends State<ProfileScreen> {



  var selectedphoto;
  var selectedphotocolor;
  List<String> assetImageList = [
    'assets/images/p1.png',
    'assets/images/p2.png',
    'assets/images/p3.png',
    'assets/images/p4.png',
    'assets/images/p5.png',
    'assets/images/p6.png',
    'assets/images/p7.png',
    'assets/images/p8.png',
    'assets/images/p9.png',
    'assets/images/p10.png',
    'assets/images/p11.png',
    'assets/images/p12.png',
    'assets/images/p13.png',
    'assets/images/p14.png',
    'assets/images/p15.png',
    'assets/images/p16.png',
    'assets/images/p17.png',
    'assets/images/p18.png',
    'assets/images/p19.png',
    'assets/images/p20.png',
    'assets/images/p21.png',
    'assets/images/p22.png',
  ];

  var id;


  // loadProfilePhoto();
  Future<List<Map<String, dynamic>>>? _futureData;

  @override
  void initState() {
    super.initState();
    // loadProfilePhoto(selectedphoto);

    id= userid;
    print(id);
    _futureData = getAllDataFromCollection('users');

    // print(profilephoto);
  }

  var useridd;

  // void loadProfilePhoto(String imge) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   String? savedProfilePhoto = prefs.getString('profilephoto');
  //
  //
  //     selectedphoto = savedProfilePhoto!;
  //
  //
  //     prefs.setString('profilephoto', savedProfilePhoto!);
  //
  //   useridd = prefs.getString('userid');
  // }







  late String documentId;
  Future<void> addprofiletodatabase() async {



    String documentId = userid;
    print(useridd);
    DocumentReference users = FirebaseFirestore.instance.collection('users').doc(id);
    // documentId = users.id;
    // userid = documentId;r
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('userid', documentId);


    // print(_drivelink);
    // Call the user's CollectionReference to add a new user
    return users
        .update({
      'profilephotopath': selectedphoto,



    })
        .then((value) => print("profile photo added Added"))
        .catchError((error) => print("Failed to add user: $error"));

  }


  Future<DocumentSnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    // Replace 'your_collection' and 'your_document_id' with the appropriate values
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();
  }








  Future<void> addprofilecolortodatabase() async {



    String documentId = userid;
    print(useridd);
    DocumentReference users = FirebaseFirestore.instance.collection('users').doc(id);
    // documentId = users.id;
    // userid = documentId;r
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString('userid', documentId);


    // print(_drivelink);
    // Call the user's CollectionReference to add a new user
    return users
        .update({
      'profilephotocolor': selectedphotocolor,



    })
        .then((value) => print("profile photo added Added"))
        .catchError((error) => print("Failed to add user: $error"));

  }


  // Future<DocumentSnapshot<Map<String, dynamic>>> getDataFromFirestore() {
  //   // Replace 'your_collection' and 'your_document_id' with the appropriate values
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(id)
  //       .get();
  // }
  //



  @override
  Widget build(BuildContext context) {
    print(selectedphoto);
    print(profilephoto);
    final screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    final crossAxisCount = screenWidth < 370 ? 3 : screenWidth < 900 ? 4 : 5;


    Future<void> _refreshData() async {
      // Perform a refresh operation here, such as fetching new data from an API.
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _futureData;
      });
    }

    return Scaffold(
        appBar: AppBar(
          // backgroundColor: Color(0xFFF1e2324),
          elevation: 0,
          // leading: IconButton(
          //   onPressed: (){
          //     Navigator.pop(context);
          //   },
          //   icon: Icon(CupertinoIcons.xmark,color: CupertinoColors.white,),
          // ),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getDataFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data();
              final name = data!['name'];
              final email = data['email'];
              final profile = data!['profilephotopath'];
              final profilecolor = data!['profilephotocolor'];
              // selectedphoto = profile;


              return
                Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                        child: GestureDetector(
                          onTap: (){

                          },
                          child:


                          Container(
                              padding: EdgeInsets.all(35),
                              // color: Colors.greenAccent,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedphotocolor==null?profilecolor==null?Colors.greenAccent:profilecolor:selectedphotocolor,
                              ),
                              child: Image.asset(selectedphoto==null?profile==null?'assets/images/noprofile.png':profile:selectedphoto,height: MediaQuery.of(context).devicePixelRatio*50,)),
                        ),
                      ),

                      Container(margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height*0.025,),child: Divider(color: Colors.blueGrey,),),


                      Expanded(
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          padding: EdgeInsets.all(16),
                          children: assetImageList.map((imagePath) {
                            return GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedphoto=imagePath;

                                });
                              },
                              child: Container(
                                // padding: EdgeInsets.symmetric(horizontal: 7,vertical: 10),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      height: MediaQuery.of(context).devicePixelRatio*25,

                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 10),

                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [




                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child: GestureDetector(
                              onTap: (){

                                setState(() {
                                  selectedphotocolor=Colors.greenAccent;

                                });

                              },
                              child:


                              Container(
                                padding: EdgeInsets.all(30),
                                // color: Colors.greenAccent,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child: GestureDetector(
                              onTap: (){

                                setState(() {
                                  selectedphotocolor=Colors.purple;

                                });

                              },
                              child:


                              Container(
                                padding: EdgeInsets.all(30),
                                // color: Colors.greenAccent,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.purple,
                                ),
                              ),
                            ),),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  selectedphotocolor=Colors.white;

                                });

                              },
                              child:


                              Container(
                                padding: EdgeInsets.all(30),
                                // color: Colors.greenAccent,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),),


                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              margin: EdgeInsets.all(27),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Color(0xFFF1e2324)),
                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                    backgroundColor: Color(0xFFF223847),
                                  ),
                                  onPressed: () async {

                                    SharedPreferences prefs = await SharedPreferences.getInstance();


                                    print(selectedphoto);
                                    // prefs.reload();
                                    // prefs.remove('profilephoto');
                                    // prefs.setString('profilephoto', selectedphoto);


                                    // loadProfilePhoto(selectedphoto);

                                    if(selectedphotocolor==null){
                                      setState(() {
                                        selectedphotocolor=Colors.greenAccent;
                                      });

                                    }



                                    addprofiletodatabase();
                                    addprofilecolortodatabase();

                                    print(profilephoto);
                                    setState(() {
                                      selectedIndex=4;
                                    });

                                    Navigator.pop(context);

                                    // Navigator.pop(context);

                                    Navigator.pushReplacement(context, MaterialPageRoute(
                                      builder: (context) {
                                        return Home();
                                      }),
                                    );
                                    //
                                    // // In the parent screen
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()))
                                    //     .then((result) {
                                    //   // Handle the result or trigger screen reload/update here
                                    //   if (result != null) {
                                    //     // Handle the result from the child screen if needed
                                    //   }
                                    //   // Reload or update the screen as needed
                                    //   setState(() {
                                    //     // Update the necessary variables or data
                                    //   });
                                    // });




                                  }, child: Text('Save',style: TextStyle(fontSize:  MediaQuery.of(context).devicePixelRatio*6),)
                              ),
                            ),




                          ),
                        ],
                      )


                    ],
                  ),
                )
              ;
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        )






      //   Container(
      //     width: double.infinity,
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         ClipRRect(
      //           borderRadius: BorderRadius.all(Radius.circular(60)),
      //           child: GestureDetector(
      //             onTap: (){
      //
      //             },
      //             child:
      //
      //
      //             Container(
      //                 padding: EdgeInsets.all(35),
      //                 // color: Colors.greenAccent,
      //                 decoration: BoxDecoration(
      //                   shape: BoxShape.circle,
      //                   color: Colors.greenAccent,
      //                 ),
      //                 child: Image.asset(selectedphoto==null?'assets/images/p2.png':selectedphoto,height: MediaQuery.of(context).devicePixelRatio*50,)),
      //           ),
      //         ),
      //
      //         Container(margin: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height*0.025,),child: Divider(color: Colors.blueGrey,),),
      //
      //
      //         Expanded(
      //           child: GridView.count(
      //             crossAxisCount: crossAxisCount,
      //             padding: EdgeInsets.all(16),
      //             children: assetImageList.map((imagePath) {
      //               return GestureDetector(
      //                 onTap: (){
      //                   setState(() {
      //                     selectedphoto=imagePath;
      //
      //                   });
      //                 },
      //                 child: Container(
      //                   // padding: EdgeInsets.symmetric(horizontal: 7,vertical: 10),
      //                   child: Column(
      //                     children: [
      //                       Image.asset(
      //                         imagePath,
      //                         fit: BoxFit.cover,
      //                         height: MediaQuery.of(context).devicePixelRatio*25,
      //
      //                       ),
      //                       Container(
      //                         padding: EdgeInsets.symmetric(vertical: 10),
      //
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //               );
      //             }).toList(),
      //           ),
      //         ),
      //
      //         Align(
      //           alignment: Alignment.bottomRight,
      //           child: Container(
      //             margin: EdgeInsets.all(27),
      //             child: ElevatedButton(
      //                 style: ElevatedButton.styleFrom(
      //                   shape: RoundedRectangleBorder(
      //                       side: BorderSide(color: Color(0xFFF1e2324)),
      //                       borderRadius: BorderRadius.all(Radius.circular(20))),
      //                   backgroundColor: Color(0xFFF223847),
      //                 ),
      //                 onPressed: () async {
      //
      //               SharedPreferences prefs = await SharedPreferences.getInstance();
      //
      //
      //               print(selectedphoto);
      //               // prefs.reload();
      //               // prefs.remove('profilephoto');
      //               // prefs.setString('profilephoto', selectedphoto);
      //
      //
      //               // loadProfilePhoto(selectedphoto);
      //
      //
      //
      //               addprofiletodatabase();
      //
      //               print(profilephoto);
      //
      //               // Navigator.pop(context);
      //               // Navigator.pop(context);
      //               // // Navigator.pushNamed(context,'profilephoto');
      //               //
      //               // // In the parent screen
      //               // Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()))
      //               //     .then((result) {
      //               //   // Handle the result or trigger screen reload/update here
      //               //   if (result != null) {
      //               //     // Handle the result from the child screen if needed
      //               //   }
      //               //   // Reload or update the screen as needed
      //               //   setState(() {
      //               //     // Update the necessary variables or data
      //               //   });
      //               // });
      //
      //
      //
      //                 }, child: Text('Save',style: TextStyle(fontSize:  MediaQuery.of(context).devicePixelRatio*6),)
      // ),
      //           ),
      //
      //
      //
      //
      //         )
      //
      //
      //       ],
      //     ),
      //   ),




    );
  }
}
