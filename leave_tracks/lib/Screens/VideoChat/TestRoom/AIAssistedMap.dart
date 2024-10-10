import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIAssistedMap extends StatefulWidget {
  const AIAssistedMap({Key? key}) : super(key: key);

  @override
  State<AIAssistedMap> createState() => _AIAssistedMapState();
}

class _AIAssistedMapState extends State<AIAssistedMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  String _aiSuggestion = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _updateMarkers();
    });

    // Move camera to current position
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    // Get AI suggestion based on location
    _getAISuggestion(position.latitude, position.longitude);
  }

  void _updateMarkers() {
    if (_currentPosition != null) {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: InfoWindow(title: 'You are here'),
      ));
    }
  }

  Future<void> _getAISuggestion(double lat, double lng) async {
    final apiKey = 'AIzaSyD-zMkmVWcQrmPBTXXq2tLxO9_8qTPays0';
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Given the latitude $lat and longitude $lng, suggest tell me the historical significant of that place. Keep the suggestion brief."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _aiSuggestion = data['candidates'][0]['content']['parts'][0]['text'];
      });
    } else {
      setState(() {
        _aiSuggestion = 'Failed to get AI suggestion.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI-Assisted Map')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            myLocationEnabled: true,
            markers: _markers,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('AI Suggestion:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(_aiSuggestion),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
