import 'package:flutter/material.dart';
import 'package:zingexpo/location/metadata.dart';
import 'package:zingexpo/sample/species_library.dart';
import 'package:zingexpo/screens/BottomNavigationBars/trial.dart';
import 'package:zingexpo/screens/add_ginger/display_gingers.dart';
import 'package:zingexpo/screens/add_quadrats.dart';
import 'package:zingexpo/screens/home.dart';
import 'package:zingexpo/screens/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryTextTheme: const TextTheme(
          headline6: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF023C0E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryColor: const Color(0xFF023C0E), // Primary color
        hintColor: const Color(0xFF097500), // Accent color
        backgroundColor: Colors.white, // Background color
        textTheme: TextTheme(
          bodyText1:
              TextStyle(color: const Color(0xFF023C0E)), // Default text color
          bodyText2: TextStyle(color: Colors.black), // Secondary text color
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF023C0E), // AppBar color
        ),
        // textButtonTheme: TextButtonThemeData.p),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF023C0E), // Default button color
        ),
      ),
    );
    // color palette:

// (0xFF023C0E)
// (0xFFF0F0F0)
// (0xFF097500)
//  Color(0xFF023C0E),
  }
}
//calling function on button passing textfield value to function
// onTap: () async(
//   await LocalDatabase(Name: ).addZing;
// )