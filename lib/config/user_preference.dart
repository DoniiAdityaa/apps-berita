import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  final SharedPreferences prefs;
  UserPreference(this.prefs);

  Future<void> setToken(String newToken) async {
    debugPrint("SAVED TOKEN => $newToken");
    await prefs.setString("token", newToken);
  }

  String? getToken() {
    return prefs.getString("token");
  }

  Future<void> setOnChat(bool onChat) async {
    await prefs.setBool("chat", onChat);
  }

  bool getOnChat() {
    return prefs.getBool("chat") ?? false;
  }

  // bookmark articles
  Future<void> setBookmarkedArticles(List<String> urls) async {
    await prefs.setStringList("bookmarked_articles", urls);
  }

  List<String> getBookmarkedArticles() {
    return prefs.getStringList("bookmarked_articles") ?? [];
  }

  // darkmode
  bool isDarkMode() {
    return prefs.getBool("dark_mode") ?? false;
  }

  // onboarding status
  Future<void> setHasSeenOnboarding(bool hasSeen) async {
    await prefs.setBool("has_seen_onboarding", hasSeen);
  }

  bool hasSeenOnboarding() {
    return prefs.getBool("has_seen_onboarding") ?? false;
  }
}
