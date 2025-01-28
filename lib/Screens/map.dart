import 'package:app_001/Screens/StationPage.dart';
import 'package:app_001/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter_isolate/flutter_isolate.dart';


class map extends StatefulWidget {
  const map({super.key});



  @override
  State<map> createState() => _mapState();
}

class StationMarker{
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

  factory StationMarker.fromJson(Map<String,dynamic> json){  //explicit casting protects us from bad json data
    return StationMarker(name: json['name'] as String, 
    id: json['station'] as String, 
    subNetwork: json['sub_network'] as String, 
    lat: json['latitude'] as double, 
    lon: json['longitude'] as double,
    );
  }
}

class _mapState extends State<map> {
  @override
  void initState(){
    super.initState();
    getMarkers();
  }

  @pragma('vm:entry-point')
  static List<StationMarker> parseToStationMarkers(String responseBody) {
  final parsed =
      (jsonDecode(responseBody) as List).cast<Map<String, dynamic>>();
  return parsed.map<StationMarker>((json) => StationMarker.fromJson(json)).toList();
  }

  List<Marker> parseToMarkers(List<StationMarker> stationList) {
    List<Marker> markers = [];
    for (StationMarker station in stationList){
      if (station.subNetwork == "HydroMet"){
        markers.add(Marker(
          point: LatLng(station.lat, station.lon), 
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => HydroStationPage(station: station,hydroBool: 1,)),
                );
            },
            child: Icon(
              Icons.circle_sharp,
              color: Color.fromARGB(255, 14, 70, 116),),
            )
          )
          );
      } else {
        markers.add(Marker(
          point: LatLng(station.lat, station.lon), 
          child: GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => HydroStationPage(station: station,hydroBool: 0,)),
                );
            },
            child: Icon(
              Icons.circle_sharp,
              color: Color.fromARGB(255, 46, 155, 18),),
            )
            )
          );
      }

    }
    return markers;
  }

  Future<List<Marker>> getMarkers() async{
    String url = 'https://mesonet.climate.umt.edu/api/v2/stations/?type=json';
    final String response = await flutterCompute(apiCall,url);
    final List<StationMarker> stationList = await compute(parseToStationMarkers, response);
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
            title: Image.asset('lib/assets/MCO_logo.png',
            width: 120,
            height: 60,
            fit: BoxFit.contain,),
            backgroundColor: Theme.of(context).colorScheme.primary,
        
            actions: [
              Builder(
                builder: (context) {
                  return MaterialButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  child: Text('Station List')
                  );
                }
              ),
            ],
          ),
        
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: List<Text>.generate(100,(counter) => Text('Item $counter')),
            ),
          ),
        
          body: FutureBuilder(future: getMarkers(),
           builder: (context,snapshot){
            if (snapshot.hasError){  //catch all errors in marker parsing
              return const Center(
                    child: Text('An error has occurred!'),
                  );
          
            } else if (snapshot.hasData){  //finished loading. Build FlutterMap
               return FlutterMap(
                options: MapOptions(
                initialCenter: LatLng(46.681625,-110.04365), // Center the map over Montana
                initialZoom: 5.5,
                keepAlive: true,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                ),
              children: [
                TileLayer( // Display map tiles from any source
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'MontanaClimateOffice.app',
                  // And many more recommended properties!
                ),
          
                MarkerLayer(markers: snapshot.data as List<Marker>),
                
                SimpleAttributionWidget(
                  backgroundColor: Colors.transparent,
                  source: Text('OpenStreetMap contributors'),
                ),
                ]
              );
          
            } else{ //loading marker data
              return const Center(
                    child: CircularProgressIndicator(),
                  );
            }
           }
           ),
        ),
      ),
    );
  }
}

