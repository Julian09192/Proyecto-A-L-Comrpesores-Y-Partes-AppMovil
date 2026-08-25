// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:proyecto_ayl_compresores_app_movil/main.dart';

void main() {
  testWidgets('muestra la pantalla inicial de la aplicación', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('A&L Compresores y Partes'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
