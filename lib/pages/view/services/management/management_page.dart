import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Barang_dan Jasa/barang_page.dart';
import 'Barang_dan Jasa/jasa_page.dart';
import 'categories_services_page/categories_services_page.dart'; // Sesuaikan dengan path sebenarnya
import 'management_stock_page/management_stock_page.dart'; // Sesuaikan dengan path sebenarnya
import 'discount_tax_cost_page/discount_tax_cost_page.dart'; // Sesuaikan dengan path sebenarnya
import 'stock_opname_page/stock_opname_page.dart'; // Sesuaikan dengan path sebenarnya

class ManagementPage extends StatelessWidget {
  final List<Map<String, dynamic>> managementItems = [
    {
      'icon': FontAwesomeIcons.boxesPacking,
      'name': 'Barang',
      'page': const BarangPage()
    },
    {
      'icon': FontAwesomeIcons.warehouse,
      'name': 'Jasa',
      'page': const JasaPage()
    },
    {
      'icon': FontAwesomeIcons.gripLines,
      'name': 'Kategori Barang',
      'page': CategoriesServicesPage()
    },
    {
      'icon': FontAwesomeIcons.truckRampBox,
      'name': 'Manajemen Stok',
      'page': ManagementStockPage()
    },
    {
      'icon': FontAwesomeIcons.newspaper,
      'name': 'Diskon Pajak dan Biaya',
      'page': DiscountTaxCostPage()
    },
    {
      'icon': FontAwesomeIcons.chalkboardUser,
      'name': 'Stok Opname',
      'page': StockOpnamePage()
    },
  ];

 ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management',
            style: TextStyle(color: Colors.white, fontSize: 30)),
        backgroundColor: Colors.orange.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.orange.shade900,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: ListView.builder(
                    itemCount: managementItems.length,
                    itemBuilder: (context, index) {
                      final item = managementItems[index];
                      return GestureDetector(
                        onTap: () {
                          final page = item['page'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => page!,
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Icon(
                              item['icon'],
                              color: Colors.orange.shade900,
                              size: 30,
                            ),
                            title: Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
