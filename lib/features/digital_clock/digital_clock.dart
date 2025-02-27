import 'package:flutter/material.dart';
import 'dart:async';

class DigitalClock extends StatefulWidget {
  final bool use24HourFormat;

  const DigitalClock({super.key, required this.use24HourFormat});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Timer _timer;
  late DateTime _currentTime;

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
    super.dispose();
  }

  String _formatTime(DateTime time) {
    if (widget.use24HourFormat) {
      return time.toString().substring(11, 19);
    } else {
      int hour = time.hour % 12;
      if (hour == 0) hour = 12;
      String period = time.hour < 12 ? 'AM' : 'PM';
      return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')} $period";
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_currentTime),
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDate(_currentTime),
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}