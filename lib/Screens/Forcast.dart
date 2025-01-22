import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';

class Forcast extends StatefulWidget {
  final double lat;
  final double lng;
  const Forcast({super.key, required this.lat, required this.lng});

  @override
  State<Forcast> createState() => _ForcastState();
}

class _ForcastState extends State<Forcast> {
  @override
  initState() {
    super.initState();
    getForcast();
  }

  @pragma('vm:entry-point') //multithread parse to map
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<List<dynamic>> getForcast() async {
    Map<String, dynamic> responseMap;
    String url;
    String response = await flutterCompute(
        apiCall, 'https://api.weather.gov/points/${widget.lat},${widget.lng}');
    responseMap = parseToMap(response);

    url = responseMap['properties']['forecast'];

    Map<String, dynamic> forecastData;
    response = await flutterCompute(apiCall, url);
    forecastData = parseToMap(response);

    //forcastData[properties][periods] will return a list of reports in map:key form
    return forecastData['properties']
        ['periods']; //print(forecastData['properties']['periods'][0]);
  }

  String dateConvert(String time){
    DateTime date = DateTime.parse(time);
    return DateFormat('MMM dd').format(date).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width/2,
        child: Card(
          color: Colors.blue,
          child: Center(
            child: Text('Weekly Forecast'),
          ),
        ),
      ),

      Expanded(
        child: FutureBuilder(
          future: getForcast(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Placeholder(
                color: Colors.red,
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.blue,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('${snapshot.data![index]['name']}',
                              style: TextStyle(
                                fontSize: 15
                              ),),
                              Text(dateConvert(snapshot.data![index]['startTime']),
                              style: TextStyle(
                                fontSize: 10,
                                
                              ),)
                            ],
                          ),
                          //image
                         // FadeInImage(placeholder: MemoryImage(kTransparentImage),
                          // image: NetworkImage(snapshot.data![index]['icon'])),
                          //temp
                          //Wind compass
                          // AspectRatio(aspectRatio: 1/1,
                          // child: Stack(
                          //   alignment: Alignment.center,
                          //   children: [
                          //     Image.asset('lib/assets/cadrant.png'),
                            
                          //   ],
                          // ),)
                          //wind speed
                        ],
                      )
                    );
                  });
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    ]);
  }
}
