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
  final String shoePhoto;
  final String rejectionReason;
  final int rating;
  final String review;
  final String reviewedAt;
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
    required this.shoePhoto,
    required this.rejectionReason,
    required this.rating,
    required this.review,
    required this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _read(json, ['id']),
      layanan: _read(json, ['layanan', 'service', 'service_name']),
      merkSepatu: _read(json, ['merk_sepatu', 'merkSepatu', 'brand']),
      bahanSepatu: _read(json, ['bahan_sepatu', 'bahanSepatu', 'material']),
      alamatPickup: _read(json, ['alamat_pickup', 'alamatPickup', 'pickup_address']),
      catatan: _read(json, ['catatan', 'notes']),
      status: _read(json, ['status'], fallback: 'Menunggu Kurir'),
      customerName: _read(json, ['customer_name', 'customerName', 'nama_customer']),
      customerEmail: _read(json, ['customer_email', 'customerEmail', 'email_customer']),
      estimasiBiaya: _readInt(json, ['estimasi_biaya', 'estimasiBiaya', 'price']),
      shoePhoto: _read(json, ['shoe_photo', 'shoePhoto', 'foto_sepatu', 'photo']),
      rejectionReason: _read(json, ['rejection_reason', 'rejectionReason', 'alasan_penolakan']),
      rating: _readInt(json, ['rating']),
      review: _read(json, ['review', 'ulasan']),
      reviewedAt: _read(json, ['reviewed_at', 'reviewedAt']),
      createdAt: _read(json, ['created_at', 'createdAt']),
      updatedAt: _read(json, ['updated_at', 'updatedAt']),
    );
  }

  static String _read(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'layanan': layanan,
      'merk_sepatu': merkSepatu,
      'bahan_sepatu': bahanSepatu,
      'alamat_pickup': alamatPickup,
      'catatan': catatan,
      'status': status,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'estimasi_biaya': estimasiBiaya,
      'shoe_photo': shoePhoto,
      'rejection_reason': rejectionReason,
      'rating': rating,
      'review': review,
      'reviewed_at': reviewedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
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
    String? shoePhoto,
    String? rejectionReason,
    int? rating,
    String? review,
    String? reviewedAt,
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
      shoePhoto: shoePhoto ?? this.shoePhoto,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isWaiting => status.toLowerCase() == 'menunggu kurir';
  bool get isFinished => status.toLowerCase() == 'selesai';
  bool get isRejected => status.toLowerCase() == 'ditolak';
  bool get hasRating => rating > 0;
  bool get canEdit => isWaiting;
  bool get canReview => isFinished && !hasRating;

  bool get isInProgress {
    final s = status.toLowerCase();
    return s == 'dijemput kurir' || s == 'cleaning' || s == 'drying' || s == 'packing';
  }
}
