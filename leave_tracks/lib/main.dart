import 'package:flutter/material.dart';
import 'package:leave_tracks/Screens/CameraCapture/CameraScreen.dart';
import 'package:leave_tracks/Screens/Dashboard/DashBoard.dart';
import 'package:leave_tracks/Screens/Trips/LandingPage.dart';
import 'package:leave_tracks/Screens/VideoChat/ReroutingRoutes/RRoute.dart';
import 'package:leave_tracks/Screens/VideoChat/TestRoom/AIAssistedMap.dart';
import 'package:leave_tracks/Screens/VideoChat/TestRoom/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
  Widget build(BuildContext context) {
    // TODO: implement build
        // TODO: implement build
    return MaterialApp(
      title: "Saint",
      home: const LandingPage(),
      routes: {
        "/Home": (context) => const LandingPage(),
        "/MyRoute":(context)=>const LandingPage(),
        "/Settings": (context) => const LandingPage(),
        "/LogOut": (context) => const LandingPage(),
        "/TestVideo": (context) => const TestRoom(),
        "/AIshine" : (context)=> const AIAssistedMap(),
        "/CameraCapture":(context)=> const CameraScreen(),
"/DashBoard":(context)=>const Dashboard(),
        '/route': (context) {
          // Get the arguments passed through navigation
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return Rroute(
            tripName: args['tripName'],
            routeId: args['routeId'],
          );
        },
        
      },
    );
  }

}
