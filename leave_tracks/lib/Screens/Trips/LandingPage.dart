import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leave_tracks/Screens/Trips/TripReview.dart';
import 'package:leave_tracks/Widgets/SingleSavedRoute.dart';
import 'package:http/http.dart' as http;
import 'RealTimeTrackingMap.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

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
    fetchAllRoutes();
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
      final responce = await http
          .get(Uri.parse('https://leave-tracks-backend.vercel.app/allRoutes'));

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
          title: const Text('Create New Trip'),
          content: TextField(
            onChanged: (value) {
              newTripName = value;
            },
            decoration: const InputDecoration(hintText: "Enter trip name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
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
            child: Row(
              children: [
                ElevatedButton(
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
                //  for the direction to camera pages...
                // ElevatedButton(
                //     onPressed: () {
                //       Navigator.of(context)
                //           .pushReplacementNamed("/CameraCapture");
                //     },
                //     child: const Text("test",
                //         style: TextStyle(color: Colors.green, fontSize: 15))
                //         )
                //  this is for the routing to the other side
                
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("/DashBoard");
                    },
                    // testing the case change 
                    child: const Text("_Board"))
                    
              ],
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
                            Text(
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
                          return GestureDetector(
                            onTap: () {
                              // Navigate to the new screen here
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Tripreview(tripId: singleRoute['_id']),
                                ),
                              );
                            },
                            child: SingleSavedRoute(
                              id: singleRoute['id']?.toString() ?? '',
                              previewFile: 'assets/Fun/Trip.png',
                              userProfile: "assets/Fun/One.png",
                              userName: "Serwaa",
                              nameTrip:
                                  singleRoute['Name_Route']?.toString() ?? '',
                            ),
                          );
                        },
                      ),
      ),
//  for the purpose of nav
// igation
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(2),
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: const Text(
                "Trackime 👻💀",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text(
                "H o m e",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/Home");
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.route,
              ),
              title: const Text(
                "My R o u t e",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/MyRoute");
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                "S e t t i n g s",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/Settings");
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/LogOut");
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.route,
              ),
              title: const Text(
                "Gemini",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/AIshine");
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.route,
              ),
              title: const Text(
                "TestVideo",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/TestVideo");
              },
            )
          ],
        ),
      ),
    );
  }
}
