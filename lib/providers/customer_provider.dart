import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/bill.dart';
import '../services/database_helper.dart';
import '../services/api_service.dart';

class CustomerProvider with ChangeNotifier {
  final _db = DatabaseHelper.instance;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = "";
  DateTime? _lastSyncTime;

  List<Customer> get customers => _filteredCustomers.isEmpty && _searchQuery.isEmpty ? _customers : _filteredCustomers;
  List<Customer> get allCustomers => _customers;
  bool get isLoading => _isLoading;
  DateTime? get lastSyncTime => _lastSyncTime;

  CustomerProvider() { fetch(); }

  Future<void> fetch() async {
    _isLoading = true; 
    notifyListeners();

    // 1. Thử cập nhật từ API nếu có mạng (Back-ground refresh)
    refreshFromServer();

    // 2. Luôn ưu tiên lấy từ SQLite trước để UI hiện lên ngay
    _customers = await _repository.getAll();
    _filteredCustomers = [];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.bootstrap();
      if (data != null) {
        final List remoteC = data['customers'];
        final List remoteB = data['bills'];
        await _db.upsertCustomers(remoteC.map((e) => Customer.fromMap(e)).toList());
        for (var b in remoteB) {
          await _db.insertBill(Bill.fromMap(b).copyWith(isSynced: true));
        }
        _customers = await _db.getAllCustomers();
        _lastSyncTime = DateTime.now();
        if (_searchQuery.isNotEmpty) searchCustomers(_searchQuery);
      }
    } catch (e) {
      debugPrint("Refresh error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String q) {
    _searchQuery = q.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredCustomers = [];
    } else {
      _filteredCustomers = _customers.where((c) => 
        c.name.toLowerCase().contains(_searchQuery) || 
        c.code.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    notifyListeners();
  }
}
