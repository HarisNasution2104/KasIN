import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../categories_services_page/categories_services_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddJasaPage extends StatefulWidget {
  const AddJasaPage({super.key});

  @override
  _AddJasaPageState createState() => _AddJasaPageState();
}

class _AddJasaPageState extends State<AddJasaPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  String _shopId = '';
  final List<String> _categories = [];
  String _category = '';

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getString('shop_id') ?? '';
    });
  }

  Future<void> _addJasa() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _warrantyController.text.isEmpty ||
        _shopId.isEmpty) {
      _handleError('Semua field harus diisi.');
      return;
    }

    final response = await http.post(
      Uri.parse('https://seputar-it.eu.org/Jasa/add_jasa.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'price': _priceController.text,
        'category': _categoryController.text,
        'warranty': _warrantyController.text,
        'shop_id': _shopId,
      }),
    );

    // Debugging: Print raw response body
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final uniqueCode = data['unique_code'];
          _showSuccess('Jasa berhasil ditambahkan. Kode Unik: $uniqueCode');
        } else {
          _handleError(data['message'] ?? 'Gagal menambahkan jasa.');
        }
      } catch (e) {
        _handleError('Format data tidak sesuai. ${e.toString()}');
      }
    } else {
      _handleError('Gagal menambahkan jasa.');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
    // Optionally pop the page after showing the success message
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
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
        title: const Text('Tambah Jasa',
            style: TextStyle(color: Colors.white, fontSize: 25)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Nama Jasa'),
              const SizedBox(height: 10),
              _buildTextField(_priceController, 'Harga'),
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
              const SizedBox(height: 10),
              _buildTextField(_categoryController, 'Kategori Jasa'),
              const SizedBox(height: 10),
              _buildTextField(_warrantyController, 'Garansi'),
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: _addJasa,
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    "Tambah Jasa",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
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
      ),
    );
  }
}
