import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

class TestRoom extends StatefulWidget {
  const TestRoom({super.key});

  @override
  State<TestRoom> createState() => _TestRoomState();
}

class _TestRoomState extends State<TestRoom> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  //  this one i do not have any idea of what it is .. 
  //  ... the googleMapController 
  //  ... the position thing ... 
  //  the makers wich is a set tha i gave nnever see it before
  //  the maker Set<Marker> _name = {}
  StreamSubscription<Position>? _positionStreamSubscription;

  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initializeVideoRenderer();
    _getCurrentLocation();
  }

  void _initializeVideoRenderer() async {
    await _localRenderer.initialize();
    _getUserMedia();
  }

  void _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }

    setState(() {});
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
        _currentPosition = position;
        _updateMarkers();
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    });
  }

  void _updateMarkers() {
    if (_currentPosition != null) {
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Current Location'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Room')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            myLocationEnabled: true,
            markers: _markers,
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ClipOval(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: RTCVideoView(_localRenderer,
                    mirror: true,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }
}
