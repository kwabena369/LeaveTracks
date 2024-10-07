import 'package:flutter/material.dart';
import 'package:leave_tracks/Screens/DumyTest/InputTest.dart';
import 'package:leave_tracks/Screens/RealTimeTrackingMap.dart';
import 'package:leave_tracks/Screens/First_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    // TODO: implement build
        // TODO: implement build
    return MaterialApp(
      title: "Saint",
      home: RealTimeTrackingMap(),
    );
  }

}
