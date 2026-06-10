import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PENTING:
  // Kalau pakai HP fisik, isi dengan IP laptop dari ipconfig.
  // Contoh: http://192.168.1.8/sneakimy_care_api
  static const String baseUrl = "http://192.168.10.11/sneakimy_care_api";

  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/orders/get_orders.php"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return _error("Gagal konek ke API get orders: $e");
    }
  }

  static Future<Map<String, dynamic>> addOrder({
    required String layanan,
    required String merkSepatu,
    required String bahanSepatu,
    required String alamatPickup,
    required String catatan,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/orders/add_order.php"),
            headers: headers,
            body: jsonEncode({
              "layanan": layanan,
              "merkSepatu": merkSepatu,
              "bahanSepatu": bahanSepatu,
              "alamatPickup": alamatPickup,
              "catatan": catatan,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return _error("Gagal konek ke API add order: $e");
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
            Uri.parse("$baseUrl/orders/update_order.php"),
            headers: headers,
            body: jsonEncode({
              "id": id,
              "merkSepatu": merkSepatu,
              "bahanSepatu": bahanSepatu,
              "alamatPickup": alamatPickup,
              "catatan": catatan,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return _error("Gagal konek ke API update order: $e");
    }
  }

  static Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/orders/update_status.php"),
            headers: headers,
            body: jsonEncode({
              "id": id,
              "status": status,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return _error("Gagal konek ke API update status: $e");
    }
  }

  static Future<Map<String, dynamic>> deleteOrder({
    required String id,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/orders/delete_order.php"),
            headers: headers,
            body: jsonEncode({
              "id": id,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      return _error("Gagal konek ke API delete order: $e");
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        "success": false,
        "message": "Response API bukan format JSON Map",
        "data": decoded,
      };
    } catch (e) {
      return {
        "success": false,
        "message":
            "Response API tidak bisa dibaca. Status: ${response.statusCode}",
        "data": response.body,
      };
    }
  }

  static Map<String, dynamic> _error(String message) {
    return {
      "success": false,
      "message": message,
      "data": null,
    };
  }
}