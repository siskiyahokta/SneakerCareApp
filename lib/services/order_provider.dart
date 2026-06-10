import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<OrderModel> get pesananList => orders;
  List<OrderModel> get daftarPesanan => orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOrders => _orders.length;
  int get totalPesanan => totalOrders;

  int get waitingOrders => _orders.where((o) => o.isWaiting).length;
  int get processOrders => _orders.where((o) => o.isInProgress).length;
  int get rejectedOrders => _orders.where((o) => o.isRejected).length;
  int get completedOrders => _orders.where((o) => o.isFinished).length;
  int get pesananSelesai => completedOrders;

  List<OrderModel> get activeOrders =>
      _orders.where((o) => !o.isFinished && !o.isRejected).toList();
  int get pesananAktif => activeOrders.length;

  double get averageRating {
    final rated = _orders.where((o) => o.rating > 0).toList();
    if (rated.isEmpty) return 0;
    final total = rated.fold<int>(0, (sum, order) => sum + order.rating);
    return total / rated.length;
  }

  Future<void> fetchOrders() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.getOrders();

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> rawList = data is List ? data : [];
      _orders
        ..clear()
        ..addAll(rawList.map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item))));
      _sortOrders();
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal mengambil data.';
    }

    _setLoading(false);
  }

  Future<void> loadOrders() => fetchOrders();
  Future<void> getOrders() => fetchOrders();
  Future<void> ambilPesanan() => fetchOrders();

  Future<bool> tambahPesanan({
    required String layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    String catatan = '',
    String customerName = '',
    String customerEmail = '',
    int estimasiBiaya = 0,
    File? shoePhotoFile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.addOrder(
      layanan: layanan,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
      customerName: customerName,
      customerEmail: customerEmail,
      estimasiBiaya: estimasiBiaya,
      shoePhotoFile: shoePhotoFile,
    );

    if (result['success'] == true) {
      await fetchOrders();
      return true;
    }

    _errorMessage = result['message']?.toString() ?? 'Gagal menambahkan pesanan.';
    _setLoading(false);
    return false;
  }

  Future<bool> updatePesanan({
    required String id,
    String? layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    String catatan = '',
    int estimasiBiaya = 0,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.updateOrder(
      id: id,
      layanan: layanan,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
      estimasiBiaya: estimasiBiaya,
    );

    if (result['success'] == true) {
      await fetchOrders();
      return true;
    }

    _errorMessage = result['message']?.toString() ?? 'Gagal mengubah pesanan.';
    _setLoading(false);
    return false;
  }

  Future<bool> hapusPesanan(String id) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.deleteOrder(id: id);

    if (result['success'] == true) {
      _orders.removeWhere((order) => order.id == id);
      _setLoading(false);
      return true;
    }

    _errorMessage = result['message']?.toString() ?? 'Gagal membatalkan pesanan.';
    _setLoading(false);
    return false;
  }

  Future<bool> deleteOrder(String id) => hapusPesanan(id);

  Future<bool> updateStatus({
    required String id,
    required String status,
    String customerEmail = '',
    String rejectionReason = '',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.updateStatus(
      id: id,
      status: status,
      customerEmail: customerEmail,
      rejectionReason: rejectionReason,
    );

    if (result['success'] == true) {
      final index = _orders.indexWhere((order) => order.id == id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: status,
          rejectionReason: rejectionReason,
        );
      }
      await fetchOrders();
      return true;
    }

    _errorMessage = result['message']?.toString() ?? 'Gagal update status.';
    _setLoading(false);
    return false;
  }

  Future<bool> submitReview({
    required String id,
    required int rating,
    required String review,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.submitReview(
      id: id,
      rating: rating,
      review: review,
    );

    if (result['success'] == true) {
      final index = _orders.indexWhere((order) => order.id == id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          rating: rating,
          review: review,
          reviewedAt: DateTime.now().toIso8601String(),
        );
      }
      await fetchOrders();
      return true;
    }

    _errorMessage = result['message']?.toString() ?? 'Gagal mengirim rating.';
    _setLoading(false);
    return false;
  }

  List<OrderModel> customerOrders(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return orders;
    return _orders
        .where((order) => order.customerEmail.trim().toLowerCase() == cleanEmail)
        .toList();
  }

  void _sortOrders() {
    _orders.sort((a, b) {
      final bDate = DateTime.tryParse(b.createdAt);
      final aDate = DateTime.tryParse(a.createdAt);
      if (aDate == null || bDate == null) return b.id.compareTo(a.id);
      return bDate.compareTo(aDate);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
