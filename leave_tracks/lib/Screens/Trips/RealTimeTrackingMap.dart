import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

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
  final double _distanceThreshold = 9.144; // 30 feet in meters
  Position? _lastRecordedPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isMoving = false;
  DateTime? _lastUpdateTime;
  final _updateInterval = Duration(seconds: 5);
  List<Map<String, double>> _tripLocations = [];
  bool _isTracking = false;
  List<Position> _recentPositions = [];
  final int _positionBufferSize = 5;

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

  void _startTracking() {
    if (_isTracking) return;

    setState(() {
      _isTracking = true;
      _markers.clear();
      _polylineCoordinates.clear();
      _tripLocations.clear();
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
            'New position marked - Distance: ${distance.toStringAsFixed(2)}m');
        _addTripLocation(averagePosition);
        _addMarker(
            gmaps.LatLng(averagePosition.latitude, averagePosition.longitude));
      }
    } else {
      _updatePosition(averagePosition);
      _lastRecordedPosition = averagePosition;
      _setDebugInfo('First position marked');
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intelligent Explorer Tracking'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isTracking ? null : _startTracking,
                child: Text('Start Trip'),
              ),
              ElevatedButton(
                onPressed:
                    _isTracking ? () => _stopTracking(isCancelled: true) : null,
                child: Text('Cancel Trip'),
              ),
              ElevatedButton(
                onPressed: _isTracking ? () => _stopTracking() : null,
                child: Text('Finish Trip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
