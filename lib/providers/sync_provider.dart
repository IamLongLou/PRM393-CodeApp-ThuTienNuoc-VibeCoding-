import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bill.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';

class SyncProvider with ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Bill> _unsynced = [];
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  List<Bill> get unsyncedBills => _unsynced;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncProvider() {
    fetchUnsyncedBills();
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timeString = prefs.getString('lastSyncTime');
    if (timeString != null) {
      _lastSyncTime = DateTime.tryParse(timeString);
      notifyListeners();
    }
  }

  Future<void> fetchUnsyncedBills() async {
    _unsyncedBills = await _dbHelper.getUnsyncedBills();
    notifyListeners();
  }

  Future<void> syncAll() async {
    if (_unsyncedBills.isEmpty) return;
    
    _isSyncing = true;
    notifyListeners();

    // 1. Gọi API để đẩy dữ liệu lên SQL Server thật
    final response = await ApiService.syncBills(_unsyncedBills);
    
    if (response != null) {
      // 2. Cập nhật trạng thái isSynced = 1 trong SQLite
      await _dbHelper.markBillsAsSynced(_unsyncedBills);
      
      // 3. Clear danh sách local
      _unsyncedBills = [];

      // 4. Cập nhật lastSyncTime
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSyncTime', _lastSyncTime!.toIso8601String());
    }
    _isSyncing = false; notifyListeners();
  }
}
