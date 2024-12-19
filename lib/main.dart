import 'package:app_001/Screens/HomeManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/*App for the montana climate office
  Built by Jim Seielstad

  Map Bounds -116.0518, 44.35556, -104.0355, 49.00769
  Center is -110,04365, 46.681625
   */


void main() async{
  runApp(const MainApp());
}

/*DOCS: Setting global functions to be used for concurrency
        pragma points to the functions for package binding in isolate
---------------------------------------------------------- */
@pragma('vm:entry-point')
Future<String> apiCall(String url) async{  
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

/*--------------------------------------------------------

DOCS: Setting light and dark color schemes for the app.
      Adjust colors below*/

const ColorScheme lightColorScheme = ColorScheme(
    primary: Color.fromARGB(255, 70, 183, 218),
    onPrimary: Colors.black,

    secondary: Color.fromARGB(255, 141, 145, 145),
    onSecondary: Color(0xFF322942),

    error: Colors.redAccent,
    onError: Colors.white,

    surface: Color.fromARGB(255, 182, 182, 182),
    onSurface: Color(0xFF241E30),

    brightness: Brightness.light,
  );
const ColorScheme darkColorScheme = ColorScheme(
    primary: Color.fromARGB(255, 14, 70, 116),
    onPrimary: Colors.white,

    secondary: Color.fromARGB(255, 99, 102, 102),
    onSecondary: Colors.white,

    error: Colors.redAccent,
    onError: Colors.white,

    surface: Color.fromARGB(255, 158, 160, 160),
    onSurface: Colors.black,
    
    brightness: Brightness.dark,
  );



class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  //Body is splash screen. Use to set theme colors for the app. 
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Montana Climate Office',
      themeMode: ThemeMode.system, //checks for system light or dark mode
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),

      home: const HomeManager(),
    );
  }
}
