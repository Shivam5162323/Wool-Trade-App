import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:number_to_indian_words/number_to_indian_words.dart';

class WoolPriceUploader extends StatefulWidget {
  @override
  State<WoolPriceUploader> createState() => _WoolPriceUploaderState();
}

class _WoolPriceUploaderState extends State<WoolPriceUploader> {
  final TextEditingController amounttextfield = TextEditingController();
  var amountofwooltosell=0;

  List<String> woolTypes = [
    'Angora wool',
    'Merino wool',
    'Cashmere wool',
    'Lambswool',
    'Alpaca wool',
    'Mohair wool',
    'Camel wool',
  ];
  void updateMSP() async {
    String selectedWool = selectedWoolType;
    // int price = int.parse(priceController.text);
    int price = amountofwooltosell;

    // Reference to Firestore collection and document
    CollectionReference woolCollection = FirebaseFirestore.instance.collection('wool');
    DocumentReference woolDocument = woolCollection.doc(selectedWoolType);

    // Get current timestamps
    List<String> timestamps = [];
    DocumentSnapshot woolSnapshot = await woolDocument.get();
    dynamic data = woolSnapshot.data();
    if (data != null && data['timestamps'] is List<dynamic>) {
      timestamps = List<String>.from(data['timestamps']);
    }

    // Create a new timestamp (use a unique identifier or date/time)
    String newTimestamp = DateTime.now().toString();

    // Update timestamps array
    timestamps.add(newTimestamp);

    // Update the timestamps array in Firestore
    await woolDocument.set({'timestamps': timestamps}, SetOptions(merge: true));

    // Create a new document under pricemap with the timestamp as its name
    DocumentReference priceMapDocument = woolDocument.collection('pricemap').doc(newTimestamp);

    // Set the price and time
    await priceMapDocument.set({
      'price':   amountofwooltosell,
      'time': newTimestamp,
    });

    // Clear the price input field after upload
    setState(() {
      amountofwooltosell=0;
      amounttextfield.clear();
      amounttextfield.text='0';
    });
  }


  var selectedWoolType;

  @override
  void initState() {
    // TODO: implement initState
    selectedWoolType = woolTypes[0];
    super.initState();
    amounttextfield.text='0';
  }

  @override
  Widget build(BuildContext context) {


    return
   Container(

          child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [


              SizedBox(height: MediaQuery.of(context).size.height*0.01,
              ),

              Container(
                  alignment: Alignment.center,

                  child: Text('Wool MSP Uploader',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600,),)),


              SizedBox(height: MediaQuery.of(context).size.height*0.05,
              ),
              Container(
                // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.07),
                  alignment: Alignment.centerLeft,

                  child: Text('Select a Wool Type',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,),)),
              SizedBox(height: MediaQuery.of(context).size.height*0.01,
              ),



              Card(
                // color: Color(0xFFFF7F2FA) ,
                elevation: 3,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,

                    items: woolTypes
                        .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      onTap: (){
                        setState(() {
                          selectedWoolType = item;

                        });
                      },

                      child: Text(

                        item,
                        style:  TextStyle(
                          fontSize: 14,
                          fontWeight: selectedWoolType==item?FontWeight.bold:null,
                          // color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    value: selectedWoolType,
                    style: TextStyle(color: Colors.black),
                    onChanged: (String? value) {
                      setState(() {
                        selectedWoolType = value!;
                        // selectedwooltosell =selectedValue;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: MediaQuery.of(context).size.height*0.06,
                      width: MediaQuery.of(context).size.width*0.9,
                      padding: EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        // border: Border.all(
                        //   // color: Colors.black26,
                        // ),
                        // color: Color(0xFFFF7F2FA) ,
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
                      width: MediaQuery.of(context).size.width*0.9,
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

              // Card(
              //   child: Container(
              //     margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1),
              //     child: DropdownButton(
              //       elevation: 0,
              //       underline: SizedBox(),
              //       value: selectedWoolType,
              //       items: woolTypes.map((woolType) {
              //         return DropdownMenuItem(
              //           value: woolType,
              //           child: Text(woolType),
              //         );
              //       }).toList(),
              //       onChanged: (newValue) {
              //         setState(() {
              //           selectedWoolType = newValue;
              //         });
              //       },
              //     ),
              //   ),
              // ),

              // TextFormField(
              //   controller: priceController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(labelText: 'Price'),
              // ),






              SizedBox(height: MediaQuery.of(context).size.height*0.04,
              ),



              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount (₹)",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,),),
                  Card(
                    elevation: 2,



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


              SizedBox(height: MediaQuery.of(context).size.height*0.02,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount in Words: ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,),),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(NumToWords.convertNumberToIndianWords(amountofwooltosell),overflow: TextOverflow.clip,),
                    ),
                  )
                ],
              ),



              SizedBox(height: MediaQuery.of(context).size.height*0.08,
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white
                ),
                onPressed: (){

                  setState(() {
                    updateMSP();
                  });
                  setState(() {

                  });
                },
                child: Text('Upload Price'),
              ),
            ],
          ),
        ),

    );
  }
}
