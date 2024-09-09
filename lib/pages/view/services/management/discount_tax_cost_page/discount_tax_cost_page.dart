import 'package:flutter/material.dart';

class DiscountTaxCostPage extends StatelessWidget {
  const DiscountTaxCostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diskon Pajak dan Biaya'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Ganti dengan widget yang sesuai
            ListTile(
              title: const Text('Diskon 1'),
              onTap: () {
                // Navigasi ke detail diskon
              },
            ),
            ListTile(
              title: const Text('Pajak 1'),
              onTap: () {
                // Navigasi ke detail pajak
              },
            ),
            // Tambahkan lebih banyak item
          ],
        ),
      ),
    );
  }
}
