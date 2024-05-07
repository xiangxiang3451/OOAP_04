import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}
abstract class WeatherService {
  Future<Map<String, dynamic>> fetchWeather();
}

class RealWeatherService implements WeatherService {
  @override
  Future<Map<String, dynamic>> fetchWeather() async {
    const apiUrl = 'http://172.20.10.2:5000/weather'; 

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class DummyWeatherService implements WeatherService {
  @override
  Future<Map<String, dynamic>> fetchWeather() async {
    // Simulated weather data
    return {
      "city": "Tomsk",
      "temperature": -20,
      "description": "Snow"
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherService _weatherService = RealWeatherService(); // Change this to switch between real or dummy service
  String _city = '';
  int _temperature = 0;
  String _description = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.fetchWeather();
      setState(() {
        _city = weatherData['city'];
        _temperature = weatherData['temperature'];
        _description = weatherData['description'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Weather App'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _city,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_temperature°C',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _description,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Switch between real and dummy weather service
            _weatherService = _weatherService is RealWeatherService ? DummyWeatherService() : RealWeatherService();
            _isLoading = true; // Reset loading state
            _fetchWeather(); // Fetch weather data for the new service
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
