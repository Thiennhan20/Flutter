import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChangeInformationUserScreen extends StatefulWidget {
  final dynamic user;
  final String token;

  const ChangeInformationUserScreen({Key? key, required this.user, required this.token}) : super(key: key);

  @override
  _ChangeInformationUserScreenState createState() => _ChangeInformationUserScreenState();
}

class _ChangeInformationUserScreenState extends State<ChangeInformationUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;

  File? _selectedImage;
  LatLng? _currentPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user['username']);
    _ageController = TextEditingController(text: widget.user['age']?.toString() ?? '');
    _locationController = TextEditingController(text: widget.user['location']);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối.')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _locationController.text = "${position.latitude}, ${position.longitude}";
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  /// Chọn hình ảnh bằng file_picker
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  /// Cập nhật thông tin người dùng
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.147.18.78:8000/api/update-profile/');
      final request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = 'Bearer ${widget.token}'
        ..fields['username'] = _usernameController.text
        ..fields['age'] = _ageController.text
        ..fields['location'] = _locationController.text;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_picture', _selectedImage!.path),
        );
      }

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseData = jsonDecode(responseBody);
          print('User updated successfully: $responseData');
          Navigator.pop(context, responseData);
        } else {
          print('Failed to update user: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update user information.')),
          );
        }
      } catch (error) {
        print('Error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar với khả năng chỉnh sửa
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (widget.user['profile_picture'] != null
                            ? NetworkImage(widget.user['profile_picture'])
                            : null) as ImageProvider?,
                        child: _selectedImage == null && widget.user['profile_picture'] == null
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Map Display
                _currentPosition == null
                    ? Center(
                  child: ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Lấy Vị Trí Hiện Tại'),
                  ),
                )
                    : SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (controller) => _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("current_location"),
                        position: _currentPosition!,
                        infoWindow: const InfoWindow(
                          title: "Vị trí của bạn",
                        ),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your age';
                    if (int.tryParse(value) == null) return 'Age must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
