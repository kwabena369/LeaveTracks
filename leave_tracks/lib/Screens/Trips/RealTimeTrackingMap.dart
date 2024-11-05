// ignore_for_file: await_only_futures

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

//  this is for the state
class UserPicture {
  final String image; // Base64 string of the image
  final Map<String, double> location; // Location coordinate
  UserPicture({required this.image, required this.location});
}

class RealTimeTrackingMap extends StatefulWidget {
  final String tripName;
// I didn't do anything I just 
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
  Uint8List? _imageBytes; // for the cover..

  String _debugInfo = ''; // for keeping the error information .
  final double _distanceThreshold =
      9.144; // tihis is in meter for feet (30feet)

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
//  this section is for storing of the user
// picture that they have taken
  List<UserPicture> userPictures = [];

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

//  for the capturing and the storing of the information
  Future<void> captureAndStore() async {
    if (_currentPosition == null) {
      _setDebugInfo('Cannot capture image: Location not available');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      _setDebugInfo('Image capture cancelled');
      return;
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final userPicture = UserPicture(
      image: base64Image,
      location: {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      },
    );

    setState(() {
      userPictures.add(userPicture);
    });

    _setDebugInfo('Image captured and stored with location');
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

//  function that is for handling of the picking of the image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveTrip() async {
    _setDebugInfo('Saving trip...');
    //  for converting the image to base64
    String base64Image = base64Encode(_imageBytes!);

    try {
      // First, convert all userPictures to the correct format
      final memoriesTrip = userPictures
          .map((up) => {
                'ImageContent': up.image,
                'Location': up.location,
              })
          .toList();

      // Try the endpoint with lowercase 'routes' instead of 'Routes'
      final url = Uri.parse('https://leave-tracks-backend.vercel.app/Routes');

      final payload = {
        'Name_Route': widget.tripName,
        'Path_Cordinate': _routeCoordinates,
        'userProfile': '/cat.png',
        'userName': 'kogi',
        'MemoriesTrip': memoriesTrip,
      };

      // Debug logging before making the request
      print('Attempting to save trip with following details:');
      print('URL: $url');
      print('Headers: ${{
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }}');
      print('Payload structure: ${payload.keys}');

      // Add timeout to the request
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      print('Response received:');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        _setDebugInfo('Trip saved successfully!');
        // Clear the current trip data
        setState(() {
          _routeCoordinates.clear();
          _tripLocations.clear();
          _markers.clear();
          _polylineCoordinates.clear();
          userPictures.clear();
        });
      } else {
        throw HttpException(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error details: $e');
      if (e is HttpException) {
        print('HTTP Exception details: ${e.message}');
      }

      print('Error stack trace: $stackTrace');
      String errorMessage = 'Error saving trip: $e';
      _setDebugInfo(errorMessage);

      // Show error dialog to user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error Saving Trip'),
            content: SingleChildScrollView(
              child: Text(errorMessage),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _storeCover() async {
    try {
      final payload = {"Base64_Content_": "base64/pandate"};
      final responce =
          await http.post(Uri.parse("https://leave_tracks_backend/Save"),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(payload));
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tripName} - Tracking'),
        actions: [
          //   the btn for the uploading of the cover for the trip
            ElevatedButton(
            onPressed: _pickImage,
            child: const Text("select Cover",style: TextStyle(
              color: Colors.blue,
              fontSize: 23
            ),),
          ),

        ],
      ),
      body: Column(
        children: [
          if (_imageBytes != null)
            Row(
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.memory(_imageBytes!, height: 100, width: 80,),
    ),
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        setState(() {
          _imageBytes = null;
        });
      },
    ),
  ],
),
           
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
                child: const Text(
                  'Start Trip',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.normal,
                  ),
                ),
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
              //  this is going to be taking the image and then seting the location of the person
              
            ],
          ),
      

      
        ],
      ),
    );
  }
}
