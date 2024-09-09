import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _shopId = '';

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShopId();
  }

  Future<void> _loadShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getString('shop_id') ?? '';
    });
    if (_shopId.isNotEmpty) {
      _loadCustomers();
    }
  }

  Future<void> _loadCustomers() async {
    if (_shopId.isEmpty) {
      _handleError('Shop ID is missing.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://seputar-it.eu.org/customers/get_customers.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'shop_id': _shopId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic> parsedCustomers = data['customers'];
          setState(() {
            _customers = List<Map<String, dynamic>>.from(parsedCustomers);
            _filteredCustomers = List.from(_customers);
            _isLoading = false;
          });
        } else {
          _handleError(data['message']);
        }
      } else {
        _handleError('Failed to load customer list.');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final name = customer['customer_name'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _addCustomer() async {
    if (_shopId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final customerName = _customerNameController.text;
    final customerAddress = _customerAddressController.text;
    final customerPhone = _customerPhoneController.text;

    try {
      final response = await http.post(
        Uri.parse('http://seputar-it.eu.org/customers/add_customer.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'shop_id': _shopId,
          'customer_name': customerName,
          'customer_address': customerAddress,
          'customer_phone': customerPhone,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          await _loadCustomers();
          Navigator.pop(context);
        } else {
          _handleError(data['message'] ?? 'Failed to add customer');
        }
      } else {
        _handleError('Error occurred while adding customer');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

Future<void> _deleteCustomer(int customerId) async {
  if (_shopId.isEmpty) return;

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final response = await http.post(
      Uri.parse('https://seputar-it.eu.org/customers/delete_customer.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': customerId.toString(),  // Convert int to String
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        await _loadCustomers();
      } else {
        _handleError(data['message'] ?? 'Failed to delete customer');
      }
    } else {
      _handleError('Error occurred while deleting customer');
    }
  } catch (e) {
    _handleError('An error occurred: $e');
  }
}

Future<void> _updateCustomer(int customerId) async {
  if (_shopId.isEmpty) return;

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  final customerName = _customerNameController.text;
  final customerAddress = _customerAddressController.text;
  final customerPhone = _customerPhoneController.text;

  try {
    final response = await http.post(
      Uri.parse('http://seputar-it.eu.org/customers/update_customer.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': customerId.toString(),  // Ensure `customerId` is a String
        'customer_name': customerName,
        'customer_address': customerAddress,
        'customer_phone': customerPhone,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        await _loadCustomers();
        Navigator.pop(context);
      } else {
        _handleError(data['message'] ?? 'Failed to update customer');
      }
    } else {
      _handleError('Error occurred while updating customer');
    }
  } catch (e) {
    _handleError('An error occurred: $e');
  }
}

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Widget _buildReadOnlyTextField(String text, String label) {
    return TextField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        labelText: label,
      ),
      readOnly: true,
    );
  }

  void _showAddCustomerDialog() {
    _clearControllers(); // Clear controllers before showing the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_customerNameController, 'Customer Name'),
                _buildTextField(_customerAddressController, 'Customer Address'),
                _buildTextField(
                  _customerPhoneController,
                  'Customer Phone',
                  keyboardType: TextInputType.phone,
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addCustomer,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _clearControllers() {
    _customerNameController.clear();
    _customerAddressController.clear();
    _customerPhoneController.clear();
  }

void _showEditCustomerDialog(Map<String, dynamic> customer) {
  _customerNameController.text = customer['customer_name'];
  _customerAddressController.text = customer['customer_address'];
  _customerPhoneController.text = customer['customer_phone'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Stack(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Edit Customer'),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReadOnlyTextField(customer['customer_code'], 'Customer Code'),
              _buildTextField(_customerNameController, 'Customer Name'),
              _buildTextField(_customerAddressController, 'Customer Address'),
              _buildTextField(_customerPhoneController, 'Customer Phone',
                  keyboardType: TextInputType.phone),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteCustomer(customer['id']);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              _updateCustomer(customer['id']);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

  void _confirmDeleteCustomer(int customerId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCustomer(customerId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Widget _buildCustomerListView() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : (_filteredCustomers.isEmpty
            ? const Center(child: Text('No customers found.'))
            : ListView.builder(
                itemCount: _filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = _filteredCustomers[index];
                  return GestureDetector(
                    onTap: () {
                      _showEditCustomerDialog(customer);
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
                          child: Icon(Icons.person),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${customer["customer_name"]}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${customer["customer_code"]}',
                                style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                            ),
                            // Text(
                            //   '${customer["customer_name"]}',
                            //   style: TextStyle(
                            //       fontSize: 16, fontWeight: FontWeight.bold),
                            // ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${customer["customer_address"]}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${customer["customer_phone"]}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                  ),
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Customer",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search by name',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                          onPressed: _showAddCustomerDialog,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.orange),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCustomerListView(),
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
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: CustomerPage(),
  ));
}
