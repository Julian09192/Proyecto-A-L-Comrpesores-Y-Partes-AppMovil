import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proyecto_ayl_compresores_app_movil/app.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/supabase/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize();
  });

  testWidgets('muestra el catálogo al abrir la aplicación', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MiApp());
    await tester.pump();

    expect(find.text('Equipos Destacados'), findsOneWidget);
  });
}