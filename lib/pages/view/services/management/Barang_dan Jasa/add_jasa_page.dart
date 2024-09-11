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
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _warrantyController;
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _warrantyController = TextEditingController();
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
        Uri.parse('https://seputar-it.eu.org/Categories/get_kategori.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['categories'] != null &&
            responseData['categories'] is List) {
          setState(() {
            _categories = (responseData['categories'] as List)
                .map((item) => {
                      'id': item['id'].toString(),
                      'name': item['name'],
                    })
                .toList();

            // Set default category if available
            if (_categories.isNotEmpty) {
              _selectedCategory = _categories.first['id'];
            }
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
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final warranty = _warrantyController.text;
      final categoryId = _selectedCategory;

      if (categoryId == null) {
        _showError('Kategori harus dipilih.');
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('https://seputar-it.eu.org/Jasa/add_jasa.php'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'shop_id': _shopId,
            'name': name,
            'price_sell': price,
            'category_id': categoryId,
            'warranty': warranty,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          Navigator.of(context).pop();
        } else {
          _showError(data['message'] ?? 'Gagal menambahkan jasa.');
        }
      } catch (e) {
        _showError('Terjadi kesalahan: $e');
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
              // Nama Jasa
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Jasa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama jasa tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              // Kategori
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
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
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              // Garansi
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(labelText: 'Garansi'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(double.infinity, 50), // Adjust button size
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
