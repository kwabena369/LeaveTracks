import 'dart:async';
//ghost 👻 
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpHelper {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';

  Future<void> testBackend(String message) async {
    const String url = '$baseUrl/test';
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
    const String url = '$baseUrl/location';
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

  Future<String> SendContent(String content) async {
// the first instance of the action to send the inforamtion

    final golden = await http.post(Uri.parse("$baseUrl/Content"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"Content": content}));
// then console  for the responce
    print(golden);
    if (golden.statusCode == 200) {
      return golden.body;
    } else {
      return "Error";
    }
  }
}
