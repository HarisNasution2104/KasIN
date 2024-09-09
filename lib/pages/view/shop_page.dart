import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String _shopName = '';
  String _shopAddress = '';
  String _shopPhone = '';
  String _receiptFooter = '';
  String _logoUrl = '';
  String _shopId = '';

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopPhoneController = TextEditingController();
  final TextEditingController _receiptFooterController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> sampleData = [
    {'title': 'Item 1', 'price': 10.0, 'qty': 2},
    {'title': 'Item 2', 'price': 5.0, 'qty': 3},
  ];
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _shopId = prefs.getString('shop_id') ?? '';

    if (_shopId.isNotEmpty) {
      await _fetchShopDetails();
    }

    setState(() {
      _shopNameController.text = _shopName;
      _shopAddressController.text = _shopAddress;
      _shopPhoneController.text = _shopPhone;
      _receiptFooterController.text = _receiptFooter;
    });
  }

Future<void> _fetchShopDetails() async {
  final uri = Uri.parse('http://seputar-it.eu.org/Shop/get_shop.php');
  final prefs = await SharedPreferences.getInstance();
  final shopId = prefs.getString('shop_id') ?? '';

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': shopId}),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final shopDetails = jsonResponse['shop'];
        setState(() {
          _shopName = shopDetails['shop_name'];
          _shopAddress = shopDetails['shop_address'];
          _shopPhone = shopDetails['shop_phone'];
          _receiptFooter = shopDetails['receipt_footer'];
          _logoUrl = shopDetails['logo_url'] ?? ''; // Handle null by setting to empty string
        });

        await prefs.setString('shop_name', _shopName);
        await prefs.setString('shop_address', _shopAddress);
        await prefs.setString('shop_phone', _shopPhone);
        await prefs.setString('receipt_footer', _receiptFooter);
        await prefs.setString('logo_url', _logoUrl);
      } else {
        _showErrorDialog(
            'Failed to fetch shop details: ${jsonResponse['message']}');
      }
    } else {
      _showErrorDialog(
          'Failed to fetch shop details. Please try again later.');
    }
  } catch (e) {
    _showErrorDialog('An error occurred while fetching shop details: $e');
  }
}


  void _showChangeLogoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Shop Logo'),
          content: const Text('Select an image from your gallery or take a new one.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Pick from Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text('Take a Photo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      await _uploadLogo(pickedFile.path);
    }
  }

Future<void> _uploadLogo(String filePath) async {
  final uri = Uri.parse('http://seputar-it.eu.org/upload_logo.php');
  final request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('logo', filePath))
    ..fields['shop_id'] = _shopId;

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBody);

    if (jsonResponse['status'] == 'success') {
      setState(() {
        _logoUrl = jsonResponse['logo_url'] ?? ''; // Handle null by setting to empty string
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logo_url', _logoUrl);
    } else {
      _showErrorDialog('Failed to upload logo: ${jsonResponse['message']}');
    }
  } catch (e) {
    _showErrorDialog('An error occurred while uploading the logo: $e');
  }
}

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopNameController.text);
    await prefs.setString('shop_address', _shopAddressController.text);
    await prefs.setString('shop_phone', _shopPhoneController.text);
    await prefs.setString('receipt_footer', _receiptFooterController.text);

    await _updateShopDetails();
  }

  Future<void> _updateShopDetails() async {
    final uri = Uri.parse('http://seputar-it.eu.org/Shop/shop.php');
    try {
      final response = await http.post(uri, body: {
        'shop_id': _shopId,
        'shop_name': _shopNameController.text.trim(),
        'shop_address': _shopAddressController.text.trim(),
        'shop_phone': _shopPhoneController.text.trim(),
        'receipt_footer': _receiptFooterController.text.trim(),
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          print('Shop details updated successfully');
        } else {
          _showErrorDialog(
              'Failed to update shop details: ${jsonResponse['message']}');
        }
      } else {
        _showErrorDialog(
            'Failed to update shop details. Please try again later.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while updating shop details: $e');
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Shop Settings",
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _logoUrl.isEmpty
                                ? const AssetImage('assets/images/default_logo.png')
                                : NetworkImage(_logoUrl),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: _showChangeLogoDialog,
                              child: Container(
                                padding: const EdgeInsets.all(7.0),
                                decoration: BoxDecoration(
                                  color: Colors.orange[900],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_shopNameController, 'Shop Name'),
                      const SizedBox(height: 10),
                      _buildTextField(_shopAddressController, 'Shop Address'),
                      const SizedBox(height: 10),
                      _buildTextField(_shopPhoneController, 'Shop Phone'),
                      const SizedBox(height: 10),
                      _buildTextField(
                          _receiptFooterController, 'Receipt Footer'),
                      const SizedBox(height: 30),
                      MaterialButton(
                        onPressed: _saveSettings,
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        onPressed: _saveSettings,
                        height: 50,
                        color: Colors.orange[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Test Print",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
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
          contentPadding: const EdgeInsets.all(15),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
