import 'package:flutter/material.dart';

class StockOpnamePage extends StatelessWidget {
  const StockOpnamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Opname'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Ganti dengan widget yang sesuai
            ListTile(
              title: const Text('Opname 1'),
              onTap: () {
                // Navigasi ke detail opname
              },
            ),
            ListTile(
              title: const Text('Opname 2'),
              onTap: () {
                // Navigasi ke detail opname
              },
            ),
            // Tambahkan lebih banyak item
          ],
        ),
      ),
    );
  }
}
