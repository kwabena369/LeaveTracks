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
  final double _distanceThreshold = 5.0; // Distance in meters
  Position? _lastRecordedPosition;
  late StreamSubscription<Position> _positionStreamSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  // Kalman filter variables
  double _qValue = 3.0; // process noise
  double _rValue = 50.0; // measurement noise
  double _xEstimate = 0.0; // estimated value
  double _pEstimate = 1.0; // estimation error covariance
  bool _isMoving = false;
  DateTime? _lastUpdateTime;
  final _updateInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startListeningToLocationUpdates();
    _startListeningToAccelerometer();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _accelerometerSubscription.cancel();
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

  void _startListeningToLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
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
      _isMoving = acceleration > 10.5; // Adjust this threshold as needed
    });
  }

  void _processNewPosition(Position newPosition) {
    if (_lastUpdateTime != null &&
        DateTime.now().difference(_lastUpdateTime!) < _updateInterval) {
      return;
    }

    if (newPosition.accuracy > 20 || !_isMoving) {
      _setDebugInfo('Low accuracy or not moving, ignoring update.');
      return;
    }

    double filteredLatitude = _applyKalmanFilter(newPosition.latitude);
    double filteredLongitude = _applyKalmanFilter(newPosition.longitude);

    Position filteredPosition = Position(
      latitude: filteredLatitude,
      longitude: filteredLongitude,
      timestamp: newPosition.timestamp,
      accuracy: newPosition.accuracy,
      altitude: newPosition.altitude,
      heading: newPosition.heading,
      speed: newPosition.speed,
      speedAccuracy: newPosition.speedAccuracy,
      floor: newPosition.floor,
      isMocked: newPosition.isMocked,
      // New required parameters
      altitudeAccuracy: newPosition.altitudeAccuracy,
      headingAccuracy: newPosition.headingAccuracy,
    );

    if (_lastRecordedPosition != null) {
      double distance = _calculateDistance(
        gmaps.LatLng(
            _lastRecordedPosition!.latitude, _lastRecordedPosition!.longitude),
        gmaps.LatLng(filteredPosition.latitude, filteredPosition.longitude),
      );

      _setDebugInfo(
          'Distance: ${distance.toStringAsFixed(2)}m, Accuracy: ${newPosition.accuracy.toStringAsFixed(2)}m, Moving: $_isMoving');

      if (distance >= _distanceThreshold) {
        _updatePosition(filteredPosition);
        _lastRecordedPosition = filteredPosition;
        _setDebugInfo('New position marked');
      }
    } else {
      _updatePosition(filteredPosition);
      _lastRecordedPosition = filteredPosition;
      _setDebugInfo('First position marked');
    }

    _lastUpdateTime = DateTime.now();
  }

  double _applyKalmanFilter(double measurement) {
    // Prediction
    double xPredicted = _xEstimate;
    double pPredicted = _pEstimate + _qValue;

    // Update
    double k = pPredicted / (pPredicted + _rValue);
    _xEstimate = xPredicted + k * (measurement - xPredicted);
    _pEstimate = (1 - k) * pPredicted;

    return _xEstimate;
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
    print(info);
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
        ],
      ),
    );
  }
}
