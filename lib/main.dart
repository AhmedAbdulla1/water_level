import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distance Sensor App',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),
      ),
      home: const DistanceSensorApp(),
    );
  }
}

class DistanceSensorApp extends StatefulWidget {
  const DistanceSensorApp({super.key});

  @override
  DistanceSensorAppState createState() => DistanceSensorAppState();
}

class DistanceSensorAppState extends State<DistanceSensorApp> {
  double _distance = 0.0;
  final _lowLevelController = TextEditingController();
  final _highLevelController = TextEditingController();

  Future<void> _sendDataToServer(double lowLevel, double highLevel) async {
    final url = 'http://192.168.4.1/low=$lowLevel&high=$highLevel';
    await http.get(Uri.parse(url));
  }

  Future<void> _refreshData() async {
    final response = await http.get(Uri.parse('http://192.168.4.1/distance'));
    final responseData = json.decode(response.body) as Map<String, dynamic>;
    setState(() {
      _distance = responseData['distance'] + 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) => _refreshData());
  }

  @override
  void dispose() {
    _lowLevelController.dispose();
    _highLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Distance Measurement'),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Distance: $_distance cm',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextField(
                controller: _lowLevelController,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Low Level (cm)',
                  labelStyle: const TextStyle(fontSize: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextField(
                controller: _highLevelController,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'High Level (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () {
                final lowLevel = double.tryParse(_lowLevelController.text);
                final highLevel = double.tryParse(_highLevelController.text);
                if (lowLevel != null && highLevel != null) {
                  _sendDataToServer(lowLevel, highLevel);
                }
              },
              child: const Text('Send levels to system '),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () => _refreshData(),
              child: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }
}

