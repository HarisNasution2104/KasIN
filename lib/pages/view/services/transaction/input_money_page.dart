import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'order_confirmation_page.dart';

class InputMoneyPage extends StatefulWidget {
  final double totalAmount;
  final String transactionId;
  final List<Map<String, dynamic>> barangDitambahkan; // Tambahkan parameter untuk barang
  final List<Map<String, dynamic>> jasaDitambahkan;   // Tambahkan parameter untuk jasa

  const InputMoneyPage({
    super.key,
    required this.totalAmount,
    required this.transactionId,
    required this.barangDitambahkan,
    required this.jasaDitambahkan,
  });

  @override
  State<InputMoneyPage> createState() => _InputMoneyPageState();
}

class _InputMoneyPageState extends State<InputMoneyPage> {
  final TextEditingController _paymentController = TextEditingController();
  double _paymentAmount = 0.0;
  double _dueAmount = 0.0;

  final currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _dueAmount = widget.totalAmount;
  }

  void _addNumber(String number) {
    setState(() {
      _paymentController.text = (_paymentController.text + number).trim();
      _paymentAmount = double.tryParse(_paymentController.text) ?? 0.0;
      _dueAmount = widget.totalAmount - _paymentAmount;
    });
  }

  void _clearInput() {
    setState(() {
      _paymentController.clear();
      _paymentAmount = 0.0;
      _dueAmount = widget.totalAmount;
    });
  }

  void _setExactAmount() {
    setState(() {
      _paymentController.text = widget.totalAmount.toStringAsFixed(0);
      _paymentAmount = widget.totalAmount;
      _dueAmount = 0.0;
    });
  }

  Future<void> _updateStock() async {
    try {
      // Update stock for barang
      for (var item in widget.barangDitambahkan) {
        final response = await http.post(
          Uri.parse('https://seputar-it.eu.org/Transaksi/update_barang_stock.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'shop_id': 'YOUR_SHOP_ID', // Ganti dengan shop_id yang sesuai
            'code': item['code'],
            'quantity': item['quantity']
          }),
        );

        if (response.statusCode != 200) {
          print('Gagal memperbarui stok barang ${item['code']}.');
        }
      }

      // Update stock for jasa
      for (var item in widget.jasaDitambahkan) {
        final response = await http.post(
          Uri.parse('https://seputar-it.eu.org/Transaksi/update_jasa_stock.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'shop_id': 'YOUR_SHOP_ID', // Ganti dengan shop_id yang sesuai
            'unique_code': item['unique_code'],
            'quantity': item['quantity']
          }),
        );

        if (response.statusCode != 200) {
          print('Gagal memperbarui stok jasa ${item['unique_code']}.');
        }
      }
    } catch (e) {
      print('Error memperbarui stok: $e');
    }
  }

void _proceedToPayment() async {
  if (_paymentAmount >= widget.totalAmount) {
    // Simulasi proses pembayaran
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran berhasil!')),
    );

    // Update stok sebelum navigasi
    await _updateStock();

    // Panggil API untuk menyimpan data transaksi
    await _saveTransactionData();

    // Navigasi ke halaman konfirmasi
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          transactionId: widget.transactionId,
          paymentAmount: _paymentAmount,
          totalAmount: widget.totalAmount,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jumlah pembayaran tidak mencukupi!')),
    );
  }
}

Future<void> _saveTransactionData() async {
  try {
    final response = await http.post(
      Uri.parse('https://seputar-it.eu.org/Transaksi/save_transaction.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'transaction_id': widget.transactionId,
        'total_amount': widget.totalAmount,
        'payment_amount': _paymentAmount,
        'barang': widget.barangDitambahkan,
        'jasa': widget.jasaDitambahkan,
      }),
    );

    if (response.statusCode == 200) {
      print('Data transaksi berhasil disimpan.');
    } else {
      print('Gagal menyimpan data transaksi.');
    }
  } catch (e) {
    print('Error saat menyimpan data transaksi: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: Column(
          children: [
            Center(
              child: Text(
                currencyFormat.format(widget.totalAmount),
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.squareCheck, color: Colors.white),
            onPressed: _proceedToPayment,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(  // Menyusun teks di tengah layar
              child: Text(
                currencyFormat.format(_paymentAmount),
                style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Sisa: ${currencyFormat.format(_dueAmount)}',
              style: TextStyle(
                  fontSize: 15,
                  color: _dueAmount <= 0 ? Colors.green : Colors.red),
                  textAlign: TextAlign.end,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 18,
                ),
                itemCount: 15,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 3: // Button C
                      return ElevatedButton(
                        onPressed: _clearInput,
                        child: const Text('C'),
                      );
                    case 7: // Button Delete (icon)
                      return ElevatedButton(
                        onPressed: () {
                          if (_paymentController.text.isNotEmpty) {
                            setState(() {
                              _paymentController.text = _paymentController.text.substring(0, _paymentController.text.length - 1);
                              _paymentAmount = double.tryParse(_paymentController.text) ?? 0.0;
                              _dueAmount = widget.totalAmount - _paymentAmount;
                            });
                          }
                        },
                        child: const Icon(Icons.backspace),
                      );
                    case 11: // Button Money (icon)
                      return ElevatedButton(
                        onPressed: _setExactAmount,
                        child: const Icon(FontAwesomeIcons.moneyBill),
                      );
                    case 12: // Button 0
                      return ElevatedButton(
                        onPressed: () => _addNumber('0'),
                        child: const Text('0'),
                      );
                    case 13: // Button 000
                      return ElevatedButton(
                        onPressed: () => _addNumber('000'),
                        child: const Text('000'),
                      );
                    case 14: // Button .
                      return ElevatedButton(
                        onPressed: () => _addNumber('.'),
                        child: const Text('.'),
                      );
                    default: // Number buttons
                      int number = index + 1;
                      if (index == 0) {
                        number = 7;
                      } else if (index == 1) {
                        number = 8;
                      } else if (index == 2) {
                        number = 9;
                      } else if (index == 4) {
                        number = 4;
                      } else if (index == 5) {
                        number = 5;
                      } else if (index == 6) {
                        number = 6;
                      } else if (index == 8) {
                        number = 1;
                      } else if (index == 9) {
                        number = 2;
                      } else if (index == 10) {
                        number = 3;
                      }
                      return ElevatedButton(
                        onPressed: () => _addNumber('$number'),
                        child: Text('$number'),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
