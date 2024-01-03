import 'dart:ffi';
// import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:woolify/Screens/govtMSPuploader.dart';
import 'package:woolify/Widgets/GraphScreen_PriceList.dart';
import 'package:woolify/Widgets/news.dart';
import 'package:woolify/main.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {

  List<String> woolTypes = [
    'Angora wool',
    'Merino wool',
    'Cashmere wool',
    'Lambswool',
    'Alpaca wool',
    'Mohair wool',
    'Camel wool',
  ];

  List<double> price=[10.0,20.0,30,50,20,90,30,27,67];


  List<FlSpot> generateDummyData() {
    return [
      FlSpot(0, 3),
      FlSpot(1, 1),
      FlSpot(2, 4),
      FlSpot(3, 2),
      FlSpot(4, 3),
      FlSpot(5, 5),
      FlSpot(6, 4),
      FlSpot(7, 6),
      FlSpot(8, 4),
    ];
  }


  bool isLineChart = true;

  List<String> newsTitles = [];
  List<String> imageUrls = [];
  List<String> directUrls = [];
  Future<void> scrapeData() async {
    final url = Uri.parse('https://news.google.com/search?q=wool&hl=en-IN&gl=IN&ceid=IN%3Aen');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    setState(() {
      newsTitles = html.querySelectorAll('div > article > h3 > a').map((element) => element.innerHtml.trim()).toList();
      imageUrls = html.querySelectorAll('figure > img').map((element) => element.attributes['src'] ?? '').toList();
      directUrls = html.querySelectorAll('div > article >a').map((element) => element.attributes['href'] ?? '').toList();
    });
  }
  void _launchURL(String url2) async {
    final Uri url = Uri.parse(url2);
    if (await canLaunchUrl(url as Uri)) {
      await  canLaunchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchURL2(String url2) async {
    final Uri url = Uri.parse(url2);
    if (!await launchUrl(url,mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrapeData();
  }

  @override
  Widget build(BuildContext context) {
    print(userid);
    return Scaffold(
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Text('an'),
            // Text('an'),
            // Text('an'),
            // Text('an'),
            // Text('an'),

            Container(
              // width: 300,
                child: HorizontalScrollableChart()),

            Divider(),
            // Container(color: Colors.deepPurple,height: 10,),
            Divider(),


            Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.04),

                child: Text('Latest News',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20,),)),
            Container(
              // color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,),


              // height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: newsTitles.length,
                itemBuilder: (context, index) {
                  if (index < imageUrls.length) {
                    return GestureDetector(
                      onTap: (){


                        // _launchURL('https://news.google.com/${directUrls[index]}');
                        launchUrlString('https://news.google.com/${directUrls[index]}');

                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.04),


                        child: Container(
                          // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                imageUrls[index],
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width * 0.6,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 8),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.04),

                                  child: Text(newsTitles[index])),

                              Divider()
                            ],


                          ),
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.04),
                        child: Text(newsTitles[index]),
                      ),
                    );
                  }
                },
              ),

            ),





            // WoolPriceUploader(),

            // News(),


            Container(
              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.7),

              // height: MediaQuery.of(context).size.height*0.4,
              // child: WoolPriceListWidget()))

            )









            // LineChart(LineChartData(lineBarsData: List.filled(7, LineChartBarData)))


          ],
        ),
      ),
    )
    ;
  }
}


class WoolDataService {
  final CollectionReference woolCollection =
  FirebaseFirestore.instance.collection('wool');

  Future<List<double>> fetchPricesForWool(String woolName) async {
    List<double> prices = [];

    try {
      QuerySnapshot querySnapshot = await woolCollection
          .doc(woolName)
          .collection('pricemap')
          .get();

      querySnapshot.docs.forEach((DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int price = data['price'] ; // Assuming 'price' is of type int
        prices.add(price.toDouble());
      });
    } catch (e) {
      print("Error fetching prices: $e");
    }

    return prices;
  }
}










class HorizontalScrollableChart extends StatefulWidget {



  @override
  _HorizontalScrollableChartState createState() =>
      _HorizontalScrollableChartState();
}

class _HorizontalScrollableChartState extends State<HorizontalScrollableChart> {

  String selectedwoolforgraph= 'Alpaca wool';

  List<FlSpot> data = [];




  // List<DateTime> timestamps = [];
  @override
  void initState() {
    super.initState();
    fetchDataForSelectedWool('Alpaca wool');
    // fetchTimestamps();
  }
  var selCol = 'Alpaca wool';

  void fetchDataForSelectedWool(String selwool) async {
    WoolDataService woolDataService = WoolDataService();
    List<double> fetchedPrices =
    await woolDataService.fetchPricesForWool(selwool);

    List<FlSpot> newData = [];
    for (int i = 0; i < fetchedPrices.length; i++) {
      newData.add(FlSpot(i.toDouble(), fetchedPrices[i]));
    }

    setState(() {
      data = newData;
    });
  }

  final CollectionReference woolCollection =
  FirebaseFirestore.instance.collection('wool');
  // List<String> timestamps ;

  // void fetchTimestamps() async {
  //   try {
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('wool')  // Replace with your collection name
  //         .doc(selCol)     // Replace with your document ID
  //         .get();
  //
  //     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //     List<Timestamp> timestampList = List.from(data['timestamps']);
  //     timestamps = timestampList.map((timestamp) => timestamp.toDate()).toList();
  //
  //     // print(timestamps.toString()); // This will print the list of timestamps
  //
  //     setState(() {});
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }





  @override
  Widget build(BuildContext context) {
    // fetchTimestamps();
    return Column(

      children: [

        Text(selCol, style: TextStyle(fontSize: MediaQuery.devicePixelRatioOf(context)*7)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            // color: Colors.green,
            width: data.length * 60,
            height: MediaQuery.of(context).size.height * 0.33,
            child: Container(
              color: Colors.black,

              // elevation: 5,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  bottom: MediaQuery.of(context).size.height * 0.03),
              child: Container(

                child: LineChart(

                  LineChartData(

                    backgroundColor: Colors.black,
                    gridData: FlGridData(

                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      // horizontalInterval:
                      // MediaQuery.of(context).size.height * 0.1,
                    ),

                    titlesData: FlTitlesData(
                        rightTitles: AxisTitles(drawBelowEverything: true),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          // getTitlesWidget: (value,meta){
                          //   String formattedDate = DateFormat('dd MMMM').format(timestamps[value.toInt()]);
                          //
                          //   return Text(formattedDate);
                          // }
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(getTitlesWidget:(value,meta){
                          String formattedDate = DateFormat('dd MMMM').format(value as DateTime);

                          return Text(formattedDate.toString());
                        } ))
                    ),
                    //                 titlesData: FlTitlesData(
                    //                   show: true,
                    //
                    //                     bottomTitles: AxisTitles(
                    //                       sideTitles: SideTitles(
                    //                         showTitles: true,
                    //                         getTitlesWidget: (value, meta) {
                    //
                    // // Assuming 'timestamps' is a List<String> containing your timestamps
                    // return Text(timestamps[value.toInt()].toString());
                    // }
                    //
                    //                           ))
                    //
                    //
                    //
                    //                 ),
                    // titlesData: FlTitlesData(show: false,),
                    baselineX: 100,
                    borderData: FlBorderData(
                      show: false,
                      // border: Border.all(
                      //   color: const Color(0xff37434d),
                      //   width: 1,
                      // ),
                    ),
                    minX: 0,
                    maxX: data.length.toDouble() ,
                    minY: 0,
                    maxY: getMaxYValue()+100,
                    lineBarsData: [
                      LineChartBarData(
                        shadow: Shadow(blurRadius: 10,color: Colors.deepPurple),
                        spots: data,
                        isCurved: false,
                        isStrokeJoinRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white,Colors.blueAccent, Colors.deepPurple, Colors.black],
                          ),
                        ),
                        // color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),





        Divider(),


        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: MediaQuery.of(context).size.width*0.04),


            child: Text('🚀 Recent MSP Movements',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20,),)),
            Container(
              // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),

              height: MediaQuery.of(context).size.height*0.7,
              child:
              StreamBuilder(
                  stream: woolCollection.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    // if (snapshot.hasError ) {
                    //   return Center(
                    //     child: Text('Error: ${snapshot.error}'),
                    //   );
                    // }

                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }



                    List<Future<DocumentSnapshot>> futureList = snapshot.data!.docs.map((DocumentSnapshot document) {
                      String woolName = document.id;
                      List<String> timestamps =
                      List<String>.from(document['timestamps']);
                      String latestTimestamp = timestamps.last;

                      return woolCollection
                          .doc(woolName)
                          .collection('pricemap')
                          .doc(latestTimestamp)
                          .get();
                    }).toList();

                    return FutureBuilder(

                      future: Future.wait(futureList),
                      builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && snapshot.hasData==false) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        List<ListTile> tiles = [];


                        for (int i = 0; i < snapshot.data!.length; i++) {
                          String woolName = snapshot.data![i].reference.parent.parent!.id;
                          var latestPriceData = snapshot.data![i].data();

                          // Add a null check for latestPriceData
                          if (latestPriceData is Map<String, dynamic>) {
                            String latestPrice = latestPriceData['price'].toString();
                            var latestTime = latestPriceData['time'];
                            DateTime dateTime = DateTime.parse(latestTime);

                            String formattedDate = DateFormat('d MMM').format(dateTime);
                            String formattedTime = DateFormat.jm().format(dateTime);

                            String formattedString = '$formattedDate at $formattedTime';

                            tiles.add(
                              ListTile(
                                // tileColor: selCol == woolName ? Colors.red : Colors.white,
                                onTap: () {
                                  setState(() {
                                    fetchDataForSelectedWool(woolName);
                                    selCol = woolName;
                                  });
                                },
                                selected: selCol == woolName ? true : false,
                                selectedColor: Colors.deepPurple,
                                title: Text(
                                  woolName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.devicePixelRatioOf(context) * 5.5,
                                  ),
                                ),
                                trailing: Text(
                                  '₹$latestPrice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.devicePixelRatioOf(context) * 5.5,
                                  ),
                                ),
                                subtitle: Text('$formattedString',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.devicePixelRatioOf(context) * 4.6,
                                  ),),
                              ),
                            );
                          }
                        }


                      return ListView(
                        physics: NeverScrollableScrollPhysics(), // Disable scrolling

                        children: tiles,
                      );
                    },
                  );
                }
              ),
            ),

            // SizedBox(height: MediaQuery.of(context).size.height*0.3,),



          ],
        )








        ,




      ],
    );
  }

  double getMaxYValue() {
    double maxY = 0;
    for (FlSpot spot in data) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    return maxY;
  }
}