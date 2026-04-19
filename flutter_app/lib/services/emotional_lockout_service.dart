import "package:flutter/foundation.dart";
import 'package:flutter/material.dart';

class EmotionalLockoutService extends ChangeNotifier {
  int _consecutiveLosses = 0;
  int _overrideCount = 0;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  void recordLoss() {
    _consecutiveLosses++;
    _checkLockout();
  }

  void recordWin() {
    _consecutiveLosses = 0;
    _checkLockout();
  }

  void recordOverride() {
    _overrideCount++;
     _checkLockout();
  }

  void resetOverrides(){
      _overrideCount = 0;
      _checkLockout();
  }

  void _checkLockout() {
    if (_consecutiveLosses >= 3 || _overrideCount >=3) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }
    notifyListeners();
  }
}
