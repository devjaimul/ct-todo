import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides local caching via SharedPreferences.
/// Used for offline-first todo storage and pending operation queue.
class CacheService extends GetxService {
  late SharedPreferences _prefs;

  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Generic Helpers ────────────────────────────────────────────────────

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  // ── JSON List Helpers (for caching todos) ──────────────────────────────

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> data) {
    return _prefs.setString(key, jsonEncode(data));
  }

  // ── Pending Operations Queue ───────────────────────────────────────────

  List<Map<String, dynamic>> getPendingOps(String key) => getJsonList(key);

  Future<void> addPendingOp(String key, Map<String, dynamic> op) async {
    final ops = getPendingOps(key);
    ops.add(op);
    await setJsonList(key, ops);
  }

  Future<void> clearPendingOps(String key) async {
    await remove(key);
  }

  // ── Clear All ──────────────────────────────────────────────────────────

  Future<bool> clearAll() => _prefs.clear();
}
