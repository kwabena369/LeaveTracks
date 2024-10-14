
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:leave_tracks/Service/http_helper.dart';

class LocationDisplayWidget extends StatefulWidget {
  const LocationDisplayWidget({super.key});

  @override
  _LocationDisplayWidgetState createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  double? latitude;
  double? longitude;
  String debugMessage = '';
  final HttpHelper httpHelper = HttpHelper();

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            debugMessage = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          debugMessage = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        debugMessage = 'Location updated successfully';
      });
    } catch (e) {
      setState(() {
        debugMessage = 'Error getting location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Latitude: ${latitude?.toStringAsFixed(6) ?? "Unknown"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Longitude: ${longitude?.toStringAsFixed(6) ?? "Unknown"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _updateLocation();
                if (latitude != null && longitude != null) {
                  await httpHelper.sendLocation(latitude!, longitude!);
                  //  the send location btn is going to be close  like more than one time 
                  //   it is going t 
                }
              },
              child: const Text('Send Location'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                httpHelper.testBackend('Test message from Flutter');
              },
              child: const Text('Test Backend'),
            ),
            const SizedBox(height: 16),
            Text(
              'Debug: $debugMessage',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}