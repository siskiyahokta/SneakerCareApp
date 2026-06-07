import 'package:flutter/material.dart';
import 'package:sneaker_care_app/services/api_service.dart';

class OrderModel {
  String id;
  String layanan;
  String merkSepatu;
  String bahanSepatu;
  String alamatPickup;
  String catatan;
  String status;
  String createdAt;

  OrderModel({
    required this.id,
    required this.layanan,
    required this.merkSepatu,
    required this.bahanSepatu,
    required this.alamatPickup,
    required this.catatan,
    this.status = 'Menunggu Kurir',
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      layanan: map['layanan']?.toString() ?? '-',
      merkSepatu: map['merkSepatu']?.toString() ?? '-',
      bahanSepatu: map['bahanSepatu']?.toString() ?? 'Belum diisi',
      alamatPickup: map['alamatPickup']?.toString() ?? 'Belum diisi',
      catatan: map['catatan']?.toString() ?? '-',
      status: map['status']?.toString() ?? 'Menunggu Kurir',
      createdAt: map['createdAt']?.toString() ?? '-',
    );
  }
}

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _pesananList = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get pesananList => _pesananList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalPesanan => _pesananList.length;

  int get pesananSelesai {
    return _pesananList.where((order) => order.status == 'Selesai').length;
  }

  int get pesananAktif {
    return _pesananList.where((order) => order.status != 'Selesai').length;
  }

  OrderProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _setLoading(true);

    final response = await ApiService.getOrders();

    if (response['success'] == true) {
      final List data = response['data'] ?? [];

      _pesananList = data
          .map((item) => OrderModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      _errorMessage = null;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal mengambil data';
    }

    _setLoading(false);
  }

  Future<bool> tambahPesanan({
    required String layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
  }) async {
    _setLoading(true);

    final response = await ApiService.addOrder(
      layanan: layanan,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
    );

    if (response['success'] == true) {
      await fetchOrders();
      _setLoading(false);
      return true;
    }

    _errorMessage = response['message']?.toString() ?? 'Gagal membuat pesanan';
    _setLoading(false);
    return false;
  }

  Future<bool> updatePesanan({
    required String id,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
  }) async {
    _setLoading(true);

    final response = await ApiService.updateOrder(
      id: id,
      merkSepatu: merkSepatu,
      bahanSepatu: bahanSepatu,
      alamatPickup: alamatPickup,
      catatan: catatan,
    );

    if (response['success'] == true) {
      await fetchOrders();
      _setLoading(false);
      return true;
    }

    _errorMessage = response['message']?.toString() ?? 'Gagal update pesanan';
    _setLoading(false);
    return false;
  }

  Future<bool> updateStatus(String id, String statusBaru) async {
    _setLoading(true);

    final response = await ApiService.updateStatus(
      id: id,
      status: statusBaru,
    );

    if (response['success'] == true) {
      await fetchOrders();
      _setLoading(false);
      return true;
    }

    _errorMessage = response['message']?.toString() ?? 'Gagal update status';
    _setLoading(false);
    return false;
  }

  Future<bool> hapusPesanan(String id) async {
    _setLoading(true);

    final response = await ApiService.deleteOrder(id: id);

    if (response['success'] == true) {
      _pesananList.removeWhere((order) => order.id == id);
      _errorMessage = null;
      _setLoading(false);
      return true;
    }

    _errorMessage = response['message']?.toString() ?? 'Gagal hapus pesanan';
    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}