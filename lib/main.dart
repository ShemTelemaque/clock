import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Clock',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const ClockPage(),
    );
  }
}

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  late Timer _timer;
  late DateTime _currentTime;
  int _timerDuration = 0; // Duration in seconds
  bool _isTimerRunning = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerDuration > 0) {
      setState(() {
        _isTimerRunning = true;
      });
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timerDuration > 0) {
            _timerDuration--;
          } else {
            _stopTimer();
          }
        });
      });
    }
  }

  void _stopTimer() {
    setState(() {
      _isTimerRunning = false;
      _countdownTimer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _timerDuration = 0;
      _isTimerRunning = false;
      _countdownTimer?.cancel();
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Digital Clock
            Text(
              _currentTime.toString().substring(11, 19),
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Timer Display
            Text(
              _formatDuration(_timerDuration),
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            // Timer Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: _isTimerRunning ? _stopTimer : _startTimer,
                  iconSize: 40,
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _resetTimer,
                  iconSize: 40,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Timer Duration Input
            if (!_isTimerRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _timerDuration += 60; // Add 1 minute
                      });
                    },
                    child: const Text('+1m'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _timerDuration += 300; // Add 5 minutes
                      });
                    },
                    child: const Text('+5m'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _timerDuration += 900; // Add 15 minutes
                      });
                    },
                    child: const Text('+15m'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
