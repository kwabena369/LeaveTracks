import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Tripreview extends StatefulWidget {
  final String tripId;

  const Tripreview({super.key, required this.tripId});

  @override
  State<Tripreview> createState() => _TripreviewState();
}

class _TripreviewState extends State<Tripreview>
    with SingleTickerProviderStateMixin {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  late AnimationController _animationController;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    fetchTripInfo();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchTripInfo() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/Trip/${widget.tripId}'));
      if (response.statusCode == 200) {
        setState(() {
          tripData = json.decode(response.body);
          isLoading = false;
        });
        _addStartEndMarkers();
      } else {
        throw Exception('Failed to load trip data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching trip data: $e');
    }
  }

  void _addStartEndMarkers() {
    if (tripData != null && tripData!['Path_Cordinate'] != null) {
      var coordinates = tripData!['Path_Cordinate'];
      var startPoint = coordinates.first;
      var endPoint = coordinates.last;

      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: LatLng(startPoint['latitude'], startPoint['longitude']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
      ));

      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: LatLng(endPoint['latitude'], endPoint['longitude']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'End'),
      ));

      setState(() {});
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        circles.clear();
        circles.add(Circle(
          circleId: const CircleId('currentLocation'),
          center: LatLng(position.latitude, position.longitude),
          radius: 10,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));
      });
    });
  }

  Set<Polyline> _createPolylines() {
    if (tripData == null || tripData!['Path_Cordinate'] == null) return {};

    List<LatLng> polylineCoordinates = [];
    for (var coord in tripData!['Path_Cordinate']) {
      polylineCoordinates.add(LatLng(coord['latitude'], coord['longitude']));
    }

    return {
      Polyline(
        polylineId: const PolylineId('trip_route'),
        color: Colors.blue,
        points: polylineCoordinates,
        width: 5,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (tripData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: const Center(child: Text('Failed to load trip data')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(tripData!['Name_Route'] ?? 'Trip Details')),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                  tripData!['userProfile'] ?? 'assets/default_profile.png'),
            ),
            title: Text(tripData!['userName'] ?? 'Unknown User'),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      tripData!['Path_Cordinate'][0]['latitude'],
                      tripData!['Path_Cordinate'][0]['longitude'],
                    ),
                    zoom: 14,
                  ),
                  polylines: _createPolylines(),
                  markers: markers,
                  circles: circles
                      .map((circle) => Circle(
                            circleId: circle.circleId,
                            center: circle.center,
                            radius: circle.radius,
                            fillColor: circle.fillColor,
                            strokeColor: circle.strokeColor,
                            strokeWidth: circle.strokeWidth,
                          ))
                      .toSet(),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
