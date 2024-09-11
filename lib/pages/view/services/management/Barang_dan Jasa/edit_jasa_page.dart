import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../categories_services_page/categories_services_page.dart';

class EditJasaPage extends StatefulWidget {
  final Map<String, dynamic> jasa;

  const EditJasaPage({super.key, required this.jasa});

  @override
  _EditJasaPageState createState() => _EditJasaPageState();
}

class _EditJasaPageState extends State<EditJasaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _warrantyController;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.jasa['name'] ?? '');
    _priceController = TextEditingController(
        text: widget.jasa['price_sell']?.toString() ?? '');
    _warrantyController =
        TextEditingController(text: widget.jasa['warranty'] ?? '');
    _selectedCategoryId = widget.jasa['category_id']?.toString();
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

            // Ensure the current category is in the list or set to the first available
            if (_selectedCategoryId != null &&
                _categories.any((cat) => cat['id'] == _selectedCategoryId)) {
              // Do nothing, _selectedCategoryId is valid
            } else if (_categories.isNotEmpty) {
              _selectedCategoryId = _categories.first['id'];
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

  Future<void> _updateJasa() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://seputar-it.eu.org/Jasa/update_jasa.php'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'id': widget.jasa['id'],
            'name': _nameController.text,
            'price_sell': double.tryParse(_priceController.text) ?? 0.0,
            'category_id': _selectedCategoryId,
            'warranty': _warrantyController.text,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'success') {
            Navigator.of(context).pop(true);
          } else {
            _showError(data['message'] ?? 'Gagal memperbarui jasa.');
          }
        } else {
          _showError('Respons dari server tidak dalam format JSON.');
        }
      } catch (e) {
        _showError('Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _confirmDeleteJasa() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus jasa ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteJasa();
    }
  }

  Future<void> _deleteJasa() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Jasa/delete_jasa.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': widget.jasa['id'],
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(true);
        } else {
          _showError(data['message'] ?? 'Gagal menghapus jasa.');
        }
      } else {
        _showError('Gagal menghapus jasa, coba lagi nanti.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Jasa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDeleteJasa,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Name
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
              // Category
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Kategori harus dipilih.';
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
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga tidak valid.';
                  }
                  return null;
                },
              ),
              // Warranty
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(labelText: 'Garansi'),
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _updateJasa,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
