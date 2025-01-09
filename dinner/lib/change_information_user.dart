import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

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
  late TextEditingController _bioController;
  late TextEditingController _genderController;


  File? _selectedImage;
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  List<dynamic> _filteredUsers = []; // Danh sách người dùng trong bán kính
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user['username']);
    _ageController = TextEditingController(text: widget.user['age']?.toString() ?? '');
    _locationController = TextEditingController(text: widget.user['location']);
    _bioController = TextEditingController(text: widget.user['bio'] ?? '');
    _genderController = TextEditingController(text: widget.user['gender'] ?? '');

    // Lắng nghe vị trí khi khởi chạy ứng dụng
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _genderController.dispose();

    // Hủy lắng nghe vị trí
    _positionStreamSubscription?.cancel();

    super.dispose();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Cập nhật sau mỗi 10m di chuyển
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Cập nhật địa chỉ
      _getAddressFromLatLng(_currentPosition!);

      // Cập nhật bản đồ
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    });
  }

  /// Chuyển đổi tọa độ thành địa chỉ
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.subAdministrativeArea}, ${place.administrativeArea}";
        setState(() {
          _locationController.text = address;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chuyển tọa độ thành địa chỉ.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy địa chỉ. Vui lòng thử lại.')),
      );
      print(e);
    }
  }

  /// Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng bật dịch vụ vị trí.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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
    });

    await _getAddressFromLatLng(_currentPosition!);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  /// Tính khoảng cách giữa hai điểm
  double _calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // Trả về khoảng cách tính bằng km
  }

  /// Lọc người dùng trong bán kính
  void _filterUsersByRadius(List<dynamic> users, LatLng currentPosition, double radiusInKm) {
    setState(() {
      _filteredUsers = users.where((user) {
        LatLng userPosition = LatLng(
          double.parse(user['latitude']),
          double.parse(user['longitude']),
        );
        double distance = _calculateDistance(currentPosition, userPosition);
        return distance <= radiusInKm;
      }).toList();
    });
  }

  /// Tạo marker cho Google Map
  Set<Marker> _createMarkers(List<dynamic> users, LatLng currentPosition, double radiusInKm) {
    return users.map((user) {
      LatLng userPosition = LatLng(
        double.parse(user['latitude']),
        double.parse(user['longitude']),
      );
      double distance = _calculateDistance(currentPosition, userPosition);
      if (distance <= radiusInKm) {
        return Marker(
          markerId: MarkerId(user['id'].toString()),
          position: userPosition,
          infoWindow: InfoWindow(
            title: user['username'],
            snippet: '${distance.toStringAsFixed(2)} km away',
          ),
        );
      } else {
        return null;
      }
    }).where((marker) => marker != null).cast<Marker>().toSet();
  }

  /// Chọn hình ảnh
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
        ..fields['location'] = _locationController.text
        ..fields['bio'] = _bioController.text
        ..fields['gender'] = _genderController.text;


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
        actions: [
          // Thêm nút PopupMenuButton ở góc trên bên phải
          PopupMenuButton<double>(
            icon: Icon(Icons.filter_alt, color: Colors.red),
            onSelected: (radiusInKm) {
              if (_currentPosition != null) {
                // Gọi hàm lọc user trong bán kính
                _filterUsersByRadius(_filteredUsers, _currentPosition!, radiusInKm);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng lấy vị trí hiện tại trước khi lọc.')),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 5.0,
                child: Text('5 km'),
              ),
              PopupMenuItem(
                value: 10.0,
                child: Text('10 km'),
              ),
              PopupMenuItem(
                value: 20.0,
                child: Text('20 km'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    markers: _createMarkers(_filteredUsers, _currentPosition!, 10),
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
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your bio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your gender' : null,
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
