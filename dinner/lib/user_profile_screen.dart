import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String username;
  final String profilePicture;
  final Map<String, dynamic> userDetails; // Thông tin chi tiết của user

  const UserProfileScreen({
    Key? key,
    required this.username,
    required this.profilePicture,
    required this.userDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          username,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ảnh đại diện lớn
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(profilePicture),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và tuổi
                  Text(
                    "${userDetails['username'] ?? "Không rõ"} (${userDetails['age'] ?? "Không rõ"} tuổi)",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Giới tính
                  Text(
                    "Giới tính: ${userDetails['gender'] ?? "Không rõ"}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Thông tin Bio
                  const Text(
                    "Bio",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userDetails['bio'] ?? "Chưa có thông tin",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Location
                  const Text(
                    "Location",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userDetails['location'] ?? "Không rõ",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Sở thích
                  const Text(
                    "Sở thích",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    children: (userDetails['hobbies'] ?? [])
                        .map<Widget>((hobby) => Chip(
                      label: Text(hobby),
                      backgroundColor: Colors.grey[800],
                      labelStyle: const TextStyle(color: Colors.white),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
