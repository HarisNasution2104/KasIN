import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_customer_page.dart';

class AddServicePage extends StatefulWidget {
  final Map<String, dynamic>? service;

  const AddServicePage({super.key, this.service});

  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceProblemController = TextEditingController();
  final TextEditingController _completenessController = TextEditingController();
  final TextEditingController _customerCodeController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _technicianNameController = TextEditingController();

  String _selectedType = 'Laptop'; // Default selected type
  final List<String> _types = [
    'Laptop',
    'CPU',
    'Android',
    'MacBook',
    'iPhone',
    'Printer',
    'Scanner'
  ]; // Dropdown options
  String _status = 'Process'; // Default status
  String? _shopId; // Variable to store shop_id
  String? _customerId; // Variable to store customer_id
  String? _technicianName; // Variable to store technician's name
  @override
  void initState() {
    super.initState();
    _loadShopId();
    _loadTechnicianName(); // Load technician name on page initialization
    // If there is a service provided, populate the fields with that data
    if (widget.service != null) {
      final service = widget.service!;
      _serviceNameController.text = service['service_name'] ?? '';
      _serviceProblemController.text = service['service_problem'] ?? '';
      _completenessController.text = service['completeness'] ?? '';
      _customerCodeController.text = service['customer_code'] ?? '';
      _customerNameController.text = service['customer_name'] ?? '';
      _customerAddressController.text = service['customer_address'] ?? '';
      _customerPhoneController.text = service['customer_phone'] ?? '';
      _selectedType = service['type'] ?? 'Laptop';
      _status = service['status'] ?? 'Process';
      _customerId = (service['customer_id'] ?? '').toString();
      _technicianNameController.text =
          service['technician_name'] ?? ''; // Set technician name
    }
  }

  Future<void> _loadShopId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shopId = prefs.getString('shop_id');
    });
  }

  Future<void> _loadTechnicianName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _technicianName =
          prefs.getString('username'); // Load username from SharedPreferences
      _technicianNameController.text =
          _technicianName ?? ''; // Set technician name
    });
  }

  Future<void> _saveService() async {
    final serviceName = _serviceNameController.text;
    final serviceProblem = _serviceProblemController.text;
    final completeness = _completenessController.text;
    final status = _status;
    final technicianName = _technicianName ?? ''; // Use technicianName variable

    // Validasi tambahan untuk customer_id
    if (_customerId == null || _customerId!.isEmpty) {
      _handleError(
          'Customer ID tidak ditemukan. Pilih customer terlebih dahulu.');
      return;
    }

    // Lanjutkan dengan menyimpan layanan jika semua validasi terpenuhi
    const endpoint = 'https://seputar-it.eu.org/services/add_services.php';

    final body = {
      'shop_id': _shopId,
      'customer_id': _customerId,
      'customer_code': _customerCodeController.text,
      'customer_name': _customerNameController.text,
      'customer_address': _customerAddressController.text,
      'customer_phone': _customerPhoneController.text,
      'service_name': serviceName,
      'service_problem': serviceProblem,
      'completeness': completeness,
      'status': status,
      'type': _selectedType,
      'technician_name': technicianName, // Kirim nama teknisi
    };

    print('Sending data: $body'); // Debug print statement

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        _handleError(data['message'] ?? 'Gagal menyimpan layanan');
      }
    } catch (e) {
      _handleError('Terjadi kesalahan: $e');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service', style: TextStyle(color: Colors.white, fontSize: 25)),
        backgroundColor: Colors.orange.shade900,
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildCustomerTextFields(),
              const SizedBox(height: 20),
              _buildDropdown(), // Dropdown for type
              const SizedBox(height: 20),
              _buildTextField(_serviceNameController, 'Service Name',
                  enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_serviceProblemController, 'Service Problem',
                  enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_completenessController, 'Completeness',
                  enabled: true),
              const SizedBox(height: 30),
              _buildStatusDropdown(), // Dropdown for status at the bottom
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: _saveService,
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButton<String>(
        padding: const EdgeInsets.all(4.0),
        value: _selectedType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedType = newValue!;
          });
        },
        items: _types.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: Container(),
        isExpanded: true,
        hint: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Select Type'),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButton<String>(
        padding: const EdgeInsets.all(4.0),
        value: _status,
        onChanged: (String? newValue) {
          setState(() {
            _status = newValue!;
          });
        },
        items: ['Process', 'Failed', 'Take Of']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: Container(),
        isExpanded: true,
        hint: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Select Status'),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {required bool enabled}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(225, 95, 27, .3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.all(8),
          border: InputBorder.none,
        ),
        enabled: enabled,
      ),
    );
  }

  // Method to handle customer selection
  Widget _buildCustomerTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTextField(_customerCodeController, 'Customer Code',
                  enabled: false),
            ),
            const SizedBox(width: 10), // Spacing between the text field and icons
            IconButton(
              icon: Icon(Icons.add, color: Colors.orange[900]),
              onPressed: () async {
                final selectedCustomer = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectCustomerPage(),
                  ),
                );

                if (selectedCustomer != null) {
                  setState(() {
                    _customerCodeController.text =
                        selectedCustomer['customer_code'] ?? '';
                    _customerNameController.text =
                        selectedCustomer['customer_name'] ?? '';
                    _customerAddressController.text =
                        selectedCustomer['customer_address'] ?? '';
                    _customerPhoneController.text =
                        selectedCustomer['customer_phone'] ?? '';
                    _customerId = (selectedCustomer['id'] ?? '').toString();
                  });
                } else {
                  _handleError('Customer tidak dipilih.');
                }
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.qrcode, color: Colors.orange[900]),
              onPressed: () {
                // Implement QR code scanning logic here
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField(_customerNameController, 'Customer Name',
            enabled: false),
        const SizedBox(height: 10),
        _buildTextField(_customerAddressController, 'Customer Address',
            enabled: false),
        const SizedBox(height: 10),
        _buildTextField(_customerPhoneController, 'Customer Phone',
            enabled: false),
      ],
    );
  }
}
