//  in this page we show information about the other routes
//   and a btn for them to create a route

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leave_tracks/Service/TripService/Trips.dart';
import 'package:leave_tracks/Widgets/SingleSavedRoute.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  //  in the init we call for all the information
  @override
  void initState() {
//  a call for all the other items
    AllRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        //  the name and then the btn for creation of the  the tracks
        children: [
          const Text(
            "Dashboad",
            style: TextStyle(color: Colors.blueAccent),
          )
          // the btn for  which brings the forms
          ,
          ElevatedButton(
            onPressed: () {
              // ignore: sort_child_properties_last
            },
            child: const Text(
              "Start NewTrip",
            ),
            style: ButtonStyle(),
          )
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 2,
            childAspectRatio: 0.3
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return const SafeArea(
                child: Singlesavedroute(
                    id: "1",
                    previewFile: 'assets/Fun/Trip.png',
                    userProfile: "assets/Fun/One.png",
                    userName: "AmaGhana",
                    nameTrip: "Circle to RiceHouse"));
          },
        ),
      ),
    );
  }
}
