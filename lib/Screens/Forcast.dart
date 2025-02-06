import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

typedef TodaysForcastIconCallback = void Function(BoxedIcon icon);

class Forcast extends StatefulWidget {
  final double lat;
  final double lng;
  // final Function(BoxedIcon) getTodaysForcastIcon;
  const Forcast({super.key, required this.lat, required this.lng, });

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

  void getTodaysForcastIcon(TodaysForcastIconCallback callback) async {
    List<dynamic> forecast = await getForcast();
    if (forecast.isNotEmpty) {
      BoxedIcon todaysIcon = BoxedIcon(
        getWeatherIcon(forecast[0]['shortForecast']),
        color: Colors.white, 
        size: 50,
      );
      callback(todaysIcon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width/2,
        child: Card(
          color: Theme.of(context).colorScheme.primary,
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
                color: Colors.white,
              );
            } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length + 1,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                  if (index == snapshot.data!.length) {
                    return SizedBox(height: 60); // Padding at the bottom of the list
                  }
                  return Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    BoxedIcon(
                      getWeatherIcon(snapshot.data![index]['shortForecast']),
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 50,
                    ),
                    SizedBox(
                      width: 150,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Center(
                      child: Text(
                        '${snapshot.data![index]['name']}',
                        style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                        ),
                      ),
                      ),
                      Center(
                      child: Text(
                        dateConvert(snapshot.data![index]['startTime']),
                        style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        ),
                      ),
                      ),
                      ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                      snapshot.data![index]['detailedForecast'],
                      style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      ),
                      ),
                      ),
                    ),
                    ],
                    ),
                    ),
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

IconData getWeatherIcon(String description) {
  if (description.toLowerCase().contains('clear') || description.toLowerCase().contains('sunny')) {
    return WeatherIcons.day_sunny;
  } else if (description.toLowerCase().contains('partly cloudy') || description.toLowerCase().contains('partly sunny')) {
    return WeatherIcons.day_cloudy;
  } else if (description.toLowerCase().contains('cloudy')) {
    return WeatherIcons.cloud;
  } else if (description.toLowerCase().contains('rain') || description.toLowerCase().contains('showers')) {
    return WeatherIcons.rain;
  } else if (description.toLowerCase().contains('thunderstorm')) {
    return WeatherIcons.thunderstorm;
  } else if (description.toLowerCase().contains('snow')) {
    return WeatherIcons.snow;
  } else if (description.toLowerCase().contains('fog')) {
    return WeatherIcons.fog;
  } else if (description.toLowerCase().contains('windy')) {
    return WeatherIcons.strong_wind;
  } else {
    return WeatherIcons.na;
  }
}
