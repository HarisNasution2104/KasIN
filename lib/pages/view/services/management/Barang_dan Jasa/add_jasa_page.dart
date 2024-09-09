import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../categories_services_page/categories_services_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddJasaPage extends StatefulWidget {
  const AddJasaPage({super.key});

  @override
  _AddJasaPageState createState() => _AddJasaPageState();
}

class _AddJasaPageState extends State<AddJasaPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String _warranty = '';
  String _categoryId = '';
  List<Map<String, String>> _categories = [];
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
      await _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Kategori/get_kategori.php?'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['kategori'] != null && responseData['kategori'] is List) {
          setState(() {
            _categories = (responseData['kategori'] as List)
                .map((item) => {
                      'id': item['id']?.toString() ?? '', // Pastikan ID adalah String
                      'name': item['nama'] as String
                    })
                .toList();
          });
        } else {
          _showError('Format data kategori tidak sesuai.');
        }
      } else {
        _showError('Gagal memuat kategori.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      const url = 'https://seputar-it.eu.org/Jasa/add_jasa.php';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'shop_id': _shopId,
          'name': _name,
          'price': _price,
          'category_id': _categoryId,
          'warranty': _warranty,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        Navigator.of(context).pop();
      } else {
        _showError(data['message'] ?? 'Gagal menambahkan jasa.');
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesServicesPage()),
    ).then((_) {
      _loadCategories(); // Refresh categories after navigating back
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Jasa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              // Nama Jasa
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Jasa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama jasa tidak boleh kosong.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              // Kategori
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoryId.isNotEmpty ? _categoryId : null,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name'] ?? ''), // Pastikan name tidak null
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoryId = value ?? ''; // Berikan nilai default jika null
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _navigateToCategories,
                  ),
                ],
              ),
              // Harga
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong.';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              // Garansi
              TextFormField(
                decoration: const InputDecoration(labelText: 'Garansi'),
                onSaved: (value) => _warranty = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Adjust button size
                    backgroundColor: Colors.orange.shade900,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0))),
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
