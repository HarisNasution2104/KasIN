import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl untuk format mata uang
import 'edit_jasa_page.dart';
import 'add_jasa_page.dart';

class JasaPage extends StatefulWidget {
  const JasaPage({super.key});

  @override
  State<JasaPage> createState() => _JasaPageState();
}

class _JasaPageState extends State<JasaPage> {
  List<Map<String, dynamic>> _jasaList = [];
  List<Map<String, dynamic>> _filteredJasaList = [];
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
      await _fetchJasa();
    }
  }

  Future<void> _fetchJasa() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/Jasa/get_jasa.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response Data: $responseData'); // Debugging output
        setState(() {
          if (responseData['status'] == 'success' &&
              responseData['jasa'] != null) {
            _jasaList = List<Map<String, dynamic>>.from(responseData['jasa']);
            _filteredJasaList = _jasaList;
            _applySearchAndSort(); // Terapkan pencarian dan penyortiran
          } else {
            _jasaList = [];
            _filteredJasaList = [];
          }
        });
      } else {
        _showError('Gagal memuat data jasa.');
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
      _filteredJasaList = _jasaList.where((jasa) {
        final nameMatch =
            jasa['name'].toLowerCase().contains(_searchQuery.toLowerCase());
        return nameMatch;
      }).toList();

      if (_sortBy == 'Nama') {
        _filteredJasaList.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortBy == 'Harga') {
        _filteredJasaList.sort((a, b) =>
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
            builder: (context) => AddJasaPage(),
          ),
        )
        .then((_) =>
            _fetchJasa()); // Refresh data setelah kembali dari halaman tambah
  }

  void _navigateToEditPage(dynamic jasa) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EditJasaPage(jasa: jasa),
          ),
        )
        .then((_) =>
            _fetchJasa()); // Refresh data setelah kembali dari halaman edit
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
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jasa',
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
              const PopupMenuItem(
                  value: 'import_excel', child: Text('Import Excel')),
              const PopupMenuItem(
                  value: 'export_excel', child: Text('Export Excel')),
              const PopupMenuItem(value: 'settings', child: Text('Pengaturan')),
              const PopupMenuItem(
                  value: 'fix_stock', child: Text('Fix Data Stok')),
              const PopupMenuItem(
                  value: 'print_stock', child: Text('Cetak Stok')),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon:
                      Icon(Icons.notifications, color: Colors.orange.shade900),
                  onPressed: () {
                    // Implementasikan logika notifikasi jika perlu
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
                    const PopupMenuItem(
                        value: 'Nama', child: Text('Sort by Nama')),
                    const PopupMenuItem(
                        value: 'Harga', child: Text('Sort by Harga')),
                  ],
                  child: Icon(FontAwesomeIcons.arrowUpShortWide,
                      color: Colors.orange.shade900),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: TextField(
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                          _applySearchAndSort();
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        labelText: 'Cari Jasa',
                        labelStyle: TextStyle(color: Colors.orange.shade900),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange.shade900),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange.shade900),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.orange.shade900, width: 2.0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredJasaList.length,
                    itemBuilder: (context, index) {
                      final jasa = _filteredJasaList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  jasa['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    jasa['code'] ?? '',
                                    style: TextStyle(
                                      color: Colors.orange.shade900,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Text(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    currencyFormat.format(
                                      double.parse(jasa['price_sell'] ?? '0'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _navigateToEditPage(
                              jasa), // Navigasi ke halaman edit
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
