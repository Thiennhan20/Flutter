import 'package:flutter/material.dart';

class MatchScreen extends StatelessWidget {
  final String yourImage;
  final String theirImage;
  final String theirName;

  const MatchScreen({
    super.key,
    required this.yourImage,
    required this.theirImage,
    required this.theirName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tiêu đề "It's a match!"
          Text(
            "It's a Match!",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Hình ảnh hai người dùng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Hình ảnh của bạn
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(yourImage),
              ),
              // Hình ảnh của người kia
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(theirImage),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Thông báo ghép đôi
          Text(
            "Bạn đã tương hợp với $theirName",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Input và nút gửi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Nói gì đó hay ho đi",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Quay lại màn hình chính
                  },
                  child: Text(
                    "Gửi",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
