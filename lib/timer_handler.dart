import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerHandler extends ChangeNotifier {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  // Public getters
  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;

  /// Start the timer if not already running
  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      // Fire a periodic callback every second
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _elapsed = _elapsed + const Duration(seconds: 1);
        notifyListeners();
      });
    }
  }

  /// Stop (pause) the timer if running
  void stopTimer() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
    }
  }

  /// Reset timer back to 0 and optionally stop it
  void resetTimer({bool alsoStop = true}) {
    if (alsoStop) {
      stopTimer();
    }
    _elapsed = Duration.zero;
    notifyListeners();
  }

  /// Format [elapsed] as HH:MM:SS
  String get formattedTime {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
