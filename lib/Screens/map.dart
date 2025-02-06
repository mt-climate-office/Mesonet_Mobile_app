import 'package:app_001/Screens/StationPage.dart';
import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';

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

  const StationMarker({
    required this.name,
    required this.id,
    required this.subNetwork,
    required this.lat,
    required this.lon,
  });

  factory StationMarker.fromJson(Map<String, dynamic> json) {
    return StationMarker(
      name: json['name'] as String,
      id: json['station'] as String,
      subNetwork: json['sub_network'] as String,
      lat: json['latitude'] as double,
      lon: json['longitude'] as double,
    );
  }
}

class _mapState extends State<map> {

  //Variables to control appearence of markers!
  final Icon hydrometStations = Icon(
    Icons.circle_sharp,
    color: Color.fromARGB(255, 14, 70, 116),
  );

  Icon agrimetStations = Icon(
    Icons.star,
    color: Color.fromARGB(255, 46, 155, 18),
  );

  // Finish

  bool showHydroMet = true;

  @override
  void initState() {
    super.initState();
    getMarkers();
  }

  @override
  void dispose() {
    super.dispose();
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
          point: LatLng(station.lat, station.lon),
          child: GestureDetector(
            onTap: () {
              print('headed to hydromet');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HydroStationPage(station: station, hydroBool: 1),
                ),
              );
            },
            child: hydrometStations
          ),
        ));
      } else if (!showHydroMet && station.subNetwork == "AgriMet") {
        markers.add(Marker(
          point: LatLng(station.lat, station.lon),
          child: GestureDetector(
            onTap: () {
              print('headed to agrimet');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HydroStationPage(station: station, hydroBool: 0),
                ),
              );
            },
            child: agrimetStations
          ),
        ));
      }
    }
    return markers;
  }

  Future<List<StationMarker>> getStations() async {
    String url = 'https://mesonet.climate.umt.edu/api/v2/stations/?type=json';
    String response = '';
    try {
      response = await compute(apiCall, url);
    } catch (e) {
      print('Error: $e');
    }

    final List<StationMarker> stationList =
        await compute(parseToStationMarkers, response);
    return stationList;
  }

  Future<List<Marker>> getMarkers() async {
    List<StationMarker> stationList = await getStations();
    List<Marker> markers = parseToMarkers(stationList);

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: AppBar(
            title: Image.asset(
              'lib/assets/MCO_logo.png',
              width: 120,
              height: 60,
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
                  
                  side: WidgetStateProperty.all(
                BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 1)),
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
              return const Center(
                child: Text('An error has occurred!'),
              );
            } else if (snapshot.hasData) {
              return FlutterMap(
                options: MapOptions(
            initialCenter: LatLng(46.681625, -110.04365),
            initialZoom: 5.5,
            keepAlive: true,
            interactionOptions: const InteractionOptions(
              flags:
                  InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
                ),
                children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'MontanaClimateOffice.app',
            ),
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
