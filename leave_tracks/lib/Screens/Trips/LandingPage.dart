import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leave_tracks/Service/TripService/Trips.dart';
import 'package:leave_tracks/Widgets/SingleSavedRoute.dart';
import 'package:http/http.dart' as http;
import 'RealTimeTrackingMap.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';
  bool _isLoading = true;
//  All the vaious routes
  List<Map<String, dynamic>> _routePlaces = [];

  @override
  void initState() {
    super.initState();
    AllRoutes();
  }

  //  this is the function for fetching the fetching all the route ...

  Future<void> fetchAllRoutes() async {
//  we set that page is loading
    setState(() {
      setState(() {
        _isLoading = true;
      });
    });

    try {
      final responce = await http.get(Uri.parse('$baseUrl/allRoutes'));

      if (responce.statusCode == 200) {
        //  setting the vlaues into the Routeplace
        setState(() {
          _routePlaces =
              List<Map<String, dynamic>>.from(json.decode(responce.body));
          _isLoading = false;
        });
      } else {
        print("there is somebig error in the backend");
        setState(() {
          _isLoading = false;
          _routePlaces = [];
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _routePlaces = [];
      });
      throw "there is some big $e";
    }
  }

  void _startNewTrip() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTripName = '';
        return AlertDialog(
          title: Text('Create New Trip'),
          content: TextField(
            onChanged: (value) {
              newTripName = value;
            },
            decoration: InputDecoration(hintText: "Enter trip name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                Navigator.of(context).pop();
                if (newTripName.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RealTimeTrackingMap(tripName: newTripName),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "TexasStudio💀👻",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
//   when it is loading
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _routePlaces.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "💀",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "__NO Thing__",
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      )
                    :
// here we show the real dela
                    GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _routePlaces
                            .length, // Replace with actual item count
                        itemBuilder: (context, index) {
                          final singleRoute = _routePlaces[index];
                          return  SingleSavedRoute(
                            id: singleRoute['id']?.toString() ?? '',
                            previewFile: 'assets/Fun/Trip.png',
                            userProfile: "assets/Fun/One.png",
                            userName: "Serwaa" ,
                            nameTrip: singleRoute['Name_Route']?.toString()??'',
                          );
                        },
                      ),
      ),
    );
  }
}
