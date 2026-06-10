import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI IP INI kalau IP laptop berubah.
  // Laptop/Laragon: http://localhost/sneakimy_care_api
  // HP fisik:       http://IP-LAPTOP/sneakimy_care_api
  static const String baseUrl = 'http://192.168.10.11/sneakimy_care_api';

  static const Duration timeoutDuration = Duration(seconds: 15);

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<Map<String, dynamic>> getOrders({
    String? customerEmail,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/get_orders.php').replace(
        queryParameters: customerEmail == null || customerEmail.trim().isEmpty
            ? null
            : {'customer_email': customerEmail.trim()},
      );

      final response = await http.get(uri, headers: headers).timeout(timeoutDuration);
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
    required String catatan,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/add_order.php'),
            headers: headers,
            body: jsonEncode({
              'layanan': layanan,
              'merkSepatu': merkSepatu,
              'bahanSepatu': bahanSepatu,
              'alamatPickup': alamatPickup,
              'catatan': catatan,
              'customerName': customerName,
              'customerEmail': customerEmail,
            }),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal membuat pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> updateOrder({
    required String id,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/update_order.php'),
            headers: headers,
            body: jsonEncode({
              'id': id,
              'merkSepatu': merkSepatu,
              'bahanSepatu': bahanSepatu,
              'alamatPickup': alamatPickup,
              'catatan': catatan,
            }),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengubah pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/update_status.php'),
            headers: headers,
            body: jsonEncode({
              'id': id,
              'status': status,
            }),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal memperbarui status pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteOrder({
    required String id,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/orders/delete_order.php'),
            headers: headers,
            body: jsonEncode({'id': id}),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal menghapus pesanan: $e');
    }
  }

  static Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/services/get_services.php'), headers: headers)
          .timeout(timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return _error('Gagal mengambil layanan: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return decoded;
        }
        return {
          'success': false,
          'message': decoded['message']?.toString() ?? 'Request gagal.',
          'data': decoded['data'],
        };
      }
      return _error('Format response API tidak valid.');
    } catch (_) {
      return _error(
        'Response API bukan JSON. Status ${response.statusCode}: ${response.body}',
      );
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
