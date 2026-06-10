import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // Ganti IP sesuai IPv4 laptop yang menjalankan Laragon.
  // Laptop browser: http://localhost/sneakimy_care_api
  // HP fisik:     http://IP-LAPTOP/sneakimy_care_api
  static const String baseUrl = 'http://192.168.10.11/sneakimy_care_api';

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String imageUrl(String path) {
    if (path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/get_orders.php'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengambil data pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> addOrder({
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
    try {
      final uri = Uri.parse('$baseUrl/orders/add_order.php');

      if (shoePhotoFile != null) {
        final request = http.MultipartRequest('POST', uri);
        request.fields.addAll({
          'layanan': layanan,
          'merkSepatu': merkSepatu,
          'bahanSepatu': bahanSepatu,
          'alamatPickup': alamatPickup,
          'catatan': catatan,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'estimasiBiaya': estimasiBiaya.toString(),
        });
        request.files.add(
          await http.MultipartFile.fromPath('shoePhoto', shoePhotoFile.path),
        );

        final streamed = await request.send();
        final body = await streamed.stream.bytesToString();
        return _decodeBody(body, streamed.statusCode);
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'layanan': layanan,
          'merkSepatu': merkSepatu,
          'bahanSepatu': bahanSepatu,
          'alamatPickup': alamatPickup,
          'catatan': catatan,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'estimasiBiaya': estimasiBiaya,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal menambahkan pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> updateOrder({
    required String id,
    String? layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    String catatan = '',
    int estimasiBiaya = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/update_order.php'),
        headers: headers,
        body: jsonEncode({
          'id': id,
          if (layanan != null) 'layanan': layanan,
          'merkSepatu': merkSepatu,
          'bahanSepatu': bahanSepatu,
          'alamatPickup': alamatPickup,
          'catatan': catatan,
          'estimasiBiaya': estimasiBiaya,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengubah pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
    String customerEmail = '',
    String rejectionReason = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/update_status.php'),
        headers: headers,
        body: jsonEncode({
          'id': id,
          'status': status,
          'customerEmail': customerEmail,
          'rejectionReason': rejectionReason,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengubah status pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteOrder({required String id}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/delete_order.php'),
        headers: headers,
        body: jsonEncode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal membatalkan pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> submitReview({
    required String id,
    required int rating,
    required String review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/submit_review.php'),
        headers: headers,
        body: jsonEncode({
          'id': id,
          'rating': rating,
          'review': review,
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengirim ulasan: $e');
    }
  }

  static Future<Map<String, dynamic>> saveFcmToken({
    required String customerEmail,
    required String customerName,
    required String fcmToken,
    String role = 'customer',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/save_token.php'),
        headers: headers,
        body: jsonEncode({
          'customerEmail': customerEmail,
          'customerName': customerName,
          'fcmToken': fcmToken,
          'role': role,
          'platform': 'android',
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal menyimpan FCM token: $e');
    }
  }

  static Future<Map<String, dynamic>> getNotifications({
    required String customerEmail,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/get_notifications.php?customerEmail=${Uri.encodeComponent(customerEmail)}'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengambil notifikasi: $e');
    }
  }

  static Future<Map<String, dynamic>> markNotificationRead({
    required String id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/mark_read.php'),
        headers: headers,
        body: jsonEncode({'id': id}),
      );
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengubah status notifikasi: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    return _decodeBody(response.body, response.statusCode);
  }

  static Map<String, dynamic> _decodeBody(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return _error('Format response tidak valid. Status: $statusCode');
    } catch (_) {
      return _error('Response bukan JSON. Status: $statusCode. Body: $body');
    }
  }

  static Map<String, dynamic> _error(String message) {
    return {
      'success': false,
      'message': message,
      'data': null,
    };
  }
}
