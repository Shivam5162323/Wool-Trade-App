import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Home/delivery.dart';
import 'package:woolify/Screens/Sell.dart';
import 'package:woolify/Screens/buy.dart';
import 'package:woolify/Screens/govtMSPuploader.dart';
import 'package:woolify/Screens/graph.dart';
import 'package:woolify/Screens/learn.dart';
import 'package:woolify/Screens/profile.dart';
import 'package:woolify/Screens/warehouse.dart';
import 'package:woolify/Widgets/allnotifications.dart';
import 'package:woolify/Widgets/verifySellingInfo.dart';

import '../Auth/signin.dart';
import '../Screens/orders.dart';
import '../main.dart';

void resetNotifCount(String userId) async {
  try {
    // Get a reference to the Firestore collection 'users'
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Get a reference to the user's document
    DocumentReference userDocRef = users.doc(userId);

    // Update the notifcount to 0
    await userDocRef.update({'notifcount': 0});

    print('Notifcount reset successfully.');
  } catch (e) {
    print('Error: $e');
  }
}

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userid');
}





class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}
int selectedIndex = 2;
class _HomeState extends State<Home> {


  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? "";
    userid = prefs.getString('userid');
    setState(() {
      _email = email;
    });
  }


  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid');
      email = prefs.getString('mail');
    });
  }


  bool isGovInEmail() {
    return firstmail==null?_email.endsWith('.gov.in'):firstmail.endsWith('.gov.in');
  }


  final _auth = FirebaseAuth.instance;

  String _email = "";


  static List<Widget> _widgetOptions = <Widget>[SellScreen(),BuyScreen(),GraphScreen(),MapScreen(),Settingss()];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  Widget logout() {
    return ElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.black38,
                // backgroundColor: Color(0xFFF062121),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(color: Colors.white),
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
                        prefs.remove('email');
                        prefs.remove('userid');
                        prefs.remove('name');
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context, '/signin', (route) => false);

                        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (BuildContext context){
                          return Signin();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Yes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      child: Text(
                        'No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Colors.green,
                      ),
                    )
                  ],
                ),
              );
            });
      },
      child: Text('Logout'),
    );
  }

  bool isSearching = false;

  var selecteddrawertile=0;






  void _openBottomSheet(
      ) {




    showModalBottomSheet(
      context: context,
      builder: (_) => WoolPriceUploader(),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchUserId();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Woolify'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        bottomOpacity: 0.3,
        actions: [

          // isGovInEmail()?GestureDetector(
          //
          //     child: I):SizedBox(),


          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(userid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // or a loading indicator
              }

              int notificationCount = snapshot.data!.get('notifcount') ?? 0;

              // If notifcount is not present, create it and set to 0
              if (notificationCount == null) {
                FirebaseFirestore.instance.collection('users').doc(userid).set({'notifcount': 0}, SetOptions(merge: true));
                notificationCount = 0;
              }

              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$notificationCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  // Reset notifcount
                   resetNotifCount(userid);

                  // Navigate to AllNotifications
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllNotifications()),
                  );
                },
              );
            },
          )

          ,

          // IconButton(onPressed: (){
          //   resetNotifCount(userid);
          //
          //   Navigator.push(
          //       context, MaterialPageRoute(builder: (context) {
          //     return  AllNotifications();
          //
          //   }));
          //
          // }, icon: Icon(Icons.notifications)),
          isGovInEmail()?Container(
            // width: MediaQuery.of(context).size.width*0.07,
            // height: MediaQuery.of(context).size.width*0.07,
            child: TextButton(onPressed:  (){
      _openBottomSheet();
    },
                child: Image.asset('assets/images/lionindia.png',color: Colors.black,height: MediaQuery.of(context).size.height*0.04,)),
          ):SizedBox(),

    // Image.asset('assets/images/lionindia.png',color: Colors.white,height: MediaQuery.of(context).size.height*0.09,)
        ],
        // shadowColor: Colors.transparent,
        // toolbarOpacity: 0.5,

      ),
      body: _widgetOptions.elementAt(selectedIndex),




      //
      // endDrawer: Drawer(
      //
      //   child: Container(
      //     // color: Colors.white,
      //     padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.075),
      //     child: Column(
      //       children: [
      //         // Card()
      //
      //         // Image.asset(name)
      //
      //         Text('Woolify',style: TextStyle(fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.height*0.04,color: Color(0xFFFd9e0ff)),),
      //         SizedBox(height: MediaQuery.of(context).size.height*0.02,),
      //
      //
      //         // Card(
      //         //   child: Column(
      //         //     children: [
      //         //       Row(children: [
      //         //         Text('Total Earnings: '),
      //         //         Text('₹77777 ')
      //         //       ],),
      //         //       Row(children: [
      //         //         Text('Total Expenses: '),
      //         //         Text('₹11111 ')
      //         //       ],)
      //         //     ],
      //         //   ),
      //         // ),
      //
      //         Card(
      //           // color: Colors.black,
      //           color: selecteddrawertile==0?Colors.black87:Colors.white,
      //
      //           elevation: selecteddrawertile==0?2:0,
      //
      //           child: ListTile(
      //             leading: Icon(Icons.rocket_launch,color: selecteddrawertile==0?Colors.white:Colors.black87,),
      //             title: Text('Items on sell',style: TextStyle(color: selecteddrawertile==0?Colors.white:Colors.black87),),
      //
      //             onTap: (){
      //               setState(() {
      //                 selecteddrawertile=0;
      //
      //               });
      //
      //               Navigator.push(
      //                   context, MaterialPageRoute(builder: (context) =>SellOrders()
      //
      //               ));
      //             },
      //
      //           ),
      //         ),
      //
      //         Card(
      //           color: selecteddrawertile==1?Colors.black87:null,
      //           elevation: 0,
      //           child: ListTile(
      //             leading: Icon(CupertinoIcons.cube_box_fill,color: selecteddrawertile==1?Colors.white:Colors.black87,),
      //             title: Text('Orders',style: TextStyle(color: selecteddrawertile==1?Colors.white:Colors.black87),),
      //
      //             onTap: (){
      //               setState(() {
      //                 selecteddrawertile=1;
      //
      //
      //
      //
      //               });
      //               Navigator.push(
      //                   context, MaterialPageRoute(builder: (context) =>BuyOrders()));
      //             },
      //
      //           ),
      //         ),
      //         Card(
      //           color: selecteddrawertile==2?Colors.black87:Colors.white,
      //           elevation: 0,
      //           child: ListTile(
      //             leading: Icon(CupertinoIcons.cube_box_fill,color: selecteddrawertile==2?Colors.white:Colors.black87,),
      //             title: Text('Orders',style: TextStyle(color: selecteddrawertile==2?Colors.white:Colors.black87),),
      //
      //             onTap: (){
      //               setState(() {
      //                 selecteddrawertile=2;
      //               });
      //             },
      //
      //           ),
      //         ),
      //
      //         ListTile(
      //           leading: Icon(CupertinoIcons.cube_box),
      //           title: Text('Orders'),
      //
      //           onTap: (){},
      //
      //         ),
      //
      //         logout(),
      //       ],
      //     ),
      //   ),
      // ),





      bottomNavigationBar: SnakeNavigationBar.color(


        backgroundColor: Colors.black,
        // currentIndex: _selectedIndex,
        snakeShape: SnakeShape.rectangle,
        selectedItemColor: Colors.white,
        showSelectedLabels: true,
        height: MediaQuery.of(context).devicePixelRatio*23,


        snakeViewColor: Colors.black,

          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },



        items: [




          BottomNavigationBarItem(

            backgroundColor: Colors.blue,
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.currency_rupee,
                color: Colors.white,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(Icons.currency_rupee, color: Colors.white),
            ),

            label: 'Sell',

          ),

        BottomNavigationBarItem(


              icon: Container(

                  padding: EdgeInsets.only(bottom: 5),
                  child: Icon(CupertinoIcons.bag,color: Colors.white,)),
              activeIcon: Container(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Icon(CupertinoIcons.bag_fill)),
              label: 'Buy',
              // backgroundColor: Color(0xFFF07191f)
            ),


            BottomNavigationBarItem(

              backgroundColor: Colors.blue,
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Icon(
                  CupertinoIcons.graph_circle,
                  color: Colors.white,
                ),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Icon(CupertinoIcons.graph_circle_fill, color: Colors.white),
              ),

              label: 'Price',

            ),
            BottomNavigationBarItem(

                // backgroundColor: Colors.blue,
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'Map',
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Icons.map,
                    color: Colors.white,
                  ),
                )
                ),




          BottomNavigationBarItem(

            backgroundColor: Colors.blue,
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(
                Icons.person_2_outlined,
                color: Colors.white,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(Icons.person, color: Colors.white),
            ),

            label: 'Profile',


          ),









          // if(isGovInEmail() ) ...[
          //   BottomNavigationBarItem(
          //
          //     backgroundColor: Colors.blue,
          //     icon: Padding(
          //       padding: EdgeInsets.only(bottom: 5),
          //       child: Image.asset('assets/images/lionindia.png',color: Colors.white,height: MediaQuery.of(context).size.height*0.04,),
          //     ),
          //     activeIcon: Padding(
          //       padding: EdgeInsets.only(bottom: 5),
          //       child: Image.asset('assets/images/lionindia.png',color: Colors.white,height: MediaQuery.of(context).size.height*0.03,),
          //     ),
          //
          //     label: 'MSP',
          //
          //   ),

          // ]



        ],
      )


































      ,
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black,
      //
      //
      //   unselectedItemColor: Colors.blueGrey,
      //
      //   showUnselectedLabels: true,
      //   showSelectedLabels: false,
      //   enableFeedback: false,
      //
      //
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      //
      //
      //   type: BottomNavigationBarType.fixed,
      //   elevation: 0,
      //   selectedFontSize: 14,
      //   unselectedFontSize: 14,
      //
      //
      //   selectedItemColor: Colors.white,
      //   iconSize: 29,
      //   items: [
      //     BottomNavigationBarItem(
      //
      //       icon: Container(
      //           padding: EdgeInsets.only(bottom: 5),
      //           child: Icon(CupertinoIcons.bag)),
      //       activeIcon: Container(
      //           padding: EdgeInsets.only(bottom: 5),
      //           child: Icon(CupertinoIcons.bag_fill)),
      //       label: 'Buy',
      //       // backgroundColor: Color(0xFFF07191f)
      //     ),
      //     BottomNavigationBarItem(
      //
      //       backgroundColor: Colors.blue,
      //       icon: Padding(
      //         padding: EdgeInsets.only(bottom: 5),
      //         child: Icon(
      //           CupertinoIcons.house,
      //           color: Colors.white,
      //         ),
      //       ),
      //       activeIcon: Padding(
      //         padding: EdgeInsets.only(bottom: 5),
      //         child: Icon(CupertinoIcons.house_fill, color: Colors.white),
      //       ),
      //
      //       label: 'Home',
      //
      //     ),
      //     BottomNavigationBarItem(
      //
      //         // backgroundColor: Colors.blue,
      //         icon: Padding(
      //           padding: EdgeInsets.only(bottom: 5),
      //           child: Icon(
      //             Icons.factory_outlined,
      //             color: Colors.white,
      //           ),
      //         ),
      //         label: 'Warehouse',
      //         activeIcon: Padding(
      //           padding: EdgeInsets.only(bottom: 5),
      //           child: Icon(
      //             Icons.factory,
      //             color: Colors.white,
      //           ),
      //         )
      //         ),
      //   ],
      // ),

    );
  }
}

class dummy1 extends StatefulWidget {
  const dummy1({super.key});

  @override
  State<dummy1> createState() => _dummy1State();
}

class _dummy1State extends State<dummy1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class dummy2 extends StatefulWidget {
  const dummy2({super.key});

  @override
  State<dummy2> createState() => _dummy2State();
}

class _dummy2State extends State<dummy2> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [

        

      ],),
    );
  }
}

class dummy3 extends StatefulWidget {
  const dummy3({super.key});

  @override
  State<dummy3> createState() => _dummy3State();
}

class _dummy3State extends State<dummy3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(



    );
  }
}










// class addmspnowmodalsheet extends StatefulWidget {
//   const addmspnowmodalsheet({super.key});
//
//   @override
//   State<addmspnowmodalsheet> createState() => _addmspnowmodalsheetState();
// }

// class _addmspnowmodalsheetState extends State<addmspnowmodalsheet> {
//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }
