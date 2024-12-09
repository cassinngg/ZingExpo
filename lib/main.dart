import 'package:flutter/material.dart';

import 'package:zingexpo/screens/homepage_screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryTextTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF023C0E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryColor: const Color(0xFF023C0E), // Primary color
        hintColor: const Color(0xFF097500), // Accent color
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