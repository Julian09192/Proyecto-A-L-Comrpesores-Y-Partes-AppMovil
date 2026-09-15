import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyecto_ayl_compresores_app_movil/app.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/supabase/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    dotenv.loadFromString(
      envString: 'SUPABASE_URL=https://dummy.supabase.co\nSUPABASE_ANON_KEY=dummy-anon-key\n',
    );
    SharedPreferences.setMockInitialValues({});
    await SupabaseService.initialize();
  });

  testWidgets('muestra el catálogo al abrir la aplicación', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MiApp());
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('Productos Destacados'), findsOneWidget);
  });
}