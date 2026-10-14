import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muscale/data/database.dart';
import 'package:muscale/features/food/recipe_screen.dart';
import 'package:muscale/providers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de'));

  testWidgets('Rezept aus zuletzt gegessener Zutat anlegen', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() async {
      final oats = await db.upsertFood(
        FoodsCompanion.insert(name: 'Haferflocken', source: FoodSource.custom, kcal: const Value(372)),
      );
      await db.addEntry(day: '2026-10-01', meal: Meal.breakfast, foodId: oats.id, amount: 50);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWith((ref) => db)],
        child: const MaterialApp(home: RecipeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Overnight Oats');
    await tester.enterText(find.widgetWithText(TextFormField, 'Portionen'), '2');
    await tester.tap(find.text('Zutat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haferflocken'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('100 g'));
    await tester.pump();
    await tester.tap(find.text('Übernehmen'));
    await tester.pumpAndSettle();

    expect(find.text('Pro Portion (50 g)'), findsOneWidget);
    expect(find.textContaining('186 kcal'), findsOneWidget);

    await tester.tap(find.text('Rezept speichern'));
    await tester.pumpAndSettle();

    final recipes = await tester.runAsync(() => db.watchRecipes().first);
    expect(recipes!.single.name, 'Overnight Oats');
    expect(recipes.single.servingSize, 50);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  });
}
