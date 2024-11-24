import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // For geocoding
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
      // Geocode the location to get latitude and longitude
      List<Location> locations = await locationFromAddress(location);
      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        });

        // Fetch wave height data from StormGlass API
        final url =
            'https://api.stormglass.io/v2/weather/point?lat=$latitude&lng=$longitude&params=waveHeight,windSpeed';
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': apiKey, // Add API key to headers
          },
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
        errorMessage = 'Failed to fetch location or weather data: $e';
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with styling
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter location (e.g., San Francisco)',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final location = _searchController.text.trim();
                      if (location.isNotEmpty) {
                        fetchWeatherData(location);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                      backgroundColor: Colors.white,
                    ),
                    child: Icon(Icons.search, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Main content
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : weatherData == null
                      ? errorMessage != null
                          ? ErrorDisplay(errorMessage: errorMessage!, onRetry: () => fetchWeatherData(_searchController.text))
                          : Center(child: Text('Enter a location to fetch data'))
                      : WeatherDetails(weatherData: weatherData!, location: _searchController.text),
            ),
          ],
        ),
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
    // Extracting wave height and wind speed
    final waveHeight = weatherData['hours'][0]['waveHeight']['sg'] ?? 'N/A'; // sg is StormGlass-specific
    final windSpeed = weatherData['hours'][0]['windSpeed']['sg'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            location,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wave Height', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('$waveHeight m', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Wind Speed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('$windSpeed m/s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          SizedBox(height: 8),
          Text(errorMessage, textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text('Retry'))
        ],
      ),
    );
  }
}
