import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../categories_services_page/categories_services_page.dart';

class EditBarangPage extends StatefulWidget {
  final Map<String, dynamic>? barang;

  const EditBarangPage({super.key, this.barang});

  @override
  _EditBarangPageState createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceBuyController;
  late TextEditingController _priceSellController;
  late TextEditingController _descriptionController;
  String? _selectedCategoryId;
  File? _image;
  List<Map<String, dynamic>> _categories = [];
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.barang?['name'] ?? '');
    _codeController = TextEditingController(text: widget.barang?['code'] ?? '');
    _quantityController = TextEditingController(
        text: widget.barang?['quantity']?.toString() ?? '');
    _priceBuyController = TextEditingController(
        text: widget.barang?['price_buy']?.toString() ?? '');
    _priceSellController = TextEditingController(
        text: widget.barang?['price_sell']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.barang?['description'] ?? '');
    _selectedCategoryId = widget.barang?['category_id']?.toString();
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

  Future<void> _updateBarang() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('https://seputar-it.eu.org/Barang/edit_barang.php'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'barang_id': widget
                .barang?['barang_id'], // Adjust according to API specification
            'shop_id': _shopId,
            'name': _nameController.text,
            'code': _codeController.text,
            'quantity': int.parse(_quantityController.text),
            'price_buy': double.parse(_priceBuyController.text),
            'price_sell': double.parse(_priceSellController.text),
            'description': _descriptionController.text,
            'category_id': _selectedCategoryId,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.headers['content-type']?.contains('application/json') ??
            false) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'success') {
            Navigator.of(context).pop();
          } else {
            _showError(data['message'] ?? 'Gagal memperbarui barang.');
          }
        } else {
          _showError('Respons dari server tidak dalam format JSON.');
        }
      } catch (e) {
        _showError('Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus barang ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () async {
                Navigator.of(context).pop(); // Menutup dialog
                await _deleteBarang(); // Panggil metode penghapusan
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBarang() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Barang/delete_barang.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'shop_id': _shopId,
          'barang_id': widget.barang?['barang_id'],
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        } else {
          _showError(data['message'] ?? 'Gagal menghapus barang.');
        }
      } else {
        _showError('Gagal menghapus barang, coba lagi nanti.');
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
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
        title: const Text(
          'Edit Barang',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDelete, // Ganti pemanggilan ke _confirmDelete
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Image upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  color: Colors.grey[200],
                  height: 100,
                  width: 100,
                  child: _image == null
                      ? const Center(child: Icon(FontAwesomeIcons.image))
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang tidak boleh kosong.';
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
              // Stock and Code
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Kode',
                        suffixIcon: IconButton(
                          icon: const Icon(FontAwesomeIcons.barcode),
                          onPressed: () {
                            // Handle barcode scanning
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kode tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // Purchase and Selling Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceBuyController,
                      decoration:
                          const InputDecoration(labelText: 'Harga Beli'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga beli tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _priceSellController,
                      decoration:
                          const InputDecoration(labelText: 'Harga Jual'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga jual tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: _updateBarang,
                style: ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, 50), // Adjust button size
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
