import 'package:flutter/material.dart';

class RecordsDetailPage extends StatelessWidget {
  const RecordsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: Colors.orange.shade900,
      ),
      body: const Center(
        child: Text('This is the Records page content.'),
      ),
    );
  }
}
