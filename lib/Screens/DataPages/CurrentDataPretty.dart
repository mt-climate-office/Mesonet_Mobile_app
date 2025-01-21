import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'package:gradient_icon/gradient_icon.dart';

class CurrentDataPretty extends StatefulWidget {
  final String id;
  const CurrentDataPretty({super.key,required this.id});

  @override
  State<CurrentDataPretty> createState() => _CurrentDataPrettyState();
}

class _CurrentDataPrettyState extends State<CurrentDataPretty> {


  @override
  initState(){
    super.initState();
  }

  @pragma('vm:entry-point')
  static Map<String,dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }


  Future<Data> getData(String url) async{
    Data dataList;
    String data = await flutterCompute(apiCall, url);
    List<dynamic> dataMap = jsonDecode(data);
    
    dataList=(Data.fromJson(dataMap[0]));

    return dataList;
  }

Color getGradientColors(double temperature) {
    // Define color ranges
    final coldColor = Colors.blue;
    final hotColor = Colors.red;

    // Interpolate between cold and hot colors based on temperature
    final factor = (temperature + 20) / (120); // Assuming temperature range 0-50
    Color interpolatedColor = Color.lerp(coldColor, hotColor, factor.abs()) as Color;

    return interpolatedColor;
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    SizedBox(
                      
                      height: 200,
                      width: MediaQuery.of(context).size.width - 10,
                      child: Card(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black,
                          width: 2.0
                        )
                      ),
                        color: Theme.of(context).colorScheme.surface,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Spacer(),
                            GradientIcon(
                              icon: Icons.thermostat_outlined,
                              gradient: LinearGradient(colors: [Colors.red,Colors.blue],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              
                              ),
                              
                              size: 100,
                              ),
                        
                            Text('${snapshot.data!.airTemperature} °F',
                            style: TextStyle(
                              color: getGradientColors(snapshot.data!.airTemperature as double),
                              fontWeight: FontWeight.w800,
                              fontSize: 40
                            ),
                            ),
                            Spacer(),
                            Spacer(),
                          ],
                        ),
                        
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 10,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.black,
                            width: 2
                          )
                        ),
                        child: PhotoPage(id: widget.id,),
                      ),
                    )
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                    width: MediaQuery.of(context).size.width/2 - 10,
                    height: 100,
                    child: Card(
                      
                      color: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black,
                          width: 2.0
                        )
                      ),
                      child: Text('Test2',
                      )
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width/2 - 10,
                    height: 100,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.black,
                          width: 2.0
                        )
                      ),
                      color: Theme.of(context).colorScheme.onSecondary,
                      child: Text('Test2',
                      ),
                    ),
                  ),
                  ],
                )
          
              ],
            ),
          ));
      } else {
        return Center(child: const CircularProgressIndicator());
      }
       }
       ),
    );
  }
}