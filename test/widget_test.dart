import 'package:constructtion/src/app.dart';
import 'package:constructtion/src/auth/repositories/api_auth_repository.dart';
import 'package:constructtion/src/data/mock_store_repository.dart';
import 'package:constructtion/src/state/store_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows splash screen before initialization completes', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final controller = StoreController(
      repository: MockStoreRepository(),
      authRepository: ApiAuthRepository(),
    );

    await tester.pumpWidget(ConstructionApp(controller: controller));
    expect(find.text('TAN MENG'), findsOneWidget);
    expect(find.text('Best Tools, Best Work'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Hello, User 👋'), findsOneWidget);
  });
}
