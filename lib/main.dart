import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyAppp());
}

class MyAppp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Alla Jobb',
      theme: ThemeData(primaryColor: Color.fromRGBO(0, 0, 86, 1.0)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  // MyHomePage({Key key, this.title}) : super(key: key);
  // final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List data;
  String city = 'Sundsvall';

  Future<String> makeRequest() async {
    final response = await http.get(
      'https://jobsearch.api.jobtechdev.se/search?q=${city}&offset=0&limit=100',
      headers: {
        'api-key':
            "USE OWN API-KEY"
      },
    );

    setState(() {
      var extractdata = json.decode(response.body);
      data = extractdata["hits"];
    });

    //print(data[0]["headline"]);
    //print(data[0]["description"]["text"]);
  }

  @override
  void initState() {
    this.makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title:  Text('Jobb i ${city} (${data.length} träffar)'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {
            showSearch(context: context, delegate: DataSearch());
          },)
        ],
      ),
      //drawer: Drawer(),
      body:  ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text(
                  data[i]["headline"],
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue[900])
                  ),
                trailing: Icon(Icons.keyboard_arrow_right),
                selected: true,
                onTap: () {
                Navigator.push(
                  context,
                   MaterialPageRoute(
                    builder: (BuildContext context) =>
                       SecondPage(data[i])
                  )
                );
              }
              ),
            );
          }),
    );
   }

}


class SecondPage extends StatelessWidget {
  final data;
  SecondPage(this.data);
  @override
  Widget build(BuildContext context) =>  Scaffold(
    //resizeToAvoidBottomPadding: false,
    appBar: AppBar(title: Text('Beskrivning')),
    body: Center(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Container(
            child: Text(
              data["headline"],
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
              ),  
          ),
          SizedBox(height: 12),
          Container(
            child: Text(
              data["employer"]["name"],
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
              ),
            ),
          SizedBox(height: 10),
          Container(
            child: Text(
              data["occupation"]["label"],
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900)
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: Text(
              'Kommun: ${data["workplace_address"]["municipality"]}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900)
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: Text(
              'Omfattning: ${data["working_hours_type"]["label"]}',
              style: TextStyle(fontWeight: FontWeight.w500)
            ),
          ),
          SizedBox(height: 2),
          Container(
            child: Text(
              'Varaktighet: ${data["duration"]["label"]}',
              style: TextStyle(fontWeight: FontWeight.w500)
            ),
          ),
          SizedBox(height: 30),
          Container(
            child: Text(
              'Om jobbet',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
              ),
          ),
          SizedBox(height: 6),
          Container(
              child: Text(
                data["description"]["text"],
                style: TextStyle(wordSpacing: 1.0, fontSize: 14.0, fontWeight: FontWeight.w500),
                ),
          ),
          SizedBox(height: 30),
          Container(
            child: Text(
              'Om anställningen',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
              ),   
          ),
          SizedBox(height: 4),
          Container(
            child: Text(
              'Lön',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900),
              ),
          ),
          SizedBox(height: 4),
          Container(
            child: Text(
              'Lönetyp: ${data["salary_type"]["label"]}',
              style: TextStyle(fontWeight: FontWeight.w500)
            ),
          ),
          SizedBox(height: 30),
          Container(
            child: Text(
              'Publiserad',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900),
              ),
          ),
          SizedBox(height: 4),
          Container(
            child: Text(
              data["publication_date"],
              style: TextStyle(fontWeight: FontWeight.w500)
              )
            ),
            SizedBox(height: 30),
            Container(
            child: Text(
              'Sista ansökningsdag',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(height: 4),
            Container(
            child: Text(
              data["application_deadline"],
              style: TextStyle(fontWeight: FontWeight.w500)
              )
            ),
        ],
      )
      )
    );
}

class DataSearch extends SearchDelegate<String> {

  final cities = [
    'Sundsvall',
    'Stockholm',
    'Hudiksvall',
    'Uppsala'
  ];

  final recentCities = [
    'Sundsvall',
    'Hudiksvall'
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {
      query = "";
    },)];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow, 
      progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Container(
        height: 100.0,
        width: 100.0,
        child: Card(
          color: Colors.red,
          child: Center(
            child: Text(query),
          ),
        ),
      ),
    );
    //return MyHomePage(String city);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ? recentCities : cities.where((p)=>p.startsWith(query)).toList();

    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
      leading: Icon(Icons.location_city),
      title: RichText(
        text: TextSpan(
          text: suggestionList[index].substring(0, query.length),
          style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(color: Colors.grey))           
            ]),
          ),
        ),
      itemCount: suggestionList.length,
      );
  }
}
