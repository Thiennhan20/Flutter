import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.147.18.78:8000/api'; // Thay đổi thành IP của bạn

  // Lấy danh sách người dùng
  Future<List<dynamic>> fetchUsers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Authorization': 'Bearer $token', // Sử dụng "Bearer" thay vì "Token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Trả về danh sách người dùng
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }
}
