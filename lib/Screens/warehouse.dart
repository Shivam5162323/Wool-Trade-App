import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(20.5937, 78.9629);

  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _fetchCitiesFromFirestore() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('sellwool').get();

    for (var orderDoc in querySnapshot.docs) {
      var subCollectionSnapshot = await orderDoc.reference.collection('orders').get();

      for (var subDoc in subCollectionSnapshot.docs) {
        var city = subDoc.data()['comb'];
        var typeofwool = subDoc.data()['typeofwool'];
        var price = subDoc.data()['amount'];
        var quantity = subDoc.data()['quantity'];
        var seller = subDoc.data()['name'];


        try {
          List<Location> locations = await locationFromAddress(city);
          double latitude = locations.first.latitude;
          double longitude = locations.first.longitude;

          print('City: $city, Latitude: $latitude, Longitude: $longitude');

          setState(() {
            _markers.add(Marker(
              icon: BitmapDescriptor.defaultMarker,
              visible: true,
              markerId: MarkerId(city),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(

                title: city,
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Wool Info'),
                        content: Container(
                          // color: Colors.black87,
                          height: MediaQuery.of(context).size.height*0.2,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Seller Name',style: TextStyle(fontWeight: FontWeight.w600),),
                                  Text(seller),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02,),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,


                                children: [
                                  Text('Wool Type',style: TextStyle(fontWeight: FontWeight.w600),),
                                  Text(typeofwool),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Text('Price',style: TextStyle(fontWeight: FontWeight.w600),),
                                  Text('₹${price.toString()}'),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.02,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                children: [
                                  Text('Quantity',style: TextStyle(fontWeight: FontWeight.w600),),
                                  Text('${quantity.toString()} Kg'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );



                }
              ),
            ));
          });
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCitiesFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 4.0,
        ),
        markers: _markers,
      ),
    );
  }
}
