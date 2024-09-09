import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl untuk format mata uang
import 'edit_barang_page.dart';
import 'add_barang_page.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  List<Map<String, dynamic>> _barangList = [];
  List<Map<String, dynamic>> _filteredBarangList = [];
  bool _isLoading = false;
  String _shopId = '';
  String _searchQuery = '';
  String _sortBy = 'Nama'; // Default sorting option

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';
    if (_shopId.isNotEmpty) {
      await _fetchBarang();
    }
  }

  Future<void> _fetchBarang() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Barang/get_barang.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _barangList = responseData['barang'] != null
              ? List<Map<String, dynamic>>.from(responseData['barang'])
              : [];
          _filteredBarangList = _barangList;
        });
        _applySearchAndSort();
      } else {
        _showError('Gagal memuat data barang.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applySearchAndSort() {
    setState(() {
      _filteredBarangList = _barangList.where((barang) {
        final nameMatch =
            barang['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        return nameMatch;
      }).toList();

      if (_sortBy == 'Nama') {
        _filteredBarangList.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortBy == 'Harga') {
        _filteredBarangList.sort((a, b) =>
            double.parse(a['price']).compareTo(double.parse(b['price'])));
      }
    });
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

  void _navigateToAddPage() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddBarangPage(),
          ),
        )
        .then((_) =>
            _fetchBarang()); // Refresh data setelah kembali dari halaman tambah
  }

  void _navigateToEditPage(dynamic barang) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditBarangPage(barang: barang),
          ),
        )
        .then((_) =>
            _fetchBarang()); // Refresh data setelah kembali dari halaman edit
  }

  Future<void> _deleteBarang(String id) async {
    final response = await http.post(
      Uri.parse('https://seputar-it.eu.org/Barang/delete_barang.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _fetchBarang(); // Refresh data setelah penghapusan
      } else {
        _showError(data['message'] ?? 'Gagal menghapus barang.');
      }
    } else {
      _showError('Gagal menghapus barang.');
    }
  }

  void _showStockNotification() {
    // Implementasi logika notifikasi stok habis atau mendekati habis
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notifikasi Stok'),
          content:
              const Text('Ada barang yang stoknya hampir habis atau sudah habis.'),
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'import_excel':
        // Implementasikan logika untuk import Excel
        break;
      case 'export_excel':
        // Implementasikan logika untuk export Excel
        break;
      case 'settings':
        // Implementasikan logika untuk pengaturan
        break;
      case 'fix_stock':
        // Implementasikan logika untuk memperbaiki data stok
        break;
      case 'print_stock':
        // Implementasikan logika untuk mencetak data stok
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ',decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang',
            style: TextStyle(color: Colors.white, fontSize: 23)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'import_excel', child: Text('Import Excel')),
              const PopupMenuItem(value: 'export_excel', child: Text('Export Excel')),
              const PopupMenuItem(value: 'settings', child: Text('Pengaturan')),
              const PopupMenuItem(value: 'fix_stock', child: Text('Fix Data Stok')),
              const PopupMenuItem(value: 'print_stock', child: Text('Cetak Stok')),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris Pencarian dan Sort
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Ikon Sort
                IconButton(
                  icon:
                      Icon(Icons.notifications, color: Colors.orange.shade900),
                  onPressed: () {
                    _showStockNotification();
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                      _applySearchAndSort();
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Nama', child: Text('Sort by Nama')),
                    const PopupMenuItem(value: 'Harga', child: Text('Sort by Harga')),
                  ],
                  child: Icon(FontAwesomeIcons.arrowUpShortWide,
                      color: Colors.orange.shade900),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 35, // Tinggi kolom pencarian
                    child: TextField(
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                          _applySearchAndSort();
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12), // Mengurangi padding horizontal
                        labelText: 'Cari Barang',
                        labelStyle: TextStyle(
                            color: Colors
                                .orange.shade900), // Mengubah warna teks label
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.orange.shade900), // Warna garis border
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.orange
                                  .shade900), // Warna garis border saat tidak fokus
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.orange.shade900,
                              width: 2.0), // Warna garis border saat fokus
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true, // Aktifkan latar belakang berwarna
                        fillColor: Colors.white70, // Warna latar belakang
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.barcode,
                      color: Colors.orange.shade900),
                  onPressed: _navigateToAddPage,
                ),
              ],
            ),
          ),
          // Daftar Barang
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredBarangList.length,
                    itemBuilder: (context, index) {
                      final barang = _filteredBarangList[index];
                      return ListTile(
                          onTap: () => _navigateToEditPage(barang),
                          title: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
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
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        barang['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        barang['code'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ]),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Stok: ${barang['quantity']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormat.format(
                                          double.parse(barang['price_sell'])),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _navigateToAddPage(),
        backgroundColor: Colors.orange.shade900,
        shape: const CircleBorder(), // Panggil fungsi untuk navigasi ke AddBarangPage
        child: Icon(Icons.add, color: Colors.white),
      )
    );
  }
}
