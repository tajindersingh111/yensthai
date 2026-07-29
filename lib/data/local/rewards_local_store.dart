import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local gamification: streaks and favorite product ids (sync-friendly later).
class RewardsLocalStore {
  static const _keyLastVisit = 'yens_last_visit_day';
  static const _keyStreak = 'yens_streak_days';
  static const _keyFavorites = 'yens_favorite_product_ids';

  static Future<int> streakDays() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyStreak) ?? 0;
  }

  static Future<List<String>> favoriteIds() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_keyFavorites);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => '$e').toList();
  }

  static Future<void> toggleFavorite(String productId) async {
    final p = await SharedPreferences.getInstance();
    final current = await favoriteIds();
    if (current.contains(productId)) {
      current.remove(productId);
    } else {
      current.add(productId);
    }
    await p.setString(_keyFavorites, jsonEncode(current));
  }

  static Future<bool> isFavorite(String productId) async {
    final ids = await favoriteIds();
    return ids.contains(productId);
  }

  /// Call on app resume / home open. Returns new streak count.
  static Future<int> recordDailyVisit() async {
    final p = await SharedPreferences.getInstance();
    final today = _dayKey(DateTime.now());
    final last = p.getString(_keyLastVisit);
    var streak = p.getInt(_keyStreak) ?? 0;

    if (last == null) {
      streak = 1;
    } else if (last == today) {
      // same calendar day
    } else {
      final lastDate = DateTime.tryParse(last);
      if (lastDate != null) {
        final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
        if (_dayKey(lastDate) == yesterday) {
          streak += 1;
        } else if (_dayKey(lastDate) != today) {
          streak = 1;
        }
      } else {
        streak = 1;
      }
    }

    await p.setString(_keyLastVisit, today);
    await p.setInt(_keyStreak, streak);
    return streak;
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
