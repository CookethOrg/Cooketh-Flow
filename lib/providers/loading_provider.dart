import 'dart:async';
import 'package:flutter/material.dart';

class LoadingProvider with ChangeNotifier {
  double _progress = 0.0;
  int _tooltipIndex = 0;
  int _imageIndex = 0;
  late Timer _progressTimer;
  late Timer _imageTimer;
  late Timer _tooltipTimer;

  final List<String> tooltips = [
    "Watch your ideas come to life",
    "Loading up your creativity",
    "Preparing something amazing",
    "Almost there, hang tight!",
    "Bringing magic to your screen"
  ];

  final List<String> imageSequence = [
    'assets/Frame 266.png',
    'assets/Frame 268.png',
    'assets/Frame 267.png',
    'assets/Frame 268.png',
    'assets/Frame 266.png',
  ];

  double get progress => _progress;
  int get tooltipIndex => _tooltipIndex;
  int get imageIndex => _imageIndex;
  String get currentTooltip => tooltips[_tooltipIndex];
  String get currentImage => imageSequence[_imageIndex];

  LoadingProvider() {
    _startTimers();
  }

  void _startTimers() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_progress < 1.0) {
        _progress += 0.02;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });

    _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _imageIndex = (_imageIndex + 1) % imageSequence.length;
      notifyListeners();
    });

    _tooltipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _tooltipIndex = (_tooltipIndex + 1) % tooltips.length;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    _imageTimer.cancel();
    _tooltipTimer.cancel();
    super.dispose();
  }
}
