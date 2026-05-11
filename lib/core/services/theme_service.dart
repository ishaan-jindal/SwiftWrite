import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeService {
  final _box = Hive.box('settings');
  final _isDarkModeKey = 'isDarkModePreferred';
  final _isFallModeActiveKey = 'isFallModeActive';

  bool get isDarkModePreferred {
    return _box.get(_isDarkModeKey, defaultValue: false);
  }

  bool get isFallModeActive {
    return _box.get(_isFallModeActiveKey, defaultValue: false);
  }

  void setDarkModePreferred(bool isDarkMode) {
    _box.put(_isDarkModeKey, isDarkMode);
  }

  void setFallModeActive(bool isActive) {
    _box.put(_isFallModeActiveKey, isActive);
  }
}
