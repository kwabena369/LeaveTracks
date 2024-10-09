//  this is the function for bring all the the trip and thier locationCordinate
import 'package:http/http.dart' as http;

//  the baseUrl
const String baseUrl = 'https://leave-tracks-backend.vercel.app';

Future<void> AllRoutes() async {
  final valueNow = await http.get(Uri.parse('$baseUrl/SavedRoutes'));
     // 
}
