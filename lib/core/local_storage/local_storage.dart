import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  static const String onboardingKey = 'onboarding_seen';

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(onboardingKey, true);
  }

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(onboardingKey) ?? false;
  }

}