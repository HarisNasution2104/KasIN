import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'add_service_page.dart';
import 'edit_service_page.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});

  @override
  _ServiceDetailPageState createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _shopId = '';

  @override
  void initState() {
    super.initState();
    _loadShopId();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadShopId() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';

    if (_shopId.isNotEmpty) {
      await _loadServices();
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://seputar-it.eu.org/services/get_services.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'shop_id': _shopId}),
      );

      print('Response Status Code: ${response.statusCode}'); // Debugging
      print('Response Body: ${response.body}'); // Debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic> parsedServices = data['services'];
          setState(() {
            _services = List<Map<String, dynamic>>.from(parsedServices);
            _filteredServices = List.from(_services);
            _isLoading = false;
          });
        } else {
          _handleError('Failed to load services');
        }
      } else {
        _handleError('Failed to load services');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _services.where((service) {
        final name = service['service_name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _navigateToAddServicePage({Map<String, dynamic>? service}) async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServicePage(service: service),
      ),
    );

    if (shouldReload == true) {
      await _loadServices();
    }
  }

  void _navigateToEditServicePage({Map<String, dynamic>? service}) async {
    if (service == null) {
      _handleError('Data layanan tidak ditemukan');
      return;
    }

    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServicePage(service: service),
      ),
    );

    if (shouldReload == true) {
      await _loadServices();
    }
  }

  Widget _buildServiceListView() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (_filteredServices.isEmpty
            ? const Center(child: Text('Tidak ada layanan ditemukan.'))
            : ListView.builder(
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  final service = _filteredServices[index];

                  print('Service data: $service'); // Debugging

                  final serviceName = service['service_name'] ?? 'Layanan Tidak Dikenal';
                  final status = service['status'] ?? 'Tidak Diketahui';
                  final technicianName = service['technician_name'] ?? 'Teknisi Tidak Dikenal';
                  final customerCode = service['customer_code'] ?? 'Kode Tidak Dikenal';

                  return GestureDetector(
                    onTap: () {
                      _navigateToEditServicePage(service: service);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color.fromARGB(255, 150, 150, 150),
                              width: 1.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.build),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  status,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  technicianName,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  customerCode,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan', style: TextStyle(color: Colors.white, fontSize: 30)),
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
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Cari berdasarkan nama',
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            onChanged: (value) => _onSearchChanged(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: () => _navigateToAddServicePage(),
                          backgroundColor: Colors.white,
                          child: Icon(Icons.add, color: Colors.orange.shade900),
                        ),
                      ],
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
                  padding: const EdgeInsets.all(20),
                  child: _buildServiceListView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
