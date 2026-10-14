import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muscale/app.dart';
import 'package:muscale/data/database.dart';
import 'package:muscale/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  testWidgets('Onboarding → Tagebuch mit Startschätzung', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(overrides: [databaseProvider.overrideWith((ref) => db)], child: const MuScaleApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Willkommen bei MuScale'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Alter'), '30');
    await tester.enterText(find.widgetWithText(TextFormField, 'Größe'), '180');
    await tester.enterText(find.widgetWithText(TextFormField, 'Aktuelles Gewicht'), '85');
    await tester.pump();
    await tester.dragUntilVisible(find.text('Los geht’s'), find.byType(ListView), const Offset(0, -200));
    // Mann, 85 kg, 180 cm, 30 J., 3–5 Trainings, Erhalt: 1830 × 1,55 = 2836,5 → 2840 kcal
    expect(find.text('Tagesziel: 2.840 kcal'), findsOneWidget);

    await tester.tap(find.text('Los geht’s'));
    await tester.pumpAndSettle();

    expect(find.text('Heute'), findsOneWidget);
    expect(find.text('Ziel 2.840 kcal'), findsOneWidget);
    expect(find.text('Startschätzung'), findsOneWidget);
    final weights = await tester.runAsync(() => db.select(db.weightEntries).get());
    expect(weights!.single.kg, 85);

    await tester.pumpWidget(const SizedBox());
    // Drift schließt Stream-Abfragen verzögert; erst danach die Datenbank schließen.
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  });
}
