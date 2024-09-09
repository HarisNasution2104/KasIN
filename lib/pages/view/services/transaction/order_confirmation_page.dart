import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'transaction_detail_page.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String transactionId;
  final double paymentAmount;
  final double totalAmount;

  OrderConfirmationPage({
    Key? key,
    required this.transactionId,
    required this.paymentAmount,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double changeAmount = paymentAmount - totalAmount;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Lottie.asset(
                'assets/success_animation.json',
                width: 250,
                repeat: false,
              ),
            ),
            Text(
              'Success',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Transaction Successful!!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Kembalian: Rp ${changeAmount.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16), // Adjust padding to shift text
                  child: Text('View Details'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade900,
                side: BorderSide(color: Colors.orange.shade900, width: 2),
                minimumSize: Size(200, 60), // Shorter width, height 60
                padding: EdgeInsets.symmetric(vertical: 16), // Larger padding
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implement the logic to print the receipt
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16), // Adjust padding to shift text
                  child: Text('Print Receipt'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade900,
                side: BorderSide(color: Colors.orange.shade900, width: 2),
                minimumSize: Size(200, 60), // Shorter width, height 60
                padding: EdgeInsets.symmetric(vertical: 16), // Larger padding
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => TransactionsDetailPage(), // Ganti dengan halaman tujuan
  ),
);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16), // Adjust padding to shift text
                  child: Text(
                    'Transaksi Baru',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade900,
                minimumSize: Size(200, 60), // Shorter width, height 60
                padding: EdgeInsets.symmetric(vertical: 16), // Larger padding
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Center(
        child: Text('Details of the transaction will be shown here.'),
      ),
    );
  }
}
