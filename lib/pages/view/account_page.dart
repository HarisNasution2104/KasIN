import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:http/http.dart' as http; // Import http package

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _username = '';
  String _email = '';
  String _level = '';
  String _profileImage = ''; // Gambar default

  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _email = prefs.getString('email') ?? 'user@example.com';
      _level = prefs.getString('user_level') ?? 'example';
      _profileImage = prefs.getString('profile_image') ?? '';
    });
  }

  // Method to handle user logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all preferences
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  }

  // Method to handle changing profile image
  Future<void> _showChangeProfileImageDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Image'),
          content: const Text('Select an image from your gallery or take a new one.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Pick from Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text('Take a Photo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Method to pick an image
  Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await _picker.pickImage(source: source);

  if (pickedFile != null) {
    setState(() {
      _profileImage = pickedFile.path;
    });

    await _uploadImage(pickedFile.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', _profileImage);
  }
}

  // Method to upload image to server
Future<void> _uploadImage(String filePath) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id') ?? '';
  final username = prefs.getString('username') ?? '';

  final fileExtension = filePath.split('.').last;
  final newFileName = '$username.$fileExtension'; // Ganti nama file sesuai username

  final uri = Uri.parse('http://seputar-it.eu.org/upload_profile.php');
  final request = http.MultipartRequest('POST', uri)
    ..fields['user_id'] = userId
    ..files.add(await http.MultipartFile.fromPath('image', filePath, filename: newFileName)); // Menyertakan nama file baru

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBody);

    if (jsonResponse['status'] == 'success') {
      print('Image uploaded successfully: ${jsonResponse['image_url']}');
      setState(() {
        _profileImage = jsonResponse['image_url'];
      });
    } else {
      print('Failed to upload image: ${jsonResponse['message']}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Account",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1400),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 90,
                               backgroundImage: _profileImage.isEmpty
                                  ? const AssetImage('assets/images/default_profile.png') as ImageProvider
                                  : NetworkImage(_profileImage), // Menggunakan NetworkImage untuk URL
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  _showChangeProfileImageDialog();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[900],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: Text(
                          _username,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: Text(
                          _email,
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1600),
                        child: Text(
                          _level,
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInUp(
                        duration: const Duration(milliseconds: 1700),
                        child: MaterialButton(
                          onPressed: _logout,
                          height: 50,
                          color: Colors.orange[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
