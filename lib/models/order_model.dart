class OrderModel {
  final String id;
  final String layanan;
  final String merkSepatu;
  final String bahanSepatu;
  final String alamatPickup;
  final String catatan;
  final String status;
  final String customerName;
  final String customerEmail;
  final int estimasiBiaya;
  final String createdAt;
  final String updatedAt;

  const OrderModel({
    required this.id,
    required this.layanan,
    required this.merkSepatu,
    required this.bahanSepatu,
    required this.alamatPickup,
    required this.catatan,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.estimasiBiaya,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canEdit => status.toLowerCase() == 'menunggu kurir';
  bool get canCancel => status.toLowerCase() == 'menunggu kurir';
  bool get isFinished => status.toLowerCase() == 'selesai';

  static const List<String> statusFlow = [
    'Menunggu Kurir',
    'Dijemput Kurir',
    'Cleaning',
    'Drying',
    'Packing',
    'Selesai',
  ];

  int get progressIndex {
    final index = statusFlow.indexWhere(
      (item) => item.toLowerCase() == status.toLowerCase(),
    );
    return index == -1 ? 0 : index;
  }

  double get progressValue {
    final max = statusFlow.length - 1;
    if (max <= 0) return 0;
    return progressIndex / max;
  }

  String get formattedPrice {
    final text = estimasiBiaya.toString();
    final buffer = StringBuffer();
    int counter = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write('.');
        counter = 0;
      }
    }

    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  OrderModel copyWith({
    String? id,
    String? layanan,
    String? merkSepatu,
    String? bahanSepatu,
    String? alamatPickup,
    String? catatan,
    String? status,
    String? customerName,
    String? customerEmail,
    int? estimasiBiaya,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      layanan: layanan ?? this.layanan,
      merkSepatu: merkSepatu ?? this.merkSepatu,
      bahanSepatu: bahanSepatu ?? this.bahanSepatu,
      alamatPickup: alamatPickup ?? this.alamatPickup,
      catatan: catatan ?? this.catatan,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      estimasiBiaya: estimasiBiaya ?? this.estimasiBiaya,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _readString(json, ['id', 'order_id']),
      layanan: _readString(json, ['layanan', 'service', 'service_name']),
      merkSepatu: _readString(json, ['merk_sepatu', 'merkSepatu', 'brand']),
      bahanSepatu: _readString(json, ['bahan_sepatu', 'bahanSepatu', 'material']),
      alamatPickup: _readString(json, ['alamat_pickup', 'alamatPickup', 'address']),
      catatan: _readString(json, ['catatan', 'note', 'notes']),
      status: _readString(json, ['status'], defaultValue: 'Menunggu Kurir'),
      customerName: _readString(json, ['customer_name', 'customerName', 'nama_customer']),
      customerEmail: _readString(json, ['customer_email', 'customerEmail', 'email_customer']),
      estimasiBiaya: _readInt(json, ['estimasi_biaya', 'estimasiBiaya', 'price'], defaultValue: 0),
      createdAt: _readString(json, ['created_at', 'createdAt']),
      updatedAt: _readString(json, ['updated_at', 'updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layanan': layanan,
      'merkSepatu': merkSepatu,
      'bahanSepatu': bahanSepatu,
      'alamatPickup': alamatPickup,
      'catatan': catatan,
      'status': status,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'estimasiBiaya': estimasiBiaya,
    };
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String defaultValue = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) return value.toString();
    }
    return defaultValue;
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int defaultValue = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? defaultValue;
    }
    return defaultValue;
  }
}
