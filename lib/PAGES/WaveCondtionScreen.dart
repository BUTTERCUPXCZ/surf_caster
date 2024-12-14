import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaveConditionScreen extends StatefulWidget {
  @override
  _WaveConditionScreenState createState() => _WaveConditionScreenState();
}

class _WaveConditionScreenState extends State<WaveConditionScreen> {
  final TextEditingController _searchController = TextEditingController();
  double? latitude;
  double? longitude;
  Map<String, dynamic>? weatherData;
  String? errorMessage;
  bool isLoading = false;

  final String apiKey = '937d080c-a41d-11ef-ae24-0242ac130003-937d087a-a41d-11ef-ae24-0242ac130003'; // Replace with your StormGlass.io API key

  Future<void> fetchWeatherData(String location) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        latitude = locations.first.latitude;
        longitude = locations.first.longitude;

        final url =
            'https://api.stormglass.io/v2/weather/point?lat=$latitude&lng=$longitude&params=waveHeight,windSpeed';
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': apiKey},
        );

        if (response.statusCode == 200) {
          setState(() {
            weatherData = json.decode(response.body);
          });
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        weatherData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // AppBar and Search Bar combined
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0), // Only horizontal padding
          child: Column(
            children: [
              const SizedBox(height: 20), // Adjust vertical spacing
              SearchBar(
                controller: _searchController,
                hintText: 'Search location(e.g, Mati City)',
                leading: Icon(Icons.search, color: const Color.fromARGB(255, 34, 34, 34)),
               onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    fetchWeatherData(value.trim());
                  }
                  }
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : weatherData != null
                  ? WeatherDetails(
                      weatherData: weatherData!,
                      location: _searchController.text,
                    )
                  : errorMessage != null
                      ? ErrorDisplay(
                          errorMessage: errorMessage!,
                          onRetry: () => fetchWeatherData(_searchController.text),
                        )
                      : Center(
                          child: Text(
                            'Enter a location to view wave conditions',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
        ),
      ],
    ),
  );
}

}

class WeatherDetails extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  final String location;

  WeatherDetails({required this.weatherData, required this.location});

  @override
  Widget build(BuildContext context) {
    final waveHeight = weatherData['hours'][0]['waveHeight']['sg'] ?? 'N/A';
    final windSpeed = weatherData['hours'][0]['windSpeed']['sg'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            location,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.waves, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wave Height', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text('$waveHeight m', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32, thickness: 1, color: Colors.grey[300]),
                  Row(
                    children: [
                      Icon(Icons.air, color: Colors.green, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wind Speed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text('$windSpeed m/s', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  ErrorDisplay({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
