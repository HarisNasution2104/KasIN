import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class EditServicePage extends StatefulWidget {
  final Map<String, dynamic>? service;

  const EditServicePage({super.key, this.service});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceProblemController = TextEditingController();
  final TextEditingController _completenessController = TextEditingController();
  final TextEditingController _customerCodeController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  String _selectedType = 'Laptop'; // Default selected type
  final List<String> _types = ['Laptop', 'CPU', 'Android', 'MacBook', 'iPhone', 'Printer', 'Scanner']; // Dropdown options
  String _status = 'Pending'; // Default status

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      // Inisialisasi data dari widget.service
      _serviceNameController.text = widget.service?['service_name'] ?? '';
      _serviceProblemController.text = widget.service?['service_problem'] ?? '';
      _completenessController.text = widget.service?['completeness'] ?? '';
      _status = widget.service?['status'] ?? 'Pending'; // Load the status if available
      _selectedType = widget.service?['type'] ?? 'Laptop'; // Load the type if available
      
      // Tampilkan data customer dari service
      _customerCodeController.text = widget.service?['customer_code'] ?? '';
      _customerNameController.text = widget.service?['customer_name'] ?? '';
      _customerAddressController.text = widget.service?['customer_address'] ?? '';
      _customerPhoneController.text = widget.service?['customer_phone'] ?? '';
    }
  }

  Future<void> _updateService() async {
    final serviceName = _serviceNameController.text;
    final serviceProblem = _serviceProblemController.text;
    final completeness = _completenessController.text;
    final serviceId = widget.service?['id'];

    const endpoint = 'http://seputar-it.eu.org/services/update_services.php';

    final body = {
      'service_name': serviceName,
      'service_problem': serviceProblem,
      'completeness': completeness,
      'type': _selectedType,
      'customer_id': widget.service?['customer_id'],
      'status': _status,
      'id': serviceId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        _handleError(data['message'] ?? 'Failed to update service');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _deleteService() async {
    final serviceId = widget.service?['id'];

    const endpoint = 'http://seputar-it.eu.org/services/delete_services.php';

    final body = {
      'id': serviceId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        _handleError(data['message'] ?? 'Failed to delete service');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service', style: TextStyle(color: Colors.white, fontSize: 25)),
        backgroundColor: Colors.orange.shade900,
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete,color: Colors.white,),
            onPressed: () {
              _deleteService();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildCustomerTextFields(),
              const SizedBox(height: 20),
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildTextField(_serviceNameController, 'Service Name', enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_serviceProblemController, 'Service Problem', enabled: true),
              const SizedBox(height: 10),
              _buildTextField(_completenessController, 'Completeness', enabled: true),
              const SizedBox(height: 20),
              _buildStatusDropdown(),
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: _updateService,
                height: 50,
                color: Colors.orange[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    "Update",
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

  Widget _buildTextField(TextEditingController controller, String label, {required bool enabled}) {
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

Widget _buildCustomerTextFields() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
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
                controller: _customerCodeController,
                decoration: const InputDecoration(
                  labelText: 'Customer Code',
                  contentPadding: EdgeInsets.all(8),
                  border: InputBorder.none,
                ),
                enabled: false, // Disable editing
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTextField(_customerNameController, 'Customer Name', enabled: false),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _buildTextField(_customerAddressController, 'Customer Address', enabled: false),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _buildTextField(_customerPhoneController, 'Customer Phone', enabled: false),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            onPressed: () {
              // Tambahkan aksi untuk ikon WhatsApp di sini
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.blue),
            onPressed: () {
              // Salin nomor telepon ke clipboard
              Clipboard.setData(ClipboardData(text: _customerPhoneController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number copied to clipboard')),
              );
            },
          ),
        ],
      ),
    ],
  );
}

  Widget _buildStatusDropdown() {
    final List<String> statuses = ['Process', 'Failed', 'Take Of']; // Status options
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
        value: _status,
        onChanged: (String? newValue) {
          setState(() {
            _status = newValue!;
          });
        },
        items: statuses.map<DropdownMenuItem<String>>((String value) {
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
}
