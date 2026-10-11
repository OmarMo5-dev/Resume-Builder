// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ThemeController extends ChangeNotifier {
//   ThemeController._();
//
//   static final ThemeController instance = ThemeController._();
//
//   static const String _preferenceKey = 'business_os_theme_mode';
//
//   ThemeMode _themeMode = ThemeMode.light;
//   ThemeMode get themeMode => _themeMode;
//
//   bool _loaded = false;
//   bool get isLoaded => _loaded;
//
//   Future<void> load() async {
//     if (_loaded) return;
//
//     try {
//       final preferences = await SharedPreferences.getInstance();
//       _themeMode = _themeModeFromString(preferences.getString(_preferenceKey));
//     } catch (error) {
//       debugPrint('Could not load theme preference: $error');
//       _themeMode = ThemeMode.light;
//     } finally {
//       _loaded = true;
//     }
//   }
//
//   Future<void> setThemeMode(ThemeMode mode) async {
//     if (_themeMode == mode) return;
//     _themeMode = mode;
//     notifyListeners();
//
//     try {
//       final preferences = await SharedPreferences.getInstance();
//       await preferences.setString(_preferenceKey, _themeModeToString(mode));
//     } catch (error) {
//       debugPrint('Could not save theme preference: $error');
//     }
//   }
//
//   ThemeMode _themeModeFromString(String? value) {
//     switch (value) {
//       case 'dark':
//         return ThemeMode.dark;
//       case 'system':
//         return ThemeMode.system;
//       case 'light':
//       default:
//         return ThemeMode.light;
//     }
//   }
//
//   String _themeModeToString(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.dark:
//         return 'dark';
//       case ThemeMode.system:
//         return 'system';
//       case ThemeMode.light:
//         return 'light';
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _preferenceKey = 'business_os_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ─────────────────────────────────────────────────────────
  // NEW: convenience getters so the UI can drive switches
  // directly, without knowing about ThemeMode.
  // ─────────────────────────────────────────────────────────

  /// True when the app is currently in explicit dark mode.
  bool get isDark => _themeMode == ThemeMode.dark;

  /// True when the app is following the OS theme.
  bool get followSystem => _themeMode == ThemeMode.system;

  // ─────────────────────────────────────────────────────────
  // NEW: switch-friendly setters that delegate to setThemeMode
  // so persistence keeps working exactly as before.
  // ─────────────────────────────────────────────────────────

  /// Toggle explicit dark/light mode. Does nothing if following system.
  void setDark(bool value) {
    if (followSystem) return;
    setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  /// Turn "follow system" on or off.
  ///
  /// When turning it OFF, we fall back to whatever the platform is
  /// currently showing, so the UI doesn't visually jump.
  void setFollowSystem(bool value, {Brightness? platformBrightness}) {
    if (value) {
      setThemeMode(ThemeMode.system);
    } else {
      final isPlatformDark = platformBrightness == Brightness.dark;
      setThemeMode(isPlatformDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  // ─────────────────────────────────────────────────────────
  // Existing load / setThemeMode / serialization — unchanged.
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    if (_loaded) return;

    try {
      final preferences = await SharedPreferences.getInstance();
      _themeMode = _themeModeFromString(preferences.getString(_preferenceKey));
    } catch (error) {
      debugPrint('Could not load theme preference: $error');
      _themeMode = ThemeMode.light;
    } finally {
      _loaded = true;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_preferenceKey, _themeModeToString(mode));
    } catch (error) {
      debugPrint('Could not save theme preference: $error');
    }
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}