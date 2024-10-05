import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpHelper {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';

  Future<void> testBackend(String message) async {
    final String url = '$baseUrl/test';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );
      if (response.statusCode == 200) {
        print('Server response: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> sendLocation(double latitude, double longitude) async {
    final String url = '$baseUrl/location';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (response.statusCode == 200) {
        print('Location sent successfully');
      } else {
        print('Error sending location: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

//  sending of users iinforation to the backend.
  Future<void> SendContent(String content) async {
// the first instance of the action to send the inforamtion

    final golden = await http.post(Uri.parse("$baseUrl/Content"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"Content": content}));
// then console  for the responce
    print(golden);
  }
}
