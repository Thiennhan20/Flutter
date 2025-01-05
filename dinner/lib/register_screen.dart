import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart'; // Import màn hình đăng nhập
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String gender = 'male'; // Giá trị mặc định
  bool isLoading = false;

  late AnimationController _controller;
  final Random _random = Random();

  List<Heart> hearts = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Generate random hearts
    for (int i = 0; i < 20; i++) {
      hearts.add(
        Heart(
          left: _random.nextDouble() * MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
          top: _random.nextDouble() * -100,
          size: _random.nextDouble() * 20 + 10,
          speed: _random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildFallingHearts() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: hearts.map((heart) {
            double newTop = heart.top + heart.speed;
            if (newTop > MediaQuery.of(context).size.height) {
              heart.top = -heart.size;
              heart.left = _random.nextDouble() * MediaQuery.of(context).size.width;
            } else {
              heart.top = newTop;
            }
            return Positioned(
              top: heart.top,
              left: heart.left,
              child: Icon(
                Icons.favorite,
                color: Colors.pink.withOpacity(0.7),
                size: heart.size,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> registerUser() async {
    final url = 'http://10.147.18.78:8000/api/register/'; // Thay URL bằng API của bạn
    setState(() {
      isLoading = true;
    });
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'gender': gender, // Thêm gender vào body
      }),
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Quay về LoginScreen
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade200,
                  Colors.purple.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          buildFallingHearts(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DINNER - Đăng ký',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: 'Tên đăng nhập',
                              prefixIcon: Icon(Icons.person, color: Colors.pink),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) => username = value,
                            validator: (value) => value!.isEmpty
                                ? 'Tên đăng nhập không được để trống'
                                : null,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.pink),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) => email = value,
                            validator: (value) => value!.isEmpty
                                ? 'Email không được để trống'
                                : null,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              hintText: 'Mật khẩu',
                              prefixIcon: Icon(Icons.lock, color: Colors.pink),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                            onChanged: (value) => password = value,
                            validator: (value) => value!.isEmpty
                                ? 'Mật khẩu không được để trống'
                                : null,
                          ),
                          SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: gender,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.person_outline, color: Colors.pink),
                            ),
                            items: [
                              DropdownMenuItem(value: 'male', child: Text('Nam')),
                              DropdownMenuItem(value: 'female', child: Text('Nữ')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                          ),
                          SizedBox(height: 30),
                          isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                registerUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 15),
                            ),
                            child: Text(
                              'Đăng ký',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text(
                              'Đã có tài khoản? Đăng nhập ngay!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Heart {
  double top;
  double left;
  double size;
  double speed;

  Heart({
    required this.top,
    required this.left,
    required this.size,
    required this.speed,
  });
}
