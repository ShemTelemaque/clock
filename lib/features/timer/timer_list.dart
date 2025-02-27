import 'package:flutter/material.dart';
import 'dart:async';
import 'timer_data.dart';

class TimerList extends StatefulWidget {
  const TimerList({super.key});

  @override
  State<TimerList> createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  final List<TimerData> _timers = [];
  //int _currentTimerIndex = 0;
  int _timerCount = 0;

  void _addNewTimer() {
    setState(() {
      _timerCount++;
      _timers.add(TimerData('Timer $_timerCount'));
    });
  }

  void _startTimer(int index) {
    final timer = _timers[index];
    if (timer.duration > 0 && !timer.isRunning) {
      final startTime = DateTime.now();
      setState(() {
        timer.isRunning = true;
      });
      timer.countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (timer.duration > 0) {
          final currentTime = DateTime.now();
          final elapsedSeconds = currentTime.difference(startTime).inMilliseconds / 1000;
          setState(() {
            timer.duration = (timer.duration - elapsedSeconds).clamp(0.0, 86400.0);
          });
          if (timer.duration <= 0) {
            t.cancel();
            _stopTimer(index);
          }
        } else {
          t.cancel();
          _stopTimer(index);
        }
      });
    }
  }

  void _stopTimer(int index) {
    final timer = _timers[index];
    setState(() {
      timer.isRunning = false;
      timer.countdownTimer?.cancel();
    });
  }

  void _resetTimer(int index) {
    final timer = _timers[index];
    setState(() {
      timer.duration = 0.0;
      timer.isRunning = false;
      timer.countdownTimer?.cancel();
    });
  }

  void _adjustTimer(int index, double seconds) {
    final timer = _timers[index];
    setState(() {
      timer.duration = (timer.duration + seconds).clamp(0.0, 86400.0); // Max 24 hours
    });
  }

  void _removeTimer(int index) {
    final timer = _timers[index];
    timer.dispose();
    setState(() {
      _timers.removeAt(index);
    });
  }

  String _formatDuration(double duration) {
    final totalSeconds = duration.round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: ListView.builder(
        itemCount: _timers.length + 1,
        itemBuilder: (context, index) {
          if (index == _timers.length) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _addNewTimer,
                child: const Text('Add Timer'),
              ),
            );
          }
          final timer = _timers[index];
          return ListTile(
            title: Text(timer.label),
            subtitle: Text(_formatDuration(timer.duration)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: timer.isRunning ? null : () => _adjustTimer(index, -60.0),
                  tooltip: 'Decrease by 1 minute',
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: timer.isRunning ? null : () => _adjustTimer(index, 60.0),
                  tooltip: 'Increase by 1 minute',
                ),
                IconButton(
                  icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (timer.isRunning) {
                      _stopTimer(index);
                    } else {
                      _startTimer(index);
                    }
                  },
                  tooltip: timer.isRunning ? 'Pause' : 'Start',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _resetTimer(index),
                  tooltip: 'Reset',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeTimer(index),
                  tooltip: 'Delete',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.dispose();
    }
    super.dispose();
  }
}