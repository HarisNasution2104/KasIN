import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../categories_services_page/categories_services_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // For picking images

class AddBarangPage extends StatefulWidget {
  const AddBarangPage({super.key});

  @override
  _AddBarangPageState createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _priceBuy = 0.0;
  double _priceSell = 0.0;
  int _quantity = 0;
  String _category = '';
  String _code = '';
  File? _image;
  List<String> _categories = [];
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
    setState(() {});

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Kategori/get_kategori.php?'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['kategori'] != null &&
            responseData['kategori'] is List) {
          setState(() {
            _categories = (responseData['kategori'] as List)
                .map((item) => item['nama'] as String)
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
    } finally {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Generate unique code if not provided
      if (_code.isEmpty) {
        _code = await _generateUniqueCode();
        if (_code.isEmpty) {
          return; // If code generation failed, exit the function
        }
      }

      const url = 'https://seputar-it.eu.org/Barang/add_barang.php';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'shop_id': _shopId,
          'name': _name,
          'description': _description,
          'price_buy': _priceBuy,
          'price_sell': _priceSell,
          'quantity': _quantity,
          'category': _category,
          'code': _code,
          // Handle image upload if needed
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        Navigator.of(context).pop();
      } else {
        _showError(data['message'] ?? 'Gagal menambahkan barang.');
      }
    }
  }

  Future<String> _generateUniqueCode() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Barang/generate_code.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] != null) {
          return responseData['code'] as String;
        } else {
          _showError('Gagal menghasilkan kode unik.');
          return ''; // Return an empty string or handle as needed
        }
      } else {
        _showError('Gagal menghasilkan kode unik.');
        return ''; // Return an empty string or handle as needed
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
      return ''; // Return an empty string or handle as needed
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
          'Tambah Barang',
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
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang tidak boleh kosong.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              // Category
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category.isNotEmpty ? _category : null,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
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
              // Stock and Code
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok tidak boleh kosong.';
                        }
                        return null;
                      },
                      onSaved: (value) => _quantity = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Kode',
                        suffixIcon: IconButton(
                          icon: const Icon(FontAwesomeIcons.barcode),
                          onPressed: () {
                            // Handle barcode scanning
                          },
                        ),
                      ),
                      onSaved: (value) => _code = value!,
                    ),
                  ),
                ],
              ),
              // Purchase and Selling Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Harga Beli'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga beli tidak boleh kosong.';
                        }
                        return null;
                      },
                      onSaved: (value) => _priceBuy = double.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Harga Jual'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga jual tidak boleh kosong.';
                        }
                        return null;
                      },
                      onSaved: (value) => _priceSell = double.parse(value!),
                    ),
                  ),
                ],
              ),
              // Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              // Save button
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
