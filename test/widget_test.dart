import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_project/main.dart';

void main() {
  testWidgets('welcome screen opens login page', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartParkingApp());

    expect(find.text('Smart Parking\nSystem'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Sign Up'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
