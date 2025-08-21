import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonSettingsProvider extends ChangeNotifier {
  static const int numControlButtons = 9;
  static const int numTotalButtons = 10;
  static const List<bool> defaultButtonEnabled = [
    false,
    true,
    false,
    true,
    false,
    true,
    false,
    true,
    false,
    false,
  ];

  List<bool> _buttonEnabled = List.from(defaultButtonEnabled);
  bool _isLoaded = false;

  List<bool> get buttonEnabled => _buttonEnabled;
  bool get isLoaded => _isLoaded;

  bool getButtonState(int index) {
    if (index >= 0 && index < _buttonEnabled.length) {
      return _buttonEnabled[index];
    }
    return false;
  }

  void setButtonState(int index, bool value) {
    if (index >= 0 && index < _buttonEnabled.length) {
      _buttonEnabled[index] = value;
      notifyListeners();
      _saveSettings();
    }
  }

  void resetToDefaults() {
    _buttonEnabled = List.from(defaultButtonEnabled);
    notifyListeners();
    _saveSettings();
  }

  Future<void> loadSettings() async {
    if (_isLoaded) return; // 避免重複加載

    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < numTotalButtons; i++) {
      _buttonEnabled[i] =
          prefs.getBool('buttonEnabled_$i') ?? defaultButtonEnabled[i];
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _buttonEnabled.length; i++) {
      await prefs.setBool('buttonEnabled_$i', _buttonEnabled[i]);
    }
  }
}
