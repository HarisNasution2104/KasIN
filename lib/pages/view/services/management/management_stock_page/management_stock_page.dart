import 'package:flutter/material.dart';

class ManagementStockPage extends StatelessWidget {
  const ManagementStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Ganti dengan widget yang sesuai
            ListTile(
              title: const Text('Stok Barang 1'),
              onTap: () {
                // Navigasi ke detail stok
              },
            ),
            ListTile(
              title: const Text('Stok Barang 2'),
              onTap: () {
                // Navigasi ke detail stok
              },
            ),
            // Tambahkan lebih banyak item
          ],
        ),
      ),
    );
  }
}
