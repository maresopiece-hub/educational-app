import 'package:shared_preferences/shared_preferences.dart';

/// Simple offline-first wrapper using SharedPreferences. Extend with work manager or background sync.
class LocalSyncService {
  Future<void> saveDraftPlan(String id, Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_$id', draft.toString());
  }

  Future<String?> loadDraftPlan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('draft_$id');
  }
}
