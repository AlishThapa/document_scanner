import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

class HistoryRepository {
  static const String _storageKey = 'scan_history';

  Future<List<ScanResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_storageKey) ?? [];
    return historyJson
        .map((item) => ScanResult.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> saveScan(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    final index = history.indexWhere((item) => item.id == result.id);
    if (index != -1) {
      history[index] = result;
    } else {
      history.insert(0, result);
    }

    final historyJson = history
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, historyJson);
  }

  Future<void> deleteScan(String id) async {
    await deleteMultipleScans([id]);
  }

  Future<void> deleteMultipleScans(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((item) => ids.contains(item.id));
    final historyJson = history
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, historyJson);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
