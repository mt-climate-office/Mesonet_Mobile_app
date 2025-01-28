import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:weather_icons/weather_icons.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Precip.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Temp_Splash.dart';

class CurrentDataPretty extends StatefulWidget {
  final String id;
  const CurrentDataPretty({super.key, required this.id});

  @override
  State<CurrentDataPretty> createState() => _CurrentDataPrettyState();
}

class _CurrentDataPrettyState extends State<CurrentDataPretty> {

  BoxedIcon todaysWeatherIcon = BoxedIcon(WeatherIcons.day_sunny);

  @override
  initState() {
    super.initState();
  }

  @pragma('vm:entry-point')
  static Map<String, dynamic> parseToMap(String responseBody) {
    return json.decode(responseBody);
  }

  Future<Data> getData(String url) async {
    Data dataList;
    String data = await flutterCompute(apiCall, url);
    List<dynamic> dataMap = jsonDecode(data);

    dataList = (Data.fromJson(dataMap[0]));

    return dataList;
  }

  Color getGradientColors(double temperature) {
    // Define color ranges
    final coldColor = Colors.blue;
    final hotColor = Colors.red;

    // Interpolate between cold and hot colors based on temperature
    final factor =
        (temperature + 20) / (120); // Assuming temperature range 0-50
    Color interpolatedColor =
        Color.lerp(coldColor, hotColor, factor.abs()) as Color;

    return interpolatedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getData(
              'https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              //waiting on the future
              return const Placeholder();
            } else if (snapshot.hasData) {
              //Two rows, Photo listview on top, temp / info box on bottom.
              //Will need to split bottom up into more column and rows
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                          aspectRatio:
                              1.75, //guesswork. Should be 16/9 but it isnt
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer, width: 1.0)),
                            child: PhotoPage(id: widget.id),
                          ),
                        ),
                      ),

                      //Bottom boxes for data display. See diagram for concept
                    ],
                  ),

                  //Temperature Box under the photos
                  Flexible(
                    flex: 1,
                    child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            width: 1.0,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(child: Text('Air Temperature:${snapshot.data!.airTemperature.toString()}[°F]',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed),)),
                          Flexible(child: Text('Relative Humidity:${snapshot.data!.relativeHumidity.toString()}[%]',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed))),
                        ],
                      ),
                    ),
                  ),
                  //==========================================================
                  //bottom flex to set up boxes for info
                  Flexible(
                    flex: 9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(  //Left side box for soil info
                          flex: 3,
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  width: 1.0,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: soil_profiles(data: snapshot.data!,),
                            ),
                          ),
                        ),

                        //Center boxes in grid
                        Flexible(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: TempSplash(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //Right side Column
                              //============================================================
                              Expanded(
                                child: Column(
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: Card(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Precip(id: widget.id),
                                        ),
                                          
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Card(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: AspectRatio(
                                                aspectRatio: 1 / 1,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Image.asset(
                                                        'lib/assets/cadrant.png',),
                                                    Transform.rotate(
                                                      angle: snapshot.data!
                                                              .windDirection
                                                          as double,
                                                      child: Image.asset(
                                                          'lib/assets/compass.png',
                                                          scale: 2.5,),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Center(
                                              child: Text(
                                                '${snapshot.data!.windSpeed!.toString()} Mi/hr',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              );
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          }),
    );
  }
}
