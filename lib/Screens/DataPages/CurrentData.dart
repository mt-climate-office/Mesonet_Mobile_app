import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';

class Currentdata extends StatefulWidget {
  final String id;
  const Currentdata({super.key,required this.id});

  @override
  State<Currentdata> createState() => _CurrentdataState();
}

class _CurrentdataState extends State<Currentdata> {


  @override
  initState(){
    super.initState();
  }

  @pragma('vm:entry-point')
  static Map<String,dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }


  Future<Map<String,dynamic>> getData(String url) async{
    String data = await flutterCompute(apiCall, url);
    int length = data.length;
     return flutterCompute(parseToMap, data.substring(1,length-1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getData('https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}'),
       builder:(context,snapshot){
        if (snapshot.hasError) {  //waiting on the future
          return const Placeholder();

      }else if (snapshot.hasData){
        return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder:(context,index){
          return ListTile(
            trailing: Text(snapshot.data![snapshot.data!.keys.elementAt(index)].toString()),
            title: Text(snapshot.data!.keys.elementAt(index)),
          );
        });
      } else {
        return Center(child: const CircularProgressIndicator());
      }
       }
       ),
    );
  }
}