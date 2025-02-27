import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

import 'features/digital_clock/digital_clock.dart';
import 'features/timer/timer_list.dart';
import 'features/world_clock/city_time.dart';
import 'features/world_clock/city_data.dart';
import 'features/background/background_manager.dart';
import 'package:provider/provider.dart';

void main() {
  tzdata.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BackgroundManager(),
      child: MaterialApp(
        title: 'Desktop Clock',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
          ),
        ),
        home: const ClockPage(),
      ),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  bool _use24HourFormat = true;
  final List<CityTime> _cities = [];
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showBackgroundSettings() {
    final backgroundManager = context.read<BackgroundManager>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Background Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Use Shape Animation'),
              value: backgroundManager.useShapes,
              onChanged: (value) {
                backgroundManager.toggleBackgroundMode();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'Enter image URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_imageUrlController.text.isNotEmpty) {
                backgroundManager.setBackgroundImage(_imageUrlController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _addCity(String cityName, String timeZone) {
    setState(() {
      _cities.add(CityTime(cityName, timeZone));
    });
  }

  void _removeCity(int index) {
    setState(() {
      _cities.removeAt(index);
    });
  }

  void _showAddCityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController searchController = TextEditingController();
        List<CityData> filteredCities = CityDatabase.cities;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add City'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Cities',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredCities = CityDatabase.search(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            final city = filteredCities[index];
                            return ListTile(
                              title: Text(city.name),
                              subtitle: Text(city.timeZone),
                              onTap: () {
                                _addCity(city.name, city.timeZone);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    if (_use24HourFormat) {
      return time.toString().substring(11, 19);
    } else {
      int hour = time.hour % 12;
      if (hour == 0) hour = 12;
      String period = time.hour < 12 ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')} $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundManager = context.watch<BackgroundManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Clock'),
        actions: [
          IconButton(
            icon: Icon(_use24HourFormat ? Icons.schedule_outlined : Icons.schedule),
            onPressed: () {
              setState(() {
                _use24HourFormat = !_use24HourFormat;
              });
            },
            tooltip: '${_use24HourFormat ? "12" : "24"}-hour format',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showBackgroundSettings,
            tooltip: 'Background Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (backgroundManager.useShapes)
            CustomPaint(
              painter: BackgroundPainter(backgroundManager.shapes),
              child: Container(),
            )
          else if (backgroundManager.localImagePath != null)
            Image.file(
              File(backgroundManager.localImagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Digital Clock
                DigitalClock(use24HourFormat: _use24HourFormat),
                const SizedBox(height: 20),
                // World Clocks
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('World Clocks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _showAddCityDialog,
                      tooltip: 'Add City',
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 200,
                          padding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    city.cityName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _formatTime(city.currentTime),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    city.offset,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => _removeCity(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Remove City',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Timer List
                const Expanded(child: TimerList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
