import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.147.18.78:8000/api'; // Thay đổi thành IP của bạn

  // Lấy danh sách người dùng
  Future<Map<String, dynamic>> fetchUsers(String token, {String? nextPageUrl}) async {
    final url = nextPageUrl ?? '$baseUrl/users/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Trả về dữ liệu phân trang
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

  Future<List<dynamic>> fetchMatches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/matches/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Trả về danh sách match
    } else {
      throw Exception('Failed to load matches: ${response.statusCode}');
    }
  }
}
