//  this is the function for bring all the the trip and thier locationCordinate
import 'package:http/http.dart' as http;

//  the baseUrl
const String baseUrl = 'https://leave-tracks-backend.vercel.app';

Future<void> AllRoutes() async {
//  for the routes
  final value_now = await http.get(Uri.parse('$baseUrl/SavedRoutes'));
  //  then base on that we console.log them out
  print(value_now.body);
  
}
