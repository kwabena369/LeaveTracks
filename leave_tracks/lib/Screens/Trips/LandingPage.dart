import 'package:flutter/material.dart';
import 'package:leave_tracks/Service/TripService/Trips.dart';
import 'package:leave_tracks/Widgets/SingleSavedRoute.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    AllRoutes();
  }

  void _startNewTrip() {
    // TODO: Implement new trip functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "TexasStudio💀👻",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,
          fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ElevatedButton(
              onPressed: _startNewTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Start New Trip",
              style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1, // Square aspect ratio for the cards
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 5, // Replace with actual item count
          itemBuilder: (context, index) {
            return const SingleSavedRoute(
              id: "1",
              previewFile: 'assets/Fun/Trip.png',
              userProfile: "assets/Fun/One.png",
              userName: "AmaGhana",
              nameTrip: "Circle to Rice",
            );
          },
        ),
      ),
    );
  }
}
