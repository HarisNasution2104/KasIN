import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'add_staff_page.dart';
import 'edit_staff_page.dart'; // Import EditStaffPage

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<Map<String, dynamic>> _staffs = [];
  List<Map<String, dynamic>> _filteredStaffs = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _loadShopId();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';

    if (_shopId.isNotEmpty) {
      await _loadStaffs();
    }
  }

  Future<void> _loadStaffs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://seputar-it.eu.org/staff/get_staff.php'), // Ganti dengan URL API yang sesuai
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      print('Response Status Code: ${response.statusCode}'); // Debugging
      print('Response Body: ${response.body}'); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic> parsedStaffs = data['staffs'];
          setState(() {
            _staffs = List<Map<String, dynamic>>.from(parsedStaffs);
            _filteredStaffs = List.from(_staffs);
            _isLoading = false;
          });
        } else {
          _handleError('Gagal memuat data karyawan');
        }
      } else {
        _handleError('Gagal memuat data karyawan');
      }
    } catch (e) {
      _handleError('Terjadi kesalahan: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStaffs = _staffs.where((staff) {
        final name = staff['username'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _navigateToAddStaffPage() async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStaffPage(),
      ),
    );

    if (shouldReload == true) {
      await _loadStaffs();
    }
  }

Future<void> _navigateToEditStaffPage(Map<String, dynamic> staff) async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStaffPage(staff: staff),
      ),
    );

    if (shouldReload == true) {
      await _loadStaffs();
    }
  }

  Widget _buildStaffListView() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (_filteredStaffs.isEmpty
            ? const Center(child: Text('Tidak ada karyawan ditemukan.'))
            : ListView.builder(
                itemCount: _filteredStaffs.length,
                itemBuilder: (context, index) {
                  final staff = _filteredStaffs[index];

                  print('Staff data: $staff'); // Debugging

                  final username =
                      staff['username'] ?? 'Username Tidak Dikenal';
                  final email = staff['email'] ?? 'Email Tidak Dikenal';
                  final level = staff['level'] ??
                      'Level Tidak Dikenal'; // Menambahkan level

                  return GestureDetector(
                    onTap: () => _navigateToEditStaffPage(staff), // Navigasi ke EditStaffPage
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 150, 150, 150),
                              width: 1.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  level, // Menampilkan level di sebelah email
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              email,
                              style:
                                  const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karyawan',
            style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.orange.shade900,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Cari berdasarkan username',
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (value) => _onSearchChanged(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: _navigateToAddStaffPage,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.add, color: Colors.orange.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildStaffListView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
