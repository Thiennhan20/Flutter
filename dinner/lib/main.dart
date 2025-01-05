import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home.dart';

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
      home: const SplashScreen(), // Thay đổi để hiển thị SplashScreen trước
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
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

    // Kiểm tra nếu token tồn tại
    if (accessToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserListScreen(token: accessToken)), // Truyền accessToken
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Chuyển đến màn hình đăng nhập
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Hiển thị vòng xoay khi đang kiểm tra trạng thái
      ),
    );
  }
}
