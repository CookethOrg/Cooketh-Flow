import 'dart:async';
import 'package:flutter/material.dart';

class LoadingProvider with ChangeNotifier {
  double _progress = 0.0;
  int _tooltipIndex = 0;
  int _imageIndex = 0;
  Timer? _imageTimer;
  Timer? _tooltipTimer;
  bool _isLoading = false;

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
  bool get isLoading => _isLoading;
  int get tooltipIndex => _tooltipIndex;
  int get imageIndex => _imageIndex;
  String get currentTooltip => tooltips[_tooltipIndex];
  String get currentImage => imageSequence[_imageIndex];

  void startLoading() {
    _isLoading = true;
    _progress = 0.0;
    notifyListeners();

    // Start image and tooltip animations
    _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _imageIndex = (_imageIndex + 1) % imageSequence.length;
      notifyListeners();
    });

    _tooltipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _tooltipIndex = (_tooltipIndex + 1) % tooltips.length;
      notifyListeners();
    });
  }

  void updateProgress(double newProgress) {
    _progress = newProgress.clamp(0.0, 1.0);
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    _imageTimer?.cancel();
    _tooltipTimer?.cancel();
    _progress = 1.0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopLoading();
    super.dispose();
  }
}