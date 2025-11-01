import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Account {
  String name;
  String email;
  String profileImageUrl;
  int totalScore;
  int gamesPlayed;

  Account({
    this.name = 'Guest User',
    this.email = 'guest@example.com',
    this.profileImageUrl = '',
    this.totalScore = 0,
    this.gamesPlayed = 0,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      name: json['name'] ?? 'Guest User',
      email: json['email'] ?? 'guest@example.com',
      profileImageUrl: json['profileImageUrl'] ?? '',
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
    };
  }

  static Future<Account> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountJson = prefs.getString('account');
    
    if (accountJson == null) {
      return Account();
    }
    
    try {
      return Account.fromJson(jsonDecode(accountJson));
    } catch (e) {
      return Account();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('account', jsonEncode(toJson()));
  }

  void updateStats(int score) {
    totalScore += score;
    gamesPlayed += 1;
    save();
  }
}