import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';




class Newsscre extends StatefulWidget {
  const Newsscre({super.key});

  @override
  State<Newsscre> createState() => _NewsscreState();
}
class _NewsscreState extends State<Newsscre> {
  List<String>? titles; // Make titles nullable

  @override
  void initState() {
    super.initState();
    fetchGeeksForGeeksContent().then((value) {
      setState(() {
        titles = value;
      });
    });
  }

  Future<List<String>> fetchGeeksForGeeksContent() async {
    final response =
    await http.get(Uri.parse('https://www.geeksforgeeks.org/'));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final titles = document.querySelectorAll('.entry-title');

      List<String> titleList = [];

      for (var title in titles) {
        titleList.add(title.text);
      }

      return titleList;
    } else {
      throw Exception('Failed to load page: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        child: titles != null
            ? ListView.builder(
          itemCount: titles!.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(titles![index],style: TextStyle(color: Colors.black),),
            );
          },
        )
            : Center(child: CircularProgressIndicator()), // Show a loading indicator while titles are being fetched
      ),
    );
  }
}
