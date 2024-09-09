import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class CategoriesServicesPage extends StatefulWidget {
  const CategoriesServicesPage({super.key});

  @override
  _CategoriesServicesPageState createState() => _CategoriesServicesPageState();
}

class _CategoriesServicesPageState extends State<CategoriesServicesPage> {
  final TextEditingController _categoryController = TextEditingController();
  List<String> _categories = [];
  bool _isLoading = true;
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';
    if (_shopId.isNotEmpty) {
      await _fetchCategories();
    }
  }

  Future<void> _fetchCategories() async {
    if (_shopId.isEmpty) return; // Jika shop_id belum dimuat, keluar

    const url = 'https://seputar-it.eu.org/Kategori/get_kategori.php'; // Ganti dengan URL API get kategori Anda
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'shop_id': _shopId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _categories = List<String>.from(data['kategori'].map((item) => item['nama']));
          _isLoading = false;
        });
      } else {
        // Tangani kesalahan jika diperlukan
        setState(() => _isLoading = false);
      }
    } else {
      // Tangani kesalahan jika diperlukan
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final category = _categoryController.text.trim();
    if (category.isNotEmpty && _shopId.isNotEmpty) {
      const url = 'https://seputar-it.eu.org/Kategori/add_kategori.php'; // Ganti dengan URL API add kategori Anda
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId, 'nama': category}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _categories.add(category);
            _categoryController.clear();
          });
        } else {
          // Tangani kesalahan jika diperlukan
        }
      } else {
        // Tangani kesalahan jika diperlukan
      }
    }
  }

  Future<void> _deleteCategory(String category) async {
    if (_shopId.isNotEmpty) {
      const url = 'https://seputar-it.eu.org/Kategori/delete_kategori.php'; // Ganti dengan URL API delete kategori Anda
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId, 'nama': category}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _categories.remove(category);
          });
        } else {
          // Tangani kesalahan jika diperlukan
        }
      } else {
        // Tangani kesalahan jika diperlukan
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk',
            style: TextStyle(color: Colors.white, fontSize: 23)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            labelText: 'Masukan Kategori',
                            labelStyle:
                                TextStyle(color: Colors.orange.shade900),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.orange.shade900), // Warna garis border
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.orange.shade900), // Warna garis border saat tidak fokus
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.orange.shade900,
                                  width: 2.0), // Warna garis border saat fokus
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true, // Aktifkan latar belakang berwarna
                            fillColor: Colors.white70,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.add,
                          color: Colors.orange.shade900,
                        ),
                        onPressed: _addCategory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '*Masukan Kategori Baru Di Kolom Dan Klik Tambah Untuk Menambahkan Kategori Baru',
                    style: TextStyle(color: Color.fromARGB(157, 66, 66, 66)),
                  ),
                ],
              ),
            ),
            // Daftar kategori
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              // Kolom Kanan: Stok dan Harga
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.trashCan,
                                      size: 20,
                                    ),
                                    color: Colors.orange.shade900,
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(category);
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "$category"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(category);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
