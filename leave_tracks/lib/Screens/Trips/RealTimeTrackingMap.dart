import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealTimeTrackingMap extends StatefulWidget {
  final String tripName;

  const RealTimeTrackingMap({super.key, required this.tripName});

  @override
  _RealTimeTrackingMapState createState() => _RealTimeTrackingMapState();
}

class _RealTimeTrackingMapState extends State<RealTimeTrackingMap> {
//  the boss that manages the way the zooming of the map is here  and there 
gmaps.GoogleMapController? _mapController;
Position? _currentPosition;
//  the keeper of the user maps there ..
final Set<gmaps.Marker> _markers = {};
//  this is the long list that store the lat and Lat pair in it .. 
final List<gmaps.LatLng> _polylineCoordinates = [];
 
  String _debugInfo = ''; // for keeping the error information .
  final double _distanceThreshold = 9.144; // tihis is in meter for feet (30feet)

  Position? _lastRecordedPosition; // this is the last possition ...
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isMoving = false;
  DateTime? _lastUpdateTime;
  final _updateInterval = const Duration(seconds: 3);
  final List<Map<String, double>> _tripLocations = [];
  bool _isTracking = false;
  final List<Position> _recentPositions = [];
  final int _positionBufferSize = 5;
  final List<Map<String, double>> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _accelerometerSubscription?.cancel();
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
        desiredAccuracy: LocationAccuracy.best,
      );

      _updatePosition(_currentPosition!);

      _setDebugInfo('Initial location set');
    } catch (e) {
      _setDebugInfo('Error: ${e.toString()}');
    }
  }

//  this is a function to Capture the image ..
Future <void> captureAndStore()async{
   
}

void _startTracking() {
    if (_isTracking) return;

    setState(() {
      _isTracking = true;
      _markers.clear();
      _polylineCoordinates.clear();
      _tripLocations.clear();
      _routeCoordinates.clear();
      _lastRecordedPosition = null;
      _recentPositions.clear();
    });

    _startListeningToLocationUpdates();
    _startListeningToAccelerometer();
    _setDebugInfo('Tracking started');
  }

  void _stopTracking({bool isCancelled = false}) {
    if (!_isTracking) return;

    setState(() {
      _isTracking = false;
    });
    _positionStreamSubscription?.cancel();
    _accelerometerSubscription?.cancel();

    if (isCancelled) {
      _setDebugInfo('Tracking canceled');
    } else {
      _setDebugInfo('Tracking finished. Locations logged to console.');
      print('Trip Locations:');
      for (var location in _tripLocations) {
        print(
            'Latitude: ${location['latitude']}, Longitude: ${location['longitude']}');
      }
    }
  }

  void _startListeningToLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _processNewPosition(position);
    });
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _isMoving = acceleration > 1.2; // Slightly increased threshold
    });
  }

  void _processNewPosition(Position newPosition) {
    if (!_isTracking) return;

    if (_lastUpdateTime != null &&
        DateTime.now().difference(_lastUpdateTime!) < _updateInterval) {
      return;
    }

    _recentPositions.add(newPosition);
    if (_recentPositions.length > _positionBufferSize) {
      _recentPositions.removeAt(0);
    }

    Position averagePosition = _calculateAveragePosition(_recentPositions);

    if (_lastRecordedPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastRecordedPosition!.latitude,
        _lastRecordedPosition!.longitude,
        averagePosition.latitude,
        averagePosition.longitude,
      );

      _setDebugInfo(
          'Distance: ${distance.toStringAsFixed(2)}m, Accuracy: ${averagePosition.accuracy.toStringAsFixed(2)}m, Moving: $_isMoving');

      if (distance >= _distanceThreshold && _isMoving) {
        _updatePosition(averagePosition);
        _lastRecordedPosition = averagePosition;
        _setDebugInfo(
            'Bro your new position marked - Distance: ${distance.toStringAsFixed(2)}m');
        _addTripLocation(averagePosition);
        _addMarker(
            gmaps.LatLng(averagePosition.latitude, averagePosition.longitude));
      }
    } else {
      _updatePosition(averagePosition);
      _lastRecordedPosition = averagePosition;
      _setDebugInfo('yo your  position marked');
      _addTripLocation(averagePosition);
      _addMarker(
          gmaps.LatLng(averagePosition.latitude, averagePosition.longitude));
    }

    _lastUpdateTime = DateTime.now();
  }

  Position _calculateAveragePosition(List<Position> positions) {
    if (positions.isEmpty) {
      throw Exception('No positions to average');
    }

    double sumLat = 0, sumLon = 0, sumAlt = 0, sumAcc = 0;
    for (var position in positions) {
      sumLat += position.latitude;
      sumLon += position.longitude;
      sumAlt += position.altitude;
      sumAcc += position.accuracy;
    }

    return Position(
      latitude: sumLat / positions.length,
      longitude: sumLon / positions.length,
      timestamp: positions.last.timestamp,
      accuracy: sumAcc / positions.length,
      altitude: sumAlt / positions.length,
      heading: positions.last.heading,
      speed: positions.last.speed,
      speedAccuracy: positions.last.speedAccuracy,
      floor: positions.last.floor,
      isMocked: positions.last.isMocked,
      altitudeAccuracy: positions.last.altitudeAccuracy,
      headingAccuracy: positions.last.headingAccuracy,
    );
  }

  void _updatePosition(Position position) {
    setState(() {
      _currentPosition = position;
      final gmaps.LatLng newPosition =
          gmaps.LatLng(position.latitude, position.longitude);

      _polylineCoordinates.add(newPosition);

      _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(newPosition));

      _setDebugInfo(
          'Position updated: ${position.latitude}, ${position.longitude}');
    });
  }

  void _addMarker(gmaps.LatLng position) {
    final markerId = gmaps.MarkerId(DateTime.now().toIso8601String());
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
    print(info);
  }

  void _addTripLocation(Position position) {
    _tripLocations.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    _routeCoordinates.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  void _endTrip() {
    _stopTracking();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Trip'),
          content: const Text('Do you want to save or discard this trip?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Discard'),
              onPressed: () {
                Navigator.of(context).pop();
                _discardTrip();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveTrip();
              },
            ),
          ],
        );
      },
    );
  }

  void _discardTrip() {
    setState(() {
      _routeCoordinates.clear();
      _tripLocations.clear();
      _markers.clear();
      _polylineCoordinates.clear();
    });
    _setDebugInfo('Trip discarded');
  }

  Future<void> _saveTrip() async {
    _setDebugInfo('Saving trip...');

    final url = Uri.parse('https://leave-tracks-backend.vercel.app/Routes');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Name_Route': widget.tripName,
        'Path_Cordinate': _routeCoordinates,
        'userProfile': '/cat.png', // Default value, update as needed
        'userName': 'kogi', // Default value, update as needed
      }),
    );

    if (response.statusCode == 200) {
      _setDebugInfo('Trip saved successfully');
    } else {
      _setDebugInfo('Failed to save trip: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tripName} - Tracking'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
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
                        polylineId: const gmaps.PolylineId('track'),
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
            padding: const EdgeInsets.all(8),
            color: Colors.black87,
            width: double.infinity,
            child: Text(
              _debugInfo,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isTracking ? null : _startTracking,
                child: const Text('Start Trip',
                style: TextStyle(color: Colors.blueAccent,
                fontWeight: FontWeight.normal,
                ),),
                
              ),
              ElevatedButton(
                onPressed:
                    _isTracking ? () => _stopTracking(isCancelled: true) : null,
                child: const Text('Cancel Trip'),
              ),
              ElevatedButton(
                onPressed: _isTracking ? _endTrip : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('End Trip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
