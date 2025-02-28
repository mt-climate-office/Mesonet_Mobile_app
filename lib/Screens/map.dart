import 'dart:ffi';

import 'package:app_001/Screens/StationPage.dart';
import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

class map extends StatefulWidget {
  const map({super.key});

  @override
  State<map> createState() => _mapState();
}

class StationMarker {
  final String name;
  final String id;
  final String subNetwork;
  final double lat;
  final double lon;
  final double? air_temp;
  final double? precipSummary;

  const StationMarker({
    required this.name,
    required this.id,
    required this.subNetwork,
    required this.lat,
    required this.lon,
    required this.air_temp,
    required this.precipSummary,  //agrimet does not have precip summary yet!
  });

  //Use type casting as a saftey check
  //agrimet does not have precip summary, so have to check in factory
  factory StationMarker.fromJson(Map<String, dynamic> json) {
    return StationMarker(
      name: json['name'] as String,
      id: json['station'] as String,
      subNetwork: json['sub_network'] as String,
      lat: json['latitude'] as double,
      lon: json['longitude'] as double,
      air_temp: json['Air Temperature [°F]'] as double,
      precipSummary: json['7-Day Precipitation [in]'],
    );
  }
}

class _mapState extends State<map> {
  late double _markerSize;
  late MapController mapController;
  late Icon hydrometStations;
  late Icon agrimetStations;
  GeoJsonParser myGeoJson =
      GeoJsonParser(defaultPolygonBorderColor: Colors.black26);
  bool showHydroMet = true;


  //Defaults are set in initState 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadPolygons());

    mapController = MapController();
    _markerSize = 16.0; // Default marker size

    hydrometStations = Icon(
      Icons.circle_sharp,
      color: Color.fromARGB(255, 14, 70, 116),
      size: _markerSize,
    );

    agrimetStations = Icon(
      Icons.star,
      color: Color.fromARGB(255, 46, 155, 18),
      size: _markerSize,
    );

    getFavoriteStationList();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  
  Future<String> loadgeojsonString() async {
    return await rootBundle.loadString('lib/assets/mt_counties.geojson');
  }

  @pragma('vm:entry-point')
  static List<StationMarker> parseToStationMarkers(String responseBody) {
    final parsed =
        (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
    return parsed
        .map<StationMarker>((json) => StationMarker.fromJson(json))
        .toList();
  }

  List<Marker> parseToMarkers(List<StationMarker> stationList) {
    List<Marker> markers = [];
    for (StationMarker station in stationList) {
      if (showHydroMet && station.subNetwork == "HydroMet") {
        markers.add(Marker(
          height: _markerSize,
          width: _markerSize,
          point: LatLng(station.lat, station.lon),
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HydroStationPage(station: station, hydroBool: 1),
                  ),
                );
              },
              child: hydrometStations),
        ));
      } else if (!showHydroMet && station.subNetwork == "AgriMet") {
        markers.add(Marker(
          point: LatLng(station.lat, station.lon),
          height: _markerSize,
          width: _markerSize,
          child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HydroStationPage(station: station, hydroBool: 0),
                  ),
                );
              },
              child: agrimetStations),
        ));
      }
    }
    return markers;
  }

  Future<List<StationMarker>> getStations() async {
    String url = 'https://mesonet.climate.umt.edu/api/v2/app/?type=json';
    String response = '';
    try {
      response = await compute(apiCall, url);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }

    final List<StationMarker> stationList =
        await compute(parseToStationMarkers, response);
    return stationList;
  }

  void loadPolygons() async {
    String mygeoString = await loadgeojsonString();
    myGeoJson.parseGeoJsonAsString(mygeoString); //pull from asset
  }

  Future<List<Marker>> getMarkers() async {
    List<StationMarker> stationList = await getStations();
    List<Marker> markers = parseToMarkers(stationList);
    //List<Marker> markers = await compute(parseToMarkers, stationList);
    return markers;
  }

  Future<List<StationMarker>> getFavoriteStationList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonStringList = prefs.getString('favorites');
    Map<String, dynamic> jsonMAP = jsonDecode(jsonStringList!); //no null safe
    //print(jsonMAP['stations'][0]['name']);
    List<StationMarker> jsonStationList = [];
    for (int i = 0; i < (jsonMAP['stations'].length); i++) {
      jsonStationList.add(StationMarker(
        name: jsonMAP['stations'][i]['name'],
        id: jsonMAP['stations'][i]['id'],
        subNetwork: jsonMAP['stations'][i]['sub_network'],
        lat: jsonMAP['stations'][i]['lat'],
        lon: jsonMAP['stations'][i]['lon'],
        air_temp: jsonMAP['stations'][i]['air_temp'],
        precipSummary: jsonMAP['stations'][i]['precipSummary'],
      ));
    }
    // setState(() {

    // });
    return jsonStationList;
  }

  void _updateMarkerSize(double zoom) {
    if (zoom > 6.4) {
      setState(() {
        _markerSize = 100.0 * (zoom / 13.0);
      });
    } else {
      setState(() {
        _markerSize = 25;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 1)),
                      ),
                      onPressed: () => setState(() {
                        Scaffold.of(context).openDrawer();
                      }),
                      child: Center(
                        child: Text('Favorite Stations'),
                      )),
                );
              },
            ),
            title: Image.asset(
              'lib/assets/MCO_logo.png',
              width: 120,
              height: 70,
              fit: BoxFit.contain,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            actions: [
              Builder(
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        side: WidgetStateProperty.all(BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary,
                            width: 1)),
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      child: InkWell(
                        splashColor: Theme.of(context).colorScheme.error,
                        onTap: () => Scaffold.of(context).openEndDrawer(),
                        child: Text('Station List'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: FutureBuilder(
                future: getFavoriteStationList(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    //print(snapshot.data);
                    return const Center(
                      child: Text('An error has occurred!'),
                    );
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List<StationMarker> stationList =
                        snapshot.data as List<StationMarker>;

                    // print(snapshot.data);

                    return ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: stationList.length,
                        itemBuilder: (context, index) {
                          StationMarker station = stationList[index];

                          return ListTile(
                            leading: Icon(
                              station.subNetwork == "HydroMet"
                                  ? hydrometStations.icon
                                  : agrimetStations.icon,
                              color: station.subNetwork == "HydroMet"
                                  ? hydrometStations.color
                                  : agrimetStations.color,
                            ),
                            title: Text(station.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HydroStationPage(
                                    station: station,
                                    hydroBool: station.subNetwork == "HydroMet"
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  }
                }),
          ),
          endDrawer: Drawer(
            child: FutureBuilder(
              future: getStations(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error has occurred!'),
                  );
                } else if (snapshot.hasData) {
                  List<StationMarker> stationList =
                      snapshot.data as List<StationMarker>;
                  return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: stationList.length,
                      itemBuilder: (context, index) {
                        StationMarker station = stationList[index];
                        return ListTile(
                          leading: Icon(
                            station.subNetwork == "HydroMet"
                                ? hydrometStations.icon
                                : agrimetStations.icon,
                            color: station.subNetwork == "HydroMet"
                                ? hydrometStations.color
                                : agrimetStations.color,
                          ),
                          title: Text(station.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HydroStationPage(
                                  station: station,
                                  hydroBool:
                                      station.subNetwork == "HydroMet" ? 1 : 0,
                                ),
                              ),
                            );
                          },
                        );
                      });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          body: Stack(
            children: [
              FutureBuilder(
                future: getMarkers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text('Refresh')),
                    );
                  } else if (snapshot.hasData) {
                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(46.681625, -110.04365),
                        initialZoom: 5.5,
                        keepAlive: true,
                        interactionOptions: const InteractionOptions(
                          flags:
                              InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        ),
                        onPositionChanged: (position, hasGesture) {
                          if (hasGesture) {
                            _updateMarkerSize(position.zoom);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'MontanaClimateOffice.app',
                        ),
                        PolygonLayer(polygons: myGeoJson.polygons),
                        MarkerLayer(markers: snapshot.data as List<Marker>),
                        SimpleAttributionWidget(
                          backgroundColor: Colors.transparent,
                          source: Text('OpenStreetMap contributors'),
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Switch(
                  value: showHydroMet,
                  onChanged: (value) {
                    setState(() {
                      showHydroMet = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.onPrimary,
                  activeTrackColor: hydrometStations.color,
                  inactiveThumbColor: Theme.of(context).colorScheme.onSecondary,
                  inactiveTrackColor: agrimetStations.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
