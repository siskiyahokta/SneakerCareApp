import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderModel {
  String id;
  String layanan;
  String merkSepatu;
  String status;

  OrderModel({required this.id, required this.layanan, required this.merkSepatu, this.status = 'Menunggu Kurir'});

  Map<String, dynamic> toMap() {
    return {'id': id, 'layanan': layanan, 'merkSepatu': merkSepatu, 'status': status};
  }


  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(id: map['id'], layanan: map['layanan'], merkSepatu: map['merkSepatu'], status: map['status']);
  }
}

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _pesananList = [];
  List<OrderModel> get pesananList => _pesananList;

  OrderProvider() {
    _loadData(); 
  }
 
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pesananStringList = _pesananList.map((order) => jsonEncode(order.toMap())).toList();
    await prefs.setStringList('data_pesanan', pesananStringList);
  }

  // [READ] Ambil data dari HP
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? pesananStringList = prefs.getStringList('data_pesanan');
    if (pesananStringList != null) {
      _pesananList = pesananStringList.map((item) => OrderModel.fromMap(jsonDecode(item))).toList();
      notifyListeners(); 
    }
  }

  

  
  void tambahPesanan(String layanan, String merk) {
    final pesananBaru = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Bikin ID unik
      layanan: layanan,
      merkSepatu: merk,
    );
    _pesananList.add(pesananBaru);
    _saveData();       
    notifyListeners(); 
  }

  void updateStatus(String id, String statusBaru) {
    final index = _pesananList.indexWhere((order) => order.id == id);
    if (index != -1) {
      _pesananList[index].status = statusBaru;
      _saveData();
      notifyListeners();
    }
  }

  void hapusPesanan(String id) {
    _pesananList.removeWhere((order) => order.id == id);
    _saveData();
    notifyListeners();
  }
}