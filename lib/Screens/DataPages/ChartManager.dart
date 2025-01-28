import 'dart:convert';

import 'package:app_001/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'JSONData.dart';


/*DOCS: Floating action button will hold date range and check boxes 
        Have function to check date range, bools then add to list of functions
        Have to call json here; parse and pass data from here?
        */


/*Problem: Bottom titles need to be generated depending on length of calender
  Switch cases can be used to find if duration is more or less than x
  Switch cases are also used to generate the title names, based off x values in graph
  See if theres a better way to code than nested switches
  
  Switch case also to be used in listview children [] for tie into checklist*/

class Chartmanager extends StatefulWidget {
  final String id;
  const Chartmanager({super.key, required this.id});

  @override
  State<Chartmanager> createState() => _ChartmanagerState();
}

class _ChartmanagerState extends State<Chartmanager> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final f = DateFormat('yyyy-MM-dd');
  DateTime now = DateTime.now();
  DateTimeRange? _selectedDateRange;

  

/*NOTE: Setting booleans for initial charting. */
  bool? airTemperature = true;
  bool? atmosphericPressure = false;
  bool? bulkEC = false;
  bool? gustSpeed = false;
  bool? maxPrecipRate = false;
  bool? precipitation = true;
  bool? referenceET = true;
  bool? relativeHumidity = false;
  bool? snowDepth = false;
  bool? soilTemperature = true;
  bool? soilVWC = true;
  bool? solarRadiation = false;
  bool? windDirection = false;
  bool? windSpeed = false;

  @override
  void initState(){
    super.initState();
    DateTime now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(Duration(days: 7)), 
      end: now);

      getDataList();
  }

// This block handles the Data retreval and api calls.
//==============================================================================
  //sets widgets in checklist.
  //Date picker and checkboxes
  List<String> calculateDaysInterval(DateTime startDate, DateTime endDate) {
  List<String> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    String temp = f.format(startDate.add(Duration(days: i)));
    days.add(temp);
  }
  return days;
}
  
  //Returns the url with date range and station ID. Premade is forced
  String parseURL(){
    List<String> dayArr= calculateDaysInterval(_selectedDateRange!.start, _selectedDateRange!.end);
    //print('Parsed URL: https://mesonet.climate.umt.edu/api/v2/observations/hourly/?type=json&stations=${widget.id}&dates=${f.format(_selectedDateRange!.start)},${f.format(_selectedDateRange!.end)}&premade=true');
    return 'https://mesonet.climate.umt.edu/api/v2/observations/hourly/?type=json&stations=${widget.id}&dates=${dayArr.join(',')}&premade=true';
  }

  //returns a list of data entries following standard json format.
  //Acess data using dot format (Data[i].datetime)
  Future<List<Data>> getDataList()async{
    List<Data> dataList = [];
    String url = parseURL();
    String response = await flutterCompute(apiCall, url);
    List<dynamic> dataMap = jsonDecode(response);
    
    for (int i = 0; i < dataMap.length;i++){
      dataList.add(Data.fromJson(dataMap[i]));
    }
    return dataList;
  }

//================================================================================

//This block handles the checklist and date picker
List<Widget> checklist() {
    List<Widget> checklist = [];

    checklist.add(ListTile(
      leading: Text('${f.format(_selectedDateRange!.start)} - ${f.format(_selectedDateRange!.end)}',
      style: TextStyle(fontWeight: FontWeight.w800),
      ),
      trailing: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        onPressed: _show,
        child: Icon(Icons.date_range),),
      ));

    checklist.add(
      CheckboxListTile(
        title: Text('Air Temperature'),
        value: airTemperature, 
        onChanged:(bool? value) {
          setState(() {
            airTemperature = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Atmospheric Pressure'),
        value: atmosphericPressure, 
        onChanged:(bool? value) {
          setState(() {
            atmosphericPressure = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Bulk EC'),
        value: bulkEC, 
        onChanged:(bool? value) {
          setState(() {
            bulkEC = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Gust Speed'),
        value: gustSpeed, 
        onChanged:(bool? value) {
          setState(() {
            gustSpeed = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Maximum Precipitation Rate'),
        value: maxPrecipRate, 
        onChanged:(bool? value) {
          setState(() {
            maxPrecipRate = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Precipitation'),
        value: precipitation, 
        onChanged:(bool? value) {
          setState(() {
            precipitation = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Reference ET'),
        value: referenceET, 
        onChanged:(bool? value) {
          setState(() {
            referenceET = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Relative Humidity'),
        value: relativeHumidity, 
        onChanged:(bool? value) {
          setState(() {
            relativeHumidity = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Snow Depth'),
        value: snowDepth, 
        onChanged:(bool? value) {
          setState(() {
            snowDepth = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Soil Temperature'),
        value: soilTemperature, 
        onChanged:(bool? value) {
          setState(() {
            soilTemperature = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Soil Volumetric Water Content'),
        value: soilVWC, 
        onChanged:(bool? value) {
          setState(() {
            soilVWC = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Solar Radiation'),
        value: solarRadiation, 
        onChanged:(bool? value) {
          setState(() {
            solarRadiation = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Wind Direction'),
        value: windDirection, 
        onChanged:(bool? value) {
          setState(() {
            windDirection = value;
          });},
        ));

      checklist.add(
      CheckboxListTile(
        title: Text('Wind Speed'),
        value: windSpeed, 
        onChanged:(bool? value) {
          setState(() {
            windSpeed = value;
          });},
        ));

      setState(() {
        
      });
      return checklist;
  }

//shows the datepicker
  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      // Rebuild the UI
      setState(() {
        _selectedDateRange = result;
      });
    }
  }

//=================================================================================

  Future<List<FlSpot>> dataSpot() async{
    List<FlSpot> airTemperatureSpotList = [];

    List<Data> data = await getDataList();
    //this ignores null checks. also really slow. Fix
    for (int i = 0; i<data.length;i++){
    //  int x = data[i].datetime ?? 0;   //This is currently not used. consider breaking into different area?
      double y = data[i].airTemperature ?? 0;
        airTemperatureSpotList.add(FlSpot(i.toDouble(),y));
    }
    return airTemperatureSpotList;
  }

  Future<List<FlSpot>> lineChart() async{
    List<FlSpot> spotList = [];
    List<Data> dataList = [];
    double y = 0;

    for (int i = 0; i<dataList.length;i++){
    //  int x = data[i].datetime ?? 0;   //This is currently not used. consider breaking into different area?
      y = dataList[i].airTemperature ?? 0;
        spotList.add(FlSpot(i.toDouble(),y));
    }

    return spotList;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      
      floatingActionButton: Builder(builder: (context){
        return FloatingActionButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          child: Icon(Icons.menu),
        );
      }
      ),

        endDrawer: Drawer(
          child: ListView(
            children: checklist(),
          ),
        ),
        //Call charts from list above
        body: GridView.count(
          crossAxisCount: 1,
          children: [FutureBuilder(
            future: dataSpot(),
            builder: (context,snapshot){
              if(!snapshot.hasData){
                return CircularProgressIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LineChart(
                    LineChartData(
                      
                      titlesData: FlTitlesData(topTitles: AxisTitles(axisNameWidget: Text("Air Temperature")),
                      
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 38,
                             maxIncluded: false,
                          )
                        )
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surfaceBright, //pick something better for colors
                      lineBarsData: [LineChartBarData(
                        color: Colors.red,
                        spots: snapshot.data!,
                        dotData: FlDotData(
                          show: false
                        )
                    )]
                    
                                  ),
                
                                  
                                ),
                );
              }
            },
          ),]
        ),
    );
  }
}