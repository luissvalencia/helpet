import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:helpet_app/main.dart';

void main() {
  testWidgets('MyApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const HelPetApp());
    await tester.pumpAndSettle();
    // Ajusta esta expectativa a un texto que realmente exista en tu WelcomeScreen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
