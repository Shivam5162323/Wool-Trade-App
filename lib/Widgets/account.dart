import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Widgets/profilephoto.dart';

import '../Auth/signin.dart';
import '../Screens/Sell.dart';
import '../Screens/buy.dart';
import '../main.dart';
class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  var profileimage2;
  var id;


  TextEditingController address= TextEditingController();
  TextEditingController landmark = TextEditingController();

  List<StateCityModel> stateCityData = [];
  String? selectedState;
  String? selectedCity;



  Future<String> loadJsonData() async {
    return await rootBundle.loadString('assets/state-districts.json');
  }

  void fetchData() async {
    String jsonString = await loadJsonData();
    final List<dynamic> parsedJson = jsonDecode(jsonString)['states'];
    setState(() {
      stateCityData = parsedJson.map((json) => StateCityModel.fromJson(json)).toList();
    });
  }

  List<dynamic> getSelectedStateCities() {
    StateCityModel selectedStateModel = stateCityData.firstWhere((state) => state.name == selectedState);
    return selectedStateModel.districts;
  }

  @override
  void initState() {
    fetchData();
    super.initState();
    id = userid;
    print(id);

    _futureData = getAllDataFromCollection('users');
  }

  Future<List<Map<String, dynamic>>>? _futureData;

  Future<DocumentSnapshot<Map<String, dynamic>>> getDataFromFirestore() {
    return FirebaseFirestore.instance.collection('users').doc(userid == null ? firstuid : userid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          setState(() {});
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(17))
            ),
            width: double.infinity,
            padding: EdgeInsets.all(20),
            // height: MediaQuery.of(context).size.height*0.75,
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: getDataFromFirestore(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            // Handle error
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.data() == null) {
                            return SizedBox();
                          }

                          final data = snapshot.data!.data();
                          final mail = data!['email'];
                          final profile = data!['profilephotopath'];
                          final name = data!['name'];
                          final cardphone = data!['phone'];
                          final address = data!['address'];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.05),


                              Center(
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(60)),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => ProfileScreen(),
                                          ));
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.greenAccent,
                                          ),
                                          child: Image.asset(
                                            profile == null ? 'assets/images/noprofile.png' : profile,
                                            height: MediaQuery.of(context).devicePixelRatio * 20,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),


                                    Container(
                                      // margin: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.03),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalize(name),
                                            style: TextStyle(fontSize: MediaQuery.of(context).devicePixelRatio * 7),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.04,),

                              Row(
                                children: [
                                  Icon(Icons.email),
                                  Text('  Email'),
                                ],
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),


                              Card(
                                child: ListTile(
                                  // leading: Icon(Icons.email),
                                  // title: Text('Email'),
                                  title: Text(mail ?? 'Not available'),
                                ),
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.03,),

                              Row(
                                children: [
                                  Icon(Icons.phone),
                                  Text('  Phone no.'),
                                ],
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.01,),



                              Card(
                                child: ListTile(
                                  // leading: Icon(Icons.phone),
                                  // title: Text('Phone'),
                                  title: Text(cardphone ?? 'Not available'),
                                ),
                              ),

                              SizedBox(height: MediaQuery.of(context).size.height*0.03,),




                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.start,
                                  //   children: [
                                  //     Text('Pick Up Location  ',style: TextStyle(fontWeight: FontWeight.bold),),
                                  //     // Icon(Icons.location_on_outlined,color: Colors.black,),
                                  //     Image.asset('assets/images/india.png',height: MediaQuery.of(context).size.height*0.03,)
                                  //
                                  //   ],
                                  // ),

                                  // SizedBox(height: MediaQuery.of(context).size.height*0.04,),

                                  Row(
                                    children: [
                                      Icon(Icons.location_on),
                                      Text('  Address'),
                                    ],
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),


                                  Card(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),
                                      child: TextFormField(
                                        controller: address,
                                        maxLines: null,

                                        // minLines: 1,

                                        maxLength: 100,
                                        decoration: InputDecoration(
                                            border: InputBorder.none
                                        ),

                                      ),
                                    ),
                                  ),




                                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),

                                  Row(
                                    children: [
                                      Icon(Icons.maps_home_work),
                                      Text('  State and city'),
                                    ],
                                  ),

                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),


                                  Row(
                                    children: [
                                      Expanded(
                                        child: Card(
                                          child: DropdownButton(
                                            isExpanded: true,
                                            value: selectedState,
                                            underline: SizedBox(),

                                            // style: TextStyle(overflow: TextOverflow.ellipsis),
                                            hint: Text('Select Your State',style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black),),
                                            // borderRadius: BorderRadius.zero,
                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.03),
                                            menuMaxHeight:  MediaQuery.of(context).size.height*0.45,
                                            borderRadius: BorderRadius.all(Radius.circular(11)),
                                            style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.black),

                                            onChanged: (String? newState) {
                                              setState(() {
                                                selectedState = newState!;
                                                selectedCity = null;
                                              });
                                            },
                                            items: stateCityData.map((StateCityModel state) {
                                              return DropdownMenuItem<String>(

                                                value: state.name,
                                                child: Text(state.name),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),

                                      // SizedBox(),





                                      if (selectedState != null)
                                        Expanded(
                                          child: Card(
                                            child: DropdownButton(
                                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.03),
                                              menuMaxHeight:  MediaQuery.of(context).size.height*0.45,
                                              isExpanded: true,
                                              hint: Text('Select City',style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black),),
                                              underline: SizedBox(),

                                              borderRadius: BorderRadius.all(Radius.circular(11)),
                                              style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color: Colors.black),

                                              value: selectedCity,
                                              onChanged: (String? newCity) {
                                                setState(() {
                                                  selectedCity = newCity;
                                                });
                                              },
                                              items: getSelectedStateCities().map((dynamic city) {
                                                return DropdownMenuItem<String>(
                                                  value: city['name'],
                                                  child: Text(city['name']),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),




                                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),


                                ],
                              ),


                            ],
                          );
                        },
                      ),
                      ElevatedButton(onPressed: (){},
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                          child: Text('Update Information',style: TextStyle(color: Colors.white),))

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}