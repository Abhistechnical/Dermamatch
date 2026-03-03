// lib/providers/scan_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/scan_result.dart';

enum ScanStatus { idle, analyzing, saving, done, error }

class ScanProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  ScanStatus _status = ScanStatus.idle;
  ScanResult? _currentResult;
  List<ScanResult> _history = [];
  String? _error;
  bool _historyLoaded = false;
  bool _isLoading = false;

  ScanStatus get status => _status;
  ScanResult? get currentResult => _currentResult;
  List<ScanResult> get history => _history;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAnalyzing =>
      _status == ScanStatus.analyzing || _status == ScanStatus.saving;

  Future<ScanResult?> analyze(File imageFile) async {
    _status = ScanStatus.analyzing;
    _error = null;
    _currentResult = null;
    notifyListeners();

    try {
      final result = await _api.analyzeFace(imageFile);
      _status = ScanStatus.saving;
      notifyListeners();

      final saved = await _api.saveScan(result);
      _currentResult = saved;
      _history.insert(0, saved);
      _status = ScanStatus.done;
      notifyListeners();
      return saved;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = ScanStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (_historyLoaded && !refresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _api.fetchScans();
      _historyLoaded = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _status = ScanStatus.idle;
    _currentResult = null;
    _error = null;
    notifyListeners();
  }

  void setCurrentResult(ScanResult result) {
    _currentResult = result;
    notifyListeners();
  }

  Future<void> trackAffiliateClick(String productId) async {
    await _api.trackAffiliateClick(productId);
  }
}
