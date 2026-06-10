import 'package:flutter/material.dart';
import 'package:sneaker_care_app/models/order_model.dart';
import 'package:sneaker_care_app/services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _pesananList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<OrderModel> get pesananList => _pesananList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<OrderModel> get activeOrders {
    return _pesananList.where((order) => !order.isFinished && !order.isRejected).toList();
  }

  List<OrderModel> get finishedOrders => _pesananList.where((order) => order.isFinished).toList();
  List<OrderModel> get rejectedOrders => _pesananList.where((order) => order.isRejected).toList();

  int get totalOrders => _pesananList.length;
  int get waitingOrders => _pesananList.where((order) => order.isWaiting).length;
  int get processOrders => _pesananList.where((order) => order.isProcess).length;
  int get completedOrders => finishedOrders.length;
  int get rejectedOrdersCount => rejectedOrders.length;

  // Getter lama untuk profil_page.dart agar tetap kompatibel.
  int get totalPesanan => totalOrders;
  int get pesananAktif => activeOrders.length;
  int get pesananSelesai => completedOrders;

  OrderProvider() {
    fetchOrders(showLoading: false);
  }

  OrderModel? getOrderById(String id) {
    try {
      return _pesananList.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchOrders({bool showLoading = true, String? customerEmail}) async {
    if (showLoading) _setLoading(true);
    _errorMessage = null;

    final result = await ApiService.getOrders(customerEmail: customerEmail);

    if (result['success'] == true) {
      final data = result['data'];
      if (data is List) {
        _pesananList = data
            .whereType<Map>()
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _pesananList = [];
      }
    } else {
      _errorMessage = result['message']?.toString() ?? 'Gagal mengambil data.';
    }

    if (showLoading) {
      _setLoading(false);
    } else {
      notifyListeners();
    }
  }

  Future<bool> tambahPesanan({
    required String layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
    required String customerName,
    required String customerEmail,
    String? shoePhotoPath,
  }) async {
    _setSubmitting(true);
    _errorMessage = null;

    final result = await ApiService.addOrder(
      layanan: layanan,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
      customerName: customerName,
      customerEmail: customerEmail,
      shoePhotoPath: shoePhotoPath,
    );

    final success = result['success'] == true;
    if (success) {
      await fetchOrders(showLoading: false, customerEmail: customerEmail);
    } else {
      _errorMessage = result['message']?.toString() ?? 'Pesanan gagal dibuat.';
    }

    _setSubmitting(false);
    return success;
  }

  Future<bool> updatePesanan({
    required String id,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
    String? customerEmail,
  }) async {
    _setSubmitting(true);
    _errorMessage = null;

    final result = await ApiService.updateOrder(
      id: id,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
    );

    final success = result['success'] == true;
    if (success) {
      await fetchOrders(showLoading: false, customerEmail: customerEmail);
    } else {
      _errorMessage = result['message']?.toString() ?? 'Pesanan gagal diubah.';
    }

    _setSubmitting(false);
    return success;
  }

  Future<bool> updateStatus({
    required String id,
    required String status,
    String rejectionReason = '',
  }) async {
    _setSubmitting(true);
    _errorMessage = null;

    final result = await ApiService.updateStatus(
      id: id,
      status: status,
      rejectionReason: rejectionReason,
    );

    final success = result['success'] == true;
    if (success) {
      await fetchOrders(showLoading: false);
    } else {
      _errorMessage = result['message']?.toString() ?? 'Status gagal diubah.';
    }

    _setSubmitting(false);
    return success;
  }

  Future<bool> hapusPesanan(String id, {String? customerEmail}) async {
    _setSubmitting(true);
    _errorMessage = null;

    final result = await ApiService.deleteOrder(id: id);

    final success = result['success'] == true;
    if (success) {
      await fetchOrders(showLoading: false, customerEmail: customerEmail);
    } else {
      _errorMessage = result['message']?.toString() ?? 'Pesanan gagal dihapus.';
    }

    _setSubmitting(false);
    return success;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
