// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/pages/login_page.dart';

void main() {
  testWidgets('MyApp widget test for logged-in user', (WidgetTester tester) async {
    // Menyediakan nilai untuk isLoggedIn
    await tester.pumpWidget(MyApp(isLoggedIn: true)); // Misalnya, test dengan nilai true
    
    // Tambahkan assert atau expect untuk memeriksa halaman yang diharapkan
    expect(find.byType(HomePage), findsOneWidget); // Sesuaikan dengan hasil yang diharapkan
  });

  testWidgets('MyApp widget test for not logged-in user', (WidgetTester tester) async {
    // Menyediakan nilai untuk isLoggedIn
    await tester.pumpWidget(MyApp(isLoggedIn: false)); // Misalnya, test dengan nilai false
    
    // Tambahkan assert atau expect untuk memeriksa halaman yang diharapkan
    expect(find.byType(LoginPage), findsOneWidget); // Sesuaikan dengan hasil yang diharapkan
  });
}

