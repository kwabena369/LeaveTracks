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
  Set<gmaps.Polyline> _polylines = {};
  List<gmaps.LatLng> _polylineCoordinates = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  final double _distanceThreshold = 1.22; // Distance in meters (approx. 4 feet)
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndStartTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndStartTracking() async {
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

      setState(() {
        _errorMessage = 'Getting current location...';
      });

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      _updatePosition(_currentPosition!);

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen(
        _updatePosition,
        onError: (e) {
          setState(() {
            _errorMessage = 'Error getting location updates: $e';
          });
        },
        cancelOnError: false,
      );

      setState(() {
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _updatePosition(Position position) {
    setState(() {
      _currentPosition = position;
      final gmaps.LatLng newPosition =
          gmaps.LatLng(position.latitude, position.longitude);

      if (_polylineCoordinates.isEmpty ||
          _calculateDistance(_polylineCoordinates.last, newPosition) >=
              _distanceThreshold) {
        _polylineCoordinates.add(newPosition);
        _updatePolylines();
        _addMarker(newPosition);
      }
    });

    _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(
        gmaps.LatLng(position.latitude, position.longitude)));
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

  void _updatePolylines() {
    final polyline = gmaps.Polyline(
      polylineId: gmaps.PolylineId('track'),
      color: Colors.blue,
      points: _polylineCoordinates,
      width: 5,
    );

    setState(() {
      _polylines.clear();
      _polylines.add(polyline);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorer Tracking Map'),
      ),
      body: _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : gmaps.GoogleMap(
                  initialCameraPosition: gmaps.CameraPosition(
                    target: gmaps.LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 18, // Increased zoom for better detail
                  ),
                  onMapCreated: (gmaps.GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocationAndStartTracking,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
