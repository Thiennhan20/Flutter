import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder Clone',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SplashScreen(), // Hiển thị SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Kiểm tra trạng thái đăng nhập
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token'); // Lấy token từ SharedPreferences

    if (accessToken != null) {
      // Gọi hàm cập nhật vị trí
      await _updateUserLocation(accessToken);

      // Chuyển sang màn hình chính
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserListScreen(token: accessToken)),
      );
    } else {
      // Chuyển đến màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  /// Hàm lấy vị trí và lưu lên server
  Future<void> _updateUserLocation(String accessToken) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Dịch vụ vị trí không được bật.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          print('Quyền truy cập vị trí bị từ chối.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _saveLocationToServer(accessToken, position.latitude, position.longitude);
    } catch (e) {
      print('Lỗi khi cập nhật vị trí: $e');
    }
  }

  /// Gửi vị trí đến server
  Future<void> _saveLocationToServer(String accessToken, double latitude, double longitude) async {
    try {
      final url = Uri.parse('http://10.147.18.78:8000/api/update-location/');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        print('Cập nhật vị trí thành công: ${response.body}');
      } else {
        print('Cập nhật vị trí thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi gửi vị trí đến server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
