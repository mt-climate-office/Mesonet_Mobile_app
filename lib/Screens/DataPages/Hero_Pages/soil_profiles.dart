// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:app_001/Screens/DataPages/JSONData.dart';
import 'package:rainbow_color/rainbow_color.dart';

/*Returns a column with graphical representations of soil VWC and Temp
Use a hero widget to allow for tap to expand in this.
FL Charts should be able to make my graphs? */

class soil_profiles extends StatefulWidget {
  final Data data;
  const soil_profiles({super.key, required this.data});

  @override
  State<soil_profiles> createState() => _soil_profilesState();
}

class _soil_profilesState extends State<soil_profiles> {

  // List<double> getTempRange(){
  //   List<double> range = [widget.data.soilTemperature5]
  // }

  Color getGradientColors(double input, bool temperatureBool) {
    // Define color ranges

    Rainbow rbColorTemp;
    if (input < 32){
      rbColorTemp = Rainbow(
      spectrum: [
        Colors.blue,
        Colors.white,
      ], //cold to hot
      rangeStart: 32,
      rangeEnd: 110,
    );
    } else{
       rbColorTemp = Rainbow(
      spectrum: [
        Colors.white,
        Colors.red,
      ], //cold to hot
      rangeStart: 0,
      rangeEnd: 32,
    );
    }

    var rbColorVWC = Rainbow(
      spectrum: [
        Colors.deepOrange,
        Colors.brown,
        Colors.black,
        Colors.green
      ], //cold to hot
      rangeStart: 0,
      rangeEnd: 50,
    );

    if (temperatureBool) {
      return rbColorTemp[input];
    } else {
      return rbColorVWC[input];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        //Text at the top of the card
        Text('Soil Profiles',style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed),),
        //=================================================================
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    Text('10'),
                    Text('10'),
                    Text('10'),
                    Text('10'),
                    Text('10'),
                  ],
                )),
                Flexible(child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: Container(color: getGradientColors(widget.data.soilTemperature5 as double, true),)),
                    Expanded(child: Container(color: getGradientColors(widget.data.soilTemperature10 as double, true),)),
                    Expanded(child: Container(color:getGradientColors(widget.data.soilTemperature20 as double, true),)),
                    Expanded(child: Container(color: getGradientColors(widget.data.soilTemperature50 as double, true),)),
                    Expanded(child: Container(color: getGradientColors(widget.data.soilTemperature100 as double, true),)),
                  ],
                )),
                Flexible(child: Container(color: Colors.white12,)),
              ],
            ),
          )
          )
      ],
    );
  }
}
