import 'dart:convert';
import 'package:http/http.dart' as http;

class MarineWeatherService {
  final String apiKey = 'd3d649753f948a659599cf4f6707fe35';
  final String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getMarineWeather(double lat, double lon) async {
    final url = Uri.parse('$apiUrl?lat=$lat&lon=$lon&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }
}
