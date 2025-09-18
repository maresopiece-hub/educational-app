import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class LocalSyncService {
  static const _kPendingKey = 'local_pending_items';
  static const _kErrorKey = 'sync_errors';

  final Connectivity _connectivity;
  final NotificationService _notification;

  LocalSyncService({Connectivity? connectivity, NotificationService? notification})
      : _connectivity = connectivity ?? Connectivity(),
        _notification = notification ?? DefaultNotificationService();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  /// Store a pending item (plan or progress) as JSON. Caller provides a
  /// map containing a `type` field ('plan' or 'progress') and a `data` map.
  Future<void> addPending(Map<String, dynamic> item) async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_kPendingKey) ?? [];
    if (item['id'] == null) item['id'] = _makeId();
    item['retries'] = 0;
    list.add(jsonEncode(item));
    await prefs.setStringList(_kPendingKey, list);
  }

  Future<List<Map<String, dynamic>>> _readAllPending() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_kPendingKey) ?? [];
    return list.map((s) => Map<String, dynamic>.from(jsonDecode(s))).toList();
  }

  Future<void> _clearPending() async {
    final prefs = await _prefs;
    await prefs.remove(_kPendingKey);
  }

  // Public wrappers for tests and callers.
  Future<List<Map<String, dynamic>>> readAllPending() => _readAllPending();
  Future<void> clearPending() => _clearPending();

  /// Try to sync pending items to Firestore. If offline, just return.
  /// This method uses per-item idempotency via a generated id and retries up
  /// to 3 times for transient failures.
  Future<void> syncPending(String userId) async {
  final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;
    final pending = await _readAllPending();
    if (pending.isEmpty) return;
    // Try to access Firestore; if it's not initialized (tests), treat as transient
    // failure: record failed metric and notify user but don't throw.
    FirebaseFirestore db;
    try {
      db = FirebaseFirestore.instance;
    } catch (e) {
      final prefs = await _prefs;
      await prefs.setInt(_kErrorKey, pending.length);
      try {
        await _notification.showSimpleNotification(1001, 'Sync failed', 'Sync failed: ${pending.length} errors, retrying...');
      } catch (_) {}
      return;
    }
    final remaining = <Map<String, dynamic>>[];

    for (final item in pending) {
      final id = item['id']?.toString() ?? _makeId();
      final type = item['type'] as String? ?? 'plan';
      int retries = (item['retries'] as int?) ?? 0;

      try {
        final docRef = db.collection('users').doc(userId).collection(type == 'plan' ? 'plans' : 'progress').doc(id);
        // Use set with merge to be idempotent if item already exists.
        await docRef.set(item['data'] ?? {}, SetOptions(merge: true));
      } catch (e) {
        retries += 1;
        debugPrint('LocalSyncService: sync of $id failed (attempt $retries): $e');
        if (retries < 3) {
          item['retries'] = retries;
          remaining.add(item);
        } else {
          debugPrint('LocalSyncService: dropping $id after $retries attempts');
        }
      }
    }

    final prefs = await _prefs;
    if (remaining.isEmpty) {
      await _clearPending();
      // reset failure metric
      await prefs.setInt(_kErrorKey, 0);
    } else {
      await prefs.setStringList(_kPendingKey, remaining.map((e) => jsonEncode(e)).toList());
      final failed = remaining.length;
      await prefs.setInt(_kErrorKey, failed);
      // notify user that sync had failures (non-blocking)
      try {
        await _notification.showSimpleNotification(1001, 'Sync failed', 'Sync failed: $failed errors, retrying...');
      } catch (_) {}
    }
  }

  /// Listen and auto-sync when connectivity changes to online.
  void startConnectivityListener(String userId) {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncPending(userId);
      }
    });
  }

  /// Return current pending count
  Future<int> pendingCount() async {
    final list = (await _prefs).getStringList(_kPendingKey) ?? [];
    return list.length;
  }

  String _makeId() => '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 32)}';
}
