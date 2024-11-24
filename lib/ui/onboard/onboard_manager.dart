import 'package:shared_preferences/shared_preferences.dart';

class OnboardManager {
  static const _keyHasSeenOnboarding = 'hasSeenOnboarding';

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  Future<void> setHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }
}
