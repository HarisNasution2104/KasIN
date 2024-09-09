import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'pages/view/service_page.dart';
import 'pages/view/customer_page.dart'; // Mengganti AddPage dengan CustomerPage
import 'pages/view/shop_page.dart';
import 'pages/view/account_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeTabPage(), // HomeTabPage sebagai tab default
    ServicePage(),
    CustomerPage(), // Ganti AddPage dengan CustomerPage
    ShopPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: const <Widget>[
          Icon(FontAwesomeIcons.home, size: 20),
          Icon(FontAwesomeIcons.windowRestore, size: 20),
          Icon(FontAwesomeIcons.user, size: 20), // Icon untuk CustomerPage
          Icon(FontAwesomeIcons.shop, size: 20),
          Icon(FontAwesomeIcons.userGear, size: 20),
        ],
        color: Colors.orange.shade900,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Statistik
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Total Laptops', '15'), // Dummy data; sesuaikan dengan data nyata
                _buildStatCard('Ongoing Services', '3'), // Dummy data; sesuaikan dengan data nyata
              ],
            ),
            const SizedBox(height: 20),
            // Daftar Laptop
            const Text('Laptop List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Dummy data; sesuaikan dengan data nyata
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.laptop),
                    title: Text('Laptop ${index + 1}'), // Dummy data; sesuaikan dengan data nyata
                    subtitle: const Text('Brand - Specs'),
                    onTap: () {
                      // Navigasi ke detail laptop
                      Navigator.pushNamed(
                        context,
                        '/laptop_details',
                        arguments: 'Laptop ${index + 1}', // Dummy data; sesuaikan dengan data nyata
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.orange.shade100,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

