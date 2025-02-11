import 'package:app_001/Screens/DataPages/Hero_Pages/soil_profiles.dart';
import 'package:app_001/main.dart';
import 'package:app_001/Screens/DataPages/Photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';
import 'JSONData.dart';
import 'package:app_001/Screens/DataPages/Hero_Pages/Precip.dart';

class CurrentDataPretty extends StatefulWidget {
  final String id;
  const CurrentDataPretty({super.key, required this.id});

  @override
  State<CurrentDataPretty> createState() => _CurrentDataPrettyState();
}

class _CurrentDataPrettyState extends State<CurrentDataPretty> {
  late Future<Data> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = getData(
        'https://mesonet.climate.umt.edu/api/v2/latest/?type=json&stations=${widget.id}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                          aspectRatio: 1.75,
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    width: 1.0)),
                            child: PhotoPage(id: widget.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 1,
                    child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            width: 1.0,
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                              child: Text(
                            'Air Temperature: ${snapshot.data!.airTemperature.toString()}[°F]',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryFixed),
                          )),
                          Flexible(
                              child: Text(
                            'Relative Humidity: ${snapshot.data!.relativeHumidity.toString()}[%]',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryFixed),
                          )),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  width: 1.0,
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: soil_profiles(
                                data: snapshot.data!,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Placeholder()
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              width: 1.0,
                                            )),
                                        child: Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Flexible(
                                      flex: 4,
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
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
                                                      'lib/assets/cadrant.png',
                                                    ),
                                                    Transform.rotate(
                                                      angle: snapshot.data!
                                                              .windDirection
                                                          as double,
                                                      child: Image.asset(
                                                        'lib/assets/compass.png',
                                                        scale: 2.5,
                                                      ),
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
             
                ],
              );
            } else {
              return Center(child: const CircularProgressIndicator());
            }
          }),
    );
  }
}
