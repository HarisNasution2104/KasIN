import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ShopDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> barangDitambahkan;

  const ShopDetailPage({super.key, required this.barangDitambahkan});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Menghitung total harga
    final totalHarga = barangDitambahkan.fold<double>(
      0.0,
      (sum, item) {
        final quantity = item['quantity'] as int? ?? 0;
        final isBarang = item['isBarang'] as bool? ?? true;
        final priceSell = item['price_sell'] as String?;
        final price = isBarang
            ? double.tryParse(priceSell ?? '') ?? 0.0
            : double.tryParse(item['price'] as String? ?? '') ?? 0.0;

        return sum + (quantity * price);
      },
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange.shade900,
          title: Column(
            children: [
              Center(
                child: Text(
                  currencyFormat.format(totalHarga),
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
              icon: const Icon(
                FontAwesomeIcons.cashRegister,
                color: Colors.white,
              ), // Gunakan ikon kasir atau ikon pembayaran sesuai keinginan
              onPressed: () {
                // Handle checkout action here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proceed to payment')),
                );
              },
            ),
            const SizedBox(width: 16), // Tambahkan jarak di sebelah kanan ikon
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: barangDitambahkan.length,
                itemBuilder: (context, index) {
                  final item = barangDitambahkan[index];
                  final isBarang = item['isBarang'] as bool? ?? true;
                  final priceSell = item['price_sell'] as String?;
                  final price = isBarang
                      ? double.tryParse(priceSell ?? '') ?? 0.0
                      : double.tryParse(item['price'] as String? ?? '') ?? 0.0;

                  return ListTile(
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${item['quantity']} X ${currencyFormat.format(price)} = ${currencyFormat.format(item['quantity'] * price)}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
         child:
           FloatingActionButton(
            backgroundColor: Colors.orange.shade900,
            onPressed: () {},
            tooltip: 'Tambah Barang',
            shape: const CircleBorder(),
            child: Icon(FontAwesomeIcons.personRays, color: Colors.white),
          ),
        )
        );
  }
}
