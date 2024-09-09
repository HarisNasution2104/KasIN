import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'select_customer_page.dart';
import 'input_money_page.dart';

class ShopDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> barangDitambahkan;
  final List<Map<String, dynamic>> jasaDitambahkan;

  const ShopDetailPage({
    super.key,
    required this.barangDitambahkan,
    required this.jasaDitambahkan,
  });

  @override
  _ShopDetailPageState createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  List<Map<String, dynamic>> _customers = [];
  String _selectedCustomerName = '';
  String? _customerId;
  final _transactionNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TextEditingController _textEditingController = TextEditingController();
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
      await _fetchCustomers();
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/customers/get_customers.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _customers = List<Map<String, dynamic>>.from(data['customers']);
        });
      } else {
        print('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  void _showDetailTransaksi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Transaksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _transactionNameController,
                  decoration: InputDecoration(
                    hintText: 'Nama Transaksi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: 'Pilih Pelanggan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green.shade700, width: 5.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _navigateToSelectCustomerPage(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Keterangan',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                final transactionName = _transactionNameController.text;
                final customerName = _textEditingController.text;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaksi: $transactionName\nPelanggan: $customerName')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateItemDialog(BuildContext context, int index, bool isBarang) {
    final item = isBarang ? widget.barangDitambahkan[index] : widget.jasaDitambahkan[index];
    final quantityController = TextEditingController(text: item['quantity']?.toString() ?? '0');
    final temporaryPriceController = TextEditingController(text: item['temporary_price']?.toString() ?? '');
    final discountController = TextEditingController(text: item['discount']?.toString() ?? '');
    final noteController = TextEditingController(text: item['note']?.toString() ?? '');

    final name = item['name'] ?? 'Unknown';
    final stock = item['stok']?.toString() ?? 'Unlimited';
    final code = isBarang ? item['code']?.toString() ?? 'N/A' : item['unique_code']?.toString() ?? 'N/A';
    final price = isBarang ? double.tryParse(item['price_sell']?.toString() ?? '0') ?? 0.0 : double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(code, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(stock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(currencyFormat.format(price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          int currentQuantity = int.tryParse(quantityController.text) ?? 0;
                          if (currentQuantity > 0) {
                            quantityController.text = (currentQuantity - 1).toString();
                          }
                        });
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Quantity'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          int currentQuantity = int.tryParse(quantityController.text) ?? 0;
                          quantityController.text = (currentQuantity + 1).toString();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: temporaryPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isBarang ? 'Harga Jual Sementara' : 'Harga Jasa Sementara',
                    hintText: 'Masukkan harga sementara',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Diskon',
                    hintText: 'Masukkan diskon',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Masukkan catatan',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                final newQuantity = int.tryParse(quantityController.text) ?? 0;
                final temporaryPrice = double.tryParse(temporaryPriceController.text);
                final discount = double.tryParse(discountController.text) ?? 0.0;
                final note = noteController.text;

                if (newQuantity > 0) {
                  setState(() {
                    if (isBarang) {
                      widget.barangDitambahkan[index]['quantity'] = newQuantity;
                      widget.barangDitambahkan[index]['temporary_price'] =
                          temporaryPrice ?? widget.barangDitambahkan[index]['price_sell'];
                      widget.barangDitambahkan[index]['discount'] = discount;
                      widget.barangDitambahkan[index]['note'] = note;
                    } else {
                      widget.jasaDitambahkan[index]['quantity'] = newQuantity;
                      widget.jasaDitambahkan[index]['temporary_price'] =
                          temporaryPrice ?? widget.jasaDitambahkan[index]['price'];
                      widget.jasaDitambahkan[index]['discount'] = discount;
                      widget.jasaDitambahkan[index]['note'] = note;
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quantity harus lebih dari nol')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToSelectCustomerPage(BuildContext context) async {
    final selectedCustomer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCustomerPage(
          customers: _customers,
          shopId: _shopId,
        ),
      ),
    );

    if (selectedCustomer != null) {
      setState(() {
        _selectedCustomerName = selectedCustomer['customer_name'] ?? '';
        _customerId = selectedCustomer['id']?.toString();
        _textEditingController.text = _selectedCustomerName;
      });
    }
  }

  void _calculateTotalAndNavigateToPayment() {
    final totalPrice = _calculateTotalPrice();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputMoneyPage(
          totalAmount: totalPrice,
          transactionId: 'your_generated_transaction_id', // Replace with actual transaction ID if available
                  barangDitambahkan: widget.barangDitambahkan, // Pass barangDitambahkan
        jasaDitambahkan: widget.jasaDitambahkan, // Pass jasaDitambahkan
        ),
      ),
    );
  }

  double _calculateTotalPrice() {
    double totalBarangHarga = widget.barangDitambahkan.fold<double>(
      0.0,
      (sum, item) {
        final quantity = item['quantity'] as int? ?? 0;
        final price = double.tryParse(item['temporary_price']?.toString() ?? '') ??
            double.tryParse(item['price_sell']?.toString() ?? '0') ?? 0.0;
        return sum + (quantity * price);
      },
    );

    double totalJasaHarga = widget.jasaDitambahkan.fold<double>(
      0.0,
      (sum, item) {
        final quantity = item['quantity'] as int? ?? 0;
        final price = double.tryParse(item['temporary_price']?.toString() ?? '') ??
            double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
        return sum + (quantity * price);
      },
    );

    return totalBarangHarga + totalJasaHarga;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalHarga = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: Center(
          child: Text(
            currencyFormat.format(totalHarga),
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.cashRegister, color: Colors.white),
            onPressed: _calculateTotalAndNavigateToPayment,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Tambah Biaya', style: TextStyle(color: Colors.orange.shade900)),
            onTap: () {
              // Handle 'Tambah Biaya' action
            },
          ),
          Expanded(
            child: ListView(
              children: [
                ...widget.barangDitambahkan.map((item) {
                  final price = double.tryParse(item['temporary_price']?.toString() ?? '') ??
                      double.tryParse(item['price_sell']?.toString() ?? '0') ??
                      0.0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        item['name']?.substring(0, 2).toUpperCase() ?? 'AD',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${item['quantity']} x ${currencyFormat.format(price)} = ${currencyFormat.format(item['quantity'] * price)}',
                    ),
                    onTap: () {
                      _showUpdateItemDialog(context, widget.barangDitambahkan.indexOf(item), true);
                    },
                  );
                }),
                ...widget.jasaDitambahkan.map((item) {
                  final price = double.tryParse(item['temporary_price']?.toString() ?? '') ??
                      double.tryParse(item['price']?.toString() ?? '0') ??
                      0.0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        item['name']?.substring(0, 2).toUpperCase() ?? 'AD',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${item['quantity']} x ${currencyFormat.format(price)} = ${currencyFormat.format(item['quantity'] * price)}',
                    ),
                    onTap: () {
                      _showUpdateItemDialog(context, widget.jasaDitambahkan.indexOf(item), false);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: () {
          _showDetailTransaksi(context);
        },
        shape: const CircleBorder(),
        child: const Icon(
          FontAwesomeIcons.userCheck,
          color: Colors.white,
        ),
      ),
    );
  }
}
