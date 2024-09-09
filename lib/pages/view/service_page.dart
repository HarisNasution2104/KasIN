import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'services/report/report_detail_page.dart';
import 'services/transaction/transaction_detail_page.dart';
import 'services/pembelian/pembelian_detail_page.dart';
import 'services/archive/archive_detail_page.dart';
import 'services/service_details/service_detail_page.dart';
import 'services/finance/finance_detail_page.dart';
import 'services/document/documents_detail_page.dart';
import 'services/file/files_detail_page.dart';
import 'services/record/records_detail_page.dart';
import 'services/staff/staff_detail_page.dart';
import 'services/categories_services_page.dart';
import 'services/management/management_page.dart';

class ServicePage extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {'icon': FontAwesomeIcons.wrench, 'name': 'Service', 'page': ServiceDetailPage()},
    {'icon': FontAwesomeIcons.cartPlus, 'name': 'Penjualan', 'page': const TransactionsDetailPage()},
    {'icon': FontAwesomeIcons.truck, 'name': 'Pembelian', 'page': PembelianDetailPage()},
    {'icon': FontAwesomeIcons.fileLines, 'name': 'Report', 'page': ReportDetailPage()},
    {'icon': FontAwesomeIcons.boxArchive, 'name': 'Archive', 'page': ArchiveDetailPage()},
    {'icon': FontAwesomeIcons.moneyBills, 'name': 'Finance', 'page': FinanceDetailPage()},
    {'icon': FontAwesomeIcons.fileLines, 'name': 'Documents', 'page': DocumentsDetailPage()},
    {'icon': FontAwesomeIcons.fileLines, 'name': 'Files', 'page': FilesDetailPage()},
    {'icon': FontAwesomeIcons.fileLines, 'name': 'Records', 'page': RecordsDetailPage()},
    {'icon': Icons.person, 'name': 'Karyawan', 'page': StaffPage()},
    {'icon': FontAwesomeIcons.list, 'name': 'Categories', 'page': const CategoriesServicesPage()},
    {'icon': FontAwesomeIcons.layerGroup, 'name': 'Management', 'page': ManagementPage()},
  ];

  ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Services",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: const Text(
                      "Choose the services you need",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () {
                          final page = service['page'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => page!,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.shade900,
                              ),
                              child: Center(
                                child: Icon(
                                  service['icon'],
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
