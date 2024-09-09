import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EditStaffPage extends StatefulWidget {
  final Map<String, dynamic> staff;

  const EditStaffPage({super.key, required this.staff});

  @override
  _EditStaffPageState createState() => _EditStaffPageState();
}

class _EditStaffPageState extends State<EditStaffPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _selectedType = ''; // Default selected type
  final List<String> _types = ['admin', 'staff']; // Dropdown options
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.staff['username']);
    _emailController = TextEditingController(text: widget.staff['email']);
    _passwordController = TextEditingController(); // Leave password empty
    _selectedType = widget.staff['level'] ?? ''; // Set initial type value
  }

  Future<void> _updateStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final type = _selectedType;

    if (username.isEmpty || email.isEmpty) {
      setState(() {
        _errorMessage = 'Username dan email tidak boleh kosong.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Prepare the payload
      Map<String, dynamic> payload = {
        'action': 'update_staff',
        'username': username,
        'email': email,
        'type': type,
      };

      if (password.isNotEmpty) {
        payload['password'] = password;
      }

      final response = await http.post(
        Uri.parse('http://seputar-it.eu.org/staff/update_staff.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Pembaharuan data karyawan gagal.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final id = widget.staff['id'];

    try {
      final response = await http.post(
        Uri.parse('http://seputar-it.eu.org/staff/delete_staff.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'id': id}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Penghapusan data karyawan gagal.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Anda yakin ingin menghapus karyawan ini?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Hapus"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStaff(); // Call delete staff method
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Karyawan'),
        backgroundColor: Colors.orange.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              _buildTextField(_usernameController, 'Username', enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email', enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_passwordController, 'Password', enabled: true),
              const SizedBox(height: 10),
              _buildDropdown(), // Dropdown for type
              const SizedBox(height: 10),
              MaterialButton(
                onPressed: _updateStaff,
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButton<String>(
        padding: const EdgeInsets.all(4.0),
        value: _selectedType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedType = newValue!;
          });
        },
        items: _types.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: Container(),
        isExpanded: true,
        hint: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Select Type'),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {required bool enabled}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.all(8),
          border: InputBorder.none,
        ),
        enabled: enabled,
      ),
    );
  }
}
