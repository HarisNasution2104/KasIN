import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'shop_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class TransactionsDetailPage extends StatefulWidget {
  const TransactionsDetailPage({super.key});

  @override
  State<TransactionsDetailPage> createState() => _TransactionsDetailPageState();
}

class _TransactionsDetailPageState extends State<TransactionsDetailPage> {
  final List<Map<String, dynamic>> barangList = [];
  final List<Map<String, dynamic>> jasaList = [];
  final List<Map<String, dynamic>> categoryList = [];
  int totalBarangDitambahkan = 0;
  int totalJasaDitambahkan = 0;
  List<Map<String, dynamic>> barangDitambahkan = [];
  List<Map<String, dynamic>> jasaDitambahkan = [];
  String _shopId = '';
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';
    if (_shopId.isNotEmpty) {
      await _loadCategories(); // Load categories first
      await _fetchData(); // Then fetch barang and jasa data
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Kategori/get_kategori.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['kategori'] != null &&
            responseData['kategori'] is List) {
          setState(() {
            categoryList.clear();
            categoryList.addAll(
              (responseData['kategori'] as List)
                  .map((item) => {
                        'id': item['id']?.toString() ?? '',
                        'nama': item['nama'] as String
                      })
                  .toList(),
            );
          });
        } else {
          print('Format data kategori tidak sesuai.');
        }
      } else {
        print('Gagal memuat kategori.');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Transaksi/get-barangjasa.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> barangJson =
            (data['barang'] as List<dynamic>?) ?? [];
        final List<dynamic> jasaJson = (data['jasa'] as List<dynamic>?) ?? [];

        setState(() {
          barangList.clear();
          barangList.addAll(
              barangJson.map((item) => item as Map<String, dynamic>).toList());
          jasaList.clear();
          jasaList.addAll(
              jasaJson.map((item) => item as Map<String, dynamic>).toList());
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<Map<String, dynamic>> get filteredBarangList {
    final selectedCategoryId = _selectedCategory == 'All'
        ? null
        : categoryList
            .firstWhere((cat) => cat['nama'] == _selectedCategory,
                orElse: () => {'id': null})['id']
            ?.toString();

    return barangList
        .where((item) =>
            (selectedCategoryId == null ||
                item['category_id']?.toString() == selectedCategoryId) &&
            (item['code'].toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  List<Map<String, dynamic>> get filteredJasaList {
    final selectedCategoryId = _selectedCategory == 'All'
        ? null
        : categoryList
            .firstWhere((cat) => cat['nama'] == _selectedCategory,
                orElse: () => {'id': null})['id']
            ?.toString();

    return jasaList
        .where((item) =>
            (selectedCategoryId == null ||
                item['category_id']?.toString() == selectedCategoryId) &&
            (item['unique_code']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())))
        .toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  Future<void> _scanBarcode() async {
    try {
      final scannedCode = await FlutterBarcodeScanner.scanBarcode(
        '#FF0000', // Color of the scan line
        'Cancel', // Text of the cancel button
        true, // Show the flash icon
        ScanMode.BARCODE, // Scan mode
      );

      if (scannedCode != '-1') {
        setState(() {
          _searchQuery = scannedCode;
        });
      }
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text('Transactions', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.orange.shade700),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchQuery = '';
                      }
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Colors.orange.shade700),
                  onSelected: _onCategorySelected,
                  itemBuilder: (BuildContext context) {
                    return [
                      'All',
                      ...categoryList.map((cat) => cat['nama'] as String)
                    ].map((String category) {
                      return PopupMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.orange.shade700),
                  onPressed: () {
                    // Handle add action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner,
                      color: Colors.orange.shade700),
                  onPressed: () {
                    _scanBarcode();
                  },
                ),
              ],
            ),
            if (_isSearching)
              Container(
                height: 35,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    labelText: 'Cari Barang',
                    labelStyle: TextStyle(color: Colors.orange.shade900),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade900),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange.shade900),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orange.shade900, width: 2.0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white60,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredBarangList.length + filteredJasaList.length,
                itemBuilder: (context, index) {
                  final isBarang = index < filteredBarangList.length;
                  final data = isBarang
                      ? filteredBarangList[index]
                      : filteredJasaList[index - filteredBarangList.length];
                  final hasImage = data['image_path'] != null &&
                      data['image_path'].isNotEmpty;
                  return ListTile(
                    leading: hasImage
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(data['image_path']),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              data['name']?.substring(0, 2).toUpperCase() ??
                                  'AD',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isBarang ? data['name'] : data['name']),
                          ],
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade900,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            isBarang ? '${data['quantity']}' : 'Unlimited',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBarang ? data['code'] : data['unique_code'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isBarang
                                  ? currencyFormat
                                      .format(double.parse(data['price_sell']))
                                  : currencyFormat
                                      .format(double.parse(data['price'])),
                              style:
                                  const TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (isBarang) {
                        _tambahBarangKePesanan(data);
                      } else {
                        _tambahJasaKePesanan(data);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.orange.shade900,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopDetailPage(
                    barangDitambahkan: List.from(barangDitambahkan),
                    jasaDitambahkan: List.from(jasaDitambahkan),
                  ),
                ),
              );
            },
            tooltip: 'Tambah Barang',
            shape: const CircleBorder(),
            child: Icon(FontAwesomeIcons.bagShopping, color: Colors.white),
          ),
          if (totalBarangDitambahkan > 0 || totalJasaDitambahkan > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  (totalBarangDitambahkan + totalJasaDitambahkan).toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _tambahBarangKePesanan(Map<String, dynamic> data) {
    setState(() {
      final existingBarangIndex = barangDitambahkan.indexWhere(
        (b) => b['code'] == data['code'],
      );

      if (existingBarangIndex != -1) {
        final existingBarang = barangDitambahkan[existingBarangIndex];
        final updatedBarang = {
          ...existingBarang,
          'quantity': existingBarang['quantity'] + 1
        };
        barangDitambahkan[existingBarangIndex] = updatedBarang;
      } else {
        barangDitambahkan.add({
          'id': data['id'],
          'shop_id': data['shop_id'],
          'name': data['name'],
          'code': data['code'],
          'quantity': 1,
          'stok': data['quantity'],
          'price_buy': data['price_buy'],
          'price_sell': data['price_sell'],
          'price': data['price'],
          'image_path': data['image_path'],
        });
      }
      totalBarangDitambahkan = barangDitambahkan.fold(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );
    });
  }

  void _tambahJasaKePesanan(Map<String, dynamic> data) {
    setState(() {
      final existingJasaIndex = jasaDitambahkan.indexWhere(
        (j) => j['unique_code'] == data['unique_code'],
      );

      if (existingJasaIndex != -1) {
        final existingJasa = jasaDitambahkan[existingJasaIndex];
        final updatedJasa = {
          ...existingJasa,
          'quantity': existingJasa['quantity'] + 1
        };
        jasaDitambahkan[existingJasaIndex] = updatedJasa;
      } else {
        jasaDitambahkan.add({
          'id': data['id'],
          'shop_id': data['shop_id'],
          'name': data['name'],
          'unique_code': data['unique_code'],
          'quantity': 1,
          'price': data['price'],
        });
      }
      totalJasaDitambahkan = jasaDitambahkan.fold(
        0,
        (sum, item) => sum + (item['quantity'] as int),
      );
    });
  }
}