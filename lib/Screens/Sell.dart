import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:number_to_indian_words/number_to_indian_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woolify/Widgets/verifySellingInfo.dart';

import '../Auth/signin.dart';
import '../main.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {



  void fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString('userid');
      email = prefs.getString('mail')==null?usermail:prefs.getString('mail');
      print(email);
      print(userid);
      print('anc');
    });
  }




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
            print(email);
          });
        }
      }
      // If email is null or not found, you can handle it here

    } catch (e) {
      print('Error: $e');

    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEmail();

    fetchUserId();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: (){
      //   if(selectedwooltosell!=null){
      //     Navigator.push(context, MaterialPageRoute(
      //       builder: (context) => SellProperties(selectedwooltosell),
      //     ));
      //   }
      // },child: Icon(Icons.arrow_forward,color: Colors.white,),backgroundColor: Colors.deepPurple),

      // body: Container(
      //   margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.height* 0.05),
      //
      //   child: Container(
      //
      //       height: MediaQuery.of(context).size.height*0.9,
      //       width: double.infinity,
      //       child: SellProperties('Angora wool')
      //
      //   ),
      // ),

      body: SellProperties('Angora wool'),

    );
  }
}












var selectedwooltosell = 'Angora wool';



class StateCityModel {
  String id;
  String type;
  String capital;
  String code;
  String name;
  List<dynamic> districts;

  StateCityModel({
    required this.id,
    required this.type,
    required this.capital,
    required this.code,
    required this.name,
    required this.districts,
  });

  factory StateCityModel.fromJson(Map<String, dynamic> json) {
    return StateCityModel(
      id: json['id'],
      type: json['type'],
      capital: json['capital'],
      code: json['code'],
      name: json['name'],
      districts: json['districts'],
    );
  }
}



class SellProperties extends StatefulWidget {
  final wooltype;
  SellProperties(this.wooltype);

  @override
  State<SellProperties> createState() => _SellPropertiesState();
}

class _SellPropertiesState extends State<SellProperties> {
  String countryValue = "India";
  String stateValue = "";
  String cityValue = "";
  String add = "";
  TextEditingController address= TextEditingController();
  TextEditingController landmark = TextEditingController();





  final otherwool = TextEditingController();
  List<String> woolTypes = [
    'Angora wool',
    'Merino wool',
    'Cashmere wool',
    'Lambswool',
    'Alpaca wool',
    'Mohair wool',
    'Camel wool',
    'Other'
  ];








  late String selectedValue;
  int quantityofwooltosell =0;
  int amountofwooltosell =0;
  int amountuserwillget=0;
  int platformamount =0;
  bool ispriceNegotiable =false;
  TextEditingController quantitytextfield = TextEditingController();
  TextEditingController amounttextfield = TextEditingController();
  String orderid="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantitytextfield=TextEditingController(text: quantityofwooltosell.toString());
    amounttextfield=TextEditingController(text: amountofwooltosell.toString());
    selectedValue =widget.wooltype;
    // platformamount = (amountofwooltosell*0.1) as int;
    // amountuserwillget = (amountofwooltosell - amountofwooltosell*0.1) as int;
    // selectedCity='India';
    fetchData();
    orderid = generateUniqueOrderId();
    fetchEmail();


  }




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


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),

        child: Container(
          margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.height* 0.03),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                  alignment: Alignment.center,

                  child: Text('Sell Your Wool',style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500,),)),
              SizedBox(height: MediaQuery.of(context).size.height*0.04,
              ),

              Container(
                  margin: EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height*0.007),
                  child: Text('Select the type of wool')),

              DropdownButtonHideUnderline(
                child: Card(

                  child: DropdownButton2<String>(
                    isExpanded: true,

                    items: woolTypes
                        .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      onTap: (){
                        setState(() {
                          selectedValue==item;
                          selectedwooltosell=item;
                        });
                      },

                      child: Text(

                        item,
                        style:  TextStyle(
                          fontSize: 14,
                          fontWeight: selectedValue==item?FontWeight.bold:null,
                          // color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    value: selectedValue,
                    style: TextStyle(color: Colors.black),
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value!;
                        selectedwooltosell =selectedValue;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: MediaQuery.of(context).size.height*0.06,
                      width: MediaQuery.of(context).size.width*1,
                      padding: EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        // border: Border.all(
                        //   // color: Colors.black26,
                        // ),
                        color: Color(0xFFFF7F2FA) ,
                      ),
                      // elevation: 2,
                    ),
                    iconStyleData:  IconStyleData(
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.black,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Colors.yellow,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: MediaQuery.of(context).size.height*0.3,
                      width: MediaQuery.of(context).size.width*0.79,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        // color: Colors.redAccent,
                      ),
                      offset: const Offset(0, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        interactive: true,

                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all<double>(6),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(

                      height: 40,
                      padding: EdgeInsets.only(left: 44, right: 14),
                    ),
                  ),
                ),
              ),



              selectedwooltosell=='Other'?Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03,),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.007),
                        child: Text('Write Other Type of wool here:')),

                    Container(
                      // decoration: BoxDecoration(
                      // color: Colors.white,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey,
                      //     offset: Offset(0.0, 1.0), //(x,y)
                      //     blurRadius: 6.0,
                      //   ),
                      // ],


                      // borderRadius: BorderRadius.horizontal(right: Radius.circular(17), left:Radius.circular(17) ),border: Border.all(color: Colors.black)),
                      child: Card(

                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(11), left:Radius.circular(11))),
                        child: TextFormField(
                          onChanged: (_){
                            setState(() {
                              selectedwooltosell=otherwool.text;

                            });
                          },
                          controller: otherwool,
                          decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              border: InputBorder.none,
                              prefix: Text('✏'),
                              hintText: ' Write Here ',
                              contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05,vertical: MediaQuery.of(context).size.height*0)
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ):Container(),



              SizedBox(height: MediaQuery.of(context).size.height*0.05,
                child: Divider(),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity per Kg'),
                  Card(

                      child: Container(

                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: (){

                                setState(() {
                                  if(quantityofwooltosell!=0){
                                    quantityofwooltosell=quantityofwooltosell-1;
                                    quantitytextfield.text=quantityofwooltosell.toString();


                                  }
                                });}, icon: Icon(CupertinoIcons.minus, )),

                              Container(
                                // margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),

                                // height: MediaQuery.of(context).size.height*0.05,
                                width: quantitytextfield.text.length<8?quantitytextfield.text.length<5? quantitytextfield.text.length<2?MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.1:quantitytextfield.text.length.toDouble() *10: MediaQuery.of(context).size.width*0.2,
                                child: TextFormField(
                                  onChanged: (_){
                                    setState(() {
                                      if(quantitytextfield.text==''){
                                        quantitytextfield.text='0';
                                      }else if (quantitytextfield.text.startsWith('0') &&  quantitytextfield.text.length>1) {
                                        quantitytextfield.text = quantitytextfield.text.substring(1,quantitytextfield.text.length); // Clear the text field if '0' is the only input
                                      }
                                      quantityofwooltosell=int.parse(quantitytextfield.text);
                                      print(quantitytextfield.text);
                                      print(quantityofwooltosell);
                                    });
                                  },
                                  controller: quantitytextfield,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(7), // Limit to 7 digits
                                  ],

                                  decoration: InputDecoration(border: InputBorder.none,

                                  ),

                                ),
                              ),
                              IconButton(onPressed: (){setState(() {
                                print(quantityofwooltosell);

                                quantityofwooltosell=quantityofwooltosell+1;
                                quantitytextfield.text=quantityofwooltosell.toString();


                              });}, icon: Icon(Icons.add),),

                            ]
                        ),
                      )),


                ],
              ),


              SizedBox(height: MediaQuery.of(context).size.height*0.03,),


              // SizedBox(height: MediaQuery.of(context).size.height*0.01,),




              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount (₹)"),
                  Card(



                      child: Container(

                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: (){setState(() {
                                if(amountofwooltosell!=0){
                                  amountofwooltosell=amountofwooltosell-1;
                                  amounttextfield.text=amountofwooltosell.toString();


                                }
                              });}, icon: Icon(CupertinoIcons.minus)),

                              Container(
                                // margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),


                                width: amounttextfield.text.length<8?amounttextfield.text.length<5? amounttextfield.text.length<2?MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.1:amounttextfield.text.length.toDouble() *10: MediaQuery.of(context).size.width*0.2,
                                child: TextFormField(
                                  onChanged: (_){
                                    setState(() {
                                      if(amounttextfield.text==''){
                                        amounttextfield.text='0';
                                      }else if (amounttextfield.text.startsWith('0') && amounttextfield.text.length>1 ) {
                                        amounttextfield.text = amounttextfield.text.substring(1,amounttextfield.text.length); // Clear the text field if '0' is the only input
                                      }
                                      amountofwooltosell=int.parse(amounttextfield.text);
                                      print(amounttextfield.text);
                                      print(amountofwooltosell);
                                    });
                                  },
                                  controller: amounttextfield,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8), // Limit to 7 digits
                                  ],

                                  decoration: InputDecoration(border: InputBorder.none,

                                  ),

                                ),
                              ),
                              IconButton(onPressed: (){setState(() {
                                print(amountofwooltosell);

                                amountofwooltosell=amountofwooltosell+1;
                                amounttextfield.text=amountofwooltosell.toString();



                              });}, icon: Icon(Icons.add),),



                            ]
                        ),
                      )),


                ],
              ),





              SizedBox(height: MediaQuery.of(context).size.height*0.04,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount in Words: '),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(NumToWords.convertNumberToIndianWords(amountofwooltosell),overflow: TextOverflow.clip,),
                    ),
                  )
                ],
              ),


              SizedBox(height: MediaQuery.of(context).size.height*0.02,),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.all(0), // Set the margin to zero

                    child: Checkbox(


                        value: ispriceNegotiable, onChanged: (_){

                      setState(() {
                        ispriceNegotiable=!ispriceNegotiable;

                      });
                    }),
                  ),

                  Expanded(child: Text('Is this price Negotiable?'))
                ],
              ),





              SizedBox(height: MediaQuery.of(context).size.height*0.04,
                child: Divider(),
              ),

              SizedBox(height: MediaQuery.of(context).size.height*0.017,),


              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Pick Up Location  ',style: TextStyle(fontWeight: FontWeight.bold),),
                      // Icon(Icons.location_on_outlined,color: Colors.black,),
                      Image.asset('assets/images/india.png',height: MediaQuery.of(context).size.height*0.03,)

                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height*0.04,),

                  Text('Address'),
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







                  SizedBox(height: MediaQuery.of(context).size.height*0.013,),

                  Text('Landmark'),
                  SizedBox(height: MediaQuery.of(context).size.height*0.008,),


                  Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),
                      child: TextFormField(
                        controller: landmark,
                        maxLines: 1,

                        // minLines: 1,


                        // maxLength: 40,
                        decoration: InputDecoration(
                            border: InputBorder.none
                        ),

                      ),
                    ),
                  ),














                  SizedBox(height: MediaQuery.of(context).size.height*0.02,),

                  Text('State and city'),

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


              SizedBox(height: MediaQuery.of(context).size.height*0.04,
                child: Divider(),),

              SizedBox(height: MediaQuery.of(context).size.height*0.02,),





              Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white
                      ),
                      onPressed: () async {

                        if(selectedwooltosell=='Other' || selectedwooltosell==null){
                          final snackBar = SnackBar(
                            content: Text('No Wool Selected'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }

                        else if(quantityofwooltosell<10){
                          final snackBar = SnackBar(
                            content: Text('Quantity can\'t be less than 10 Kg'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }


                        else if(amountofwooltosell==0){
                          final snackBar = SnackBar(
                            content: Text('Amount Can\'t be 0'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }

                        else if(address.text==''){
                          final snackBar = SnackBar(
                            content: Text('Address can\'t be empty'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }

                        else if(selectedState==null){
                          final snackBar = SnackBar(
                            content: Text('State not selected'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        else if(selectedCity==null){
                          final snackBar = SnackBar(
                            content: Text('City not selected'),);


                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        else{

                          print(selectedwooltosell);

                          print(orderid);
                          print(orderid);
                          print(userid);
                          print(usermail);
                          SharedPreferences prefs = await SharedPreferences.getInstance();


                          fetchEmail();


                          print(email);
                          print(email);
                          print(email);
                          print(email);
                          print(email);

                          print(email);



                          // print()


                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => verifySellingInfo(email, ispriceNegotiable, selectedwooltosell, quantityofwooltosell, amountofwooltosell,amountofwooltosell -amountofwooltosell*0.01, amountofwooltosell*0.01, address.text, landmark.text, selectedState, selectedCity,orderid,userid)));
                        }

                      }, child: Text('Proceed to verify'))),



              SizedBox(height: MediaQuery.of(context).size.height*0.02,),


            ],
          ),





        ),
      ),
    );
  }
  List<dynamic> getSelectedStateCities() {
    StateCityModel selectedStateModel = stateCityData.firstWhere((state) => state.name == selectedState);
    return selectedStateModel.districts;
  }


  String generateUniqueOrderId()  {

    // Fetch the list of order IDs for the specified user


    String randomOrderId;


    // Generate a random 11-digit number
    randomOrderId = (1000000000 + Random().nextInt(900000000)).toString();
    // Keep generating until it's unique

    return randomOrderId;
  }



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

}