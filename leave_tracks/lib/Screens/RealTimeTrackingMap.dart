import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class RealTimeTrackingMap extends StatefulWidget {
  @override
  _RealTimeTrackingMapState createState() => _RealTimeTrackingMapState();
}

class _RealTimeTrackingMapState extends State<RealTimeTrackingMap> {
  gmaps.GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<gmaps.Marker> _markers = {};
  List<gmaps.LatLng> _polylineCoordinates = [];
  String _debugInfo = '';
  final double _distanceThreshold = 3.048; // Distance in meters (10 feet)
  Position? _lastRecordedPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      _setDebugInfo('Getting current location...');

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _updatePosition(_currentPosition!);

      _setDebugInfo('Initial location set');
    } catch (e) {
      _setDebugInfo('Error: ${e.toString()}');
    }
  }

  void _markMilestone() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_lastRecordedPosition != null) {
        double distance = _calculateDistance(
          gmaps.LatLng(_lastRecordedPosition!.latitude,
              _lastRecordedPosition!.longitude),
          gmaps.LatLng(newPosition.latitude, newPosition.longitude),
        );

        _setDebugInfo(
            'Distance from last milestone: ${distance.toStringAsFixed(2)} meters');

        if (distance >= _distanceThreshold) {
          _updatePosition(newPosition);
          _lastRecordedPosition = newPosition;
          _setDebugInfo('New milestone marked');
        } else {
          _setDebugInfo('Milestone not marked: Distance less than 10 feet');
        }
      } else {
        _updatePosition(newPosition);
        _lastRecordedPosition = newPosition;
        _setDebugInfo('First milestone marked');
      }
    } catch (e) {
      _setDebugInfo('Error marking milestone: ${e.toString()}');
    }
  }

  void _updatePosition(Position position) {
    setState(() {
      _currentPosition = position;
      final gmaps.LatLng newPosition =
          gmaps.LatLng(position.latitude, position.longitude);

      _polylineCoordinates.add(newPosition);
      _addMarker(newPosition);

      _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(newPosition));

      _setDebugInfo(
          'Position updated: ${position.latitude}, ${position.longitude}');
    });
  }

  double _calculateDistance(gmaps.LatLng start, gmaps.LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  void _addMarker(gmaps.LatLng position) {
    final markerId = gmaps.MarkerId(position.toString());
    final marker = gmaps.Marker(
      markerId: markerId,
      position: position,
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _setDebugInfo(String info) {
    setState(() {
      _debugInfo = info;
    });
    print(info); // Also print to console for easier debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorer Tracking Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : gmaps.GoogleMap(
                    initialCameraPosition: gmaps.CameraPosition(
                      target: gmaps.LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 18,
                    ),
                    onMapCreated: (gmaps.GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    polylines: {
                      gmaps.Polyline(
                        polylineId: gmaps.PolylineId('track'),
                        color: Colors.blue,
                        points: _polylineCoordinates,
                        width: 5,
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.black87,
            width: double.infinity,
            child: Text(
              _debugInfo,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _markMilestone,
        child: Icon(Icons.add_location),
      ),
    );
  }
}
