// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;
//
//
// class News extends StatefulWidget {
//   const News({super.key});
//
//   @override
//   State<News> createState() => _NewsState();
// }
//
// class _NewsState extends State<News> {
//
//   late Future<Album> futureAlbum;
//
//   @override
//   void initState() {
//     super.initState();
//     futureAlbum = fetchAlbum();
//   }
//
//   Future<Album> fetchAlbum() async {
//     final response = await http
//         .get(Uri.parse('https://news.google.com/search?q=wool&hl=en-IN&gl=IN&ceid=IN%3Aen'));
//
//     if (response.statusCode == 200) {
//       // If the server did return a 200 OK response,
//       // then parse the JSON.
//       return Album.fromJson(jsonDecode(response.body));
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       throw Exception('Failed to load album');
//     }
//   }
//
//   void parseHTML(String html) {
//     var document = parser.parse(html);
//     // Now you can use DOM operations to extract data.
//     // For example, document.querySelectorAll('selector') to select elements.
//   }
//
//
//   Widget build(BuildContext context) {
//     return  Center(
//       child: FutureBuilder<Album>(
//           future: futureAlbum,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return Text(snapshot.data!.title);
//             } else if (snapshot.hasError) {
//               return Text('${snapshot.error}');
//             }
//
//             // By default, show a loading spinner.
//             return  CircularProgressIndicator();
//           },
//         ),
//     );
//   }
// }
//
//
//
//
//
//
//
// class Album {
//   final int userId;
//   final int id;
//   final String title;
//
//   const Album({
//     required this.userId,
//     required this.id,
//     required this.title,
//   });
//
//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(
//       userId: json['userId'],
//       id: json['id'],
//       title: json['title'],
//     );
//   }
// }