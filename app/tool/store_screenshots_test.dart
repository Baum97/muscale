// Testwerkzeug außerhalb von test/: Test-Hilfen der Pakete sind hier gewollt.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muscale/app.dart';
import 'package:muscale/data/database.dart';
import 'package:muscale/domain/days.dart';
import 'package:muscale/domain/energy.dart';
import 'package:muscale/features/food/add_food.dart';
import 'package:muscale/features/settings/appearance_screen.dart';
import 'package:muscale/features/today/today_screen.dart';
import 'package:muscale/providers.dart';
import 'package:muscale/services/home_widget_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Store-Screenshots aus der echten App mit Beispieldaten. Nicht Teil der normalen Tests.
//   cd app && flutter test tool/store_screenshots_test.dart --update-goldens
//   node ../scripts/store-graphics.js
// Rohbilder landen in app/build/store/raw, fertige Grafiken in fastlane/metadata/android/de-DE/images.
const out = '../build/store/raw';

Future<void> loadFont(String family, String path) async {
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

late Food skyr;

Future<void> seed(AppDatabase db) async {
  await db.saveProfile(
    ProfilesCompanion.insert(
      sex: Sex.male,
      birthYear: 1995,
      heightCm: 182,
      activity: ActivityLevel.moderate,
      goal: Goal.cut,
      pacePercent: -0.5,
      proteinPerKg: 2.0,
      calorieTargetOverride: const Value(2450),
    ),
  );
  Future<Food> f(
    String name,
    double kcal,
    double p,
    double c,
    double s,
    double fat,
    double sat, {
    String? brand,
    double? fiber,
    double? serving,
    bool liquid = false,
    String? barcode,
  }) => db.upsertFood(
    FoodsCompanion.insert(
      name: name,
      brand: Value(brand),
      barcode: Value(barcode),
      source: FoodSource.openFoodFacts,
      isLiquid: Value(liquid),
      servingSize: Value(serving),
      kcal: Value(kcal),
      protein: Value(p),
      carbs: Value(c),
      sugar: Value(s),
      fiber: Value(fiber),
      fat: Value(fat),
      saturatedFat: Value(sat),
    ),
  );
  final oats = await f('Zarte Haferflocken', 372, 13.5, 58.7, 0.7, 7, 1.3, brand: 'Kölln', fiber: 10);
  skyr = await f('Skyr Natur', 63, 11, 4, 4, 0.2, 0.1, brand: 'Arla', serving: 150, barcode: '4000000000001');
  final berries = await f('Heidelbeeren', 57, 0.7, 14, 10, 0.3, 0, fiber: 2.4);
  final chicken = await f('Hähnchenbrustfilet', 110, 23, 0, 0, 1.5, 0.4);
  final rice = await f('Basmati-Reis, gekocht', 130, 2.7, 28, 0.1, 0.3, 0.1, fiber: 0.4);
  final broccoli = await f('Brokkoli', 34, 2.8, 4, 1.7, 0.4, 0.1, fiber: 2.6);
  final oil = await f('Olivenöl', 824, 0, 0, 0, 91.6, 13.8);
  final whey = await f('Whey Protein Vanille', 380, 75, 8, 5, 5.5, 3.2, serving: 30);
  final today0 = today();
  // 14 Tage zurück: vollständig getrackt, Gewicht sinkt langsam → gültiger Check-in.
  for (var i = 14; i >= 0; i--) {
    final d = dayKey(today0.subtract(Duration(days: i)));
    await db.addEntry(day: d, meal: Meal.breakfast, foodId: oats.id, amount: 80);
    await db.addEntry(day: d, meal: Meal.breakfast, foodId: skyr.id, amount: 250);
    await db.addEntry(day: d, meal: Meal.breakfast, foodId: berries.id, amount: 100);
    if (i > 0) {
      await db.addEntry(day: d, meal: Meal.lunch, foodId: chicken.id, amount: 200);
      await db.addEntry(day: d, meal: Meal.lunch, foodId: rice.id, amount: 300);
      await db.addEntry(day: d, meal: Meal.lunch, foodId: oil.id, amount: 10);
      await db.addEntry(day: d, meal: Meal.dinner, foodId: chicken.id, amount: 180);
      await db.addEntry(day: d, meal: Meal.dinner, foodId: broccoli.id, amount: 250);
      await db.addEntry(day: d, meal: Meal.snacks, foodId: whey.id, amount: 30);
      await db.setDayComplete(d, true);
    } else {
      await db.addEntry(day: d, meal: Meal.lunch, foodId: chicken.id, amount: 200);
      await db.addEntry(day: d, meal: Meal.lunch, foodId: rice.id, amount: 300);
      await db.addEntry(day: d, meal: Meal.snacks, foodId: whey.id, amount: 30);
    }
    final noise = [0.3, -0.2, 0.1, 0.4, -0.3, 0.0, 0.2, -0.1, 0.3, -0.4, 0.1, 0.2, -0.2, 0.0, 0.1][i];
    await db.saveWeight(d, double.parse((84.0 - (14 - i) * 0.045 + noise).toStringAsFixed(1)));
  }
  for (var i = 40; i > 14; i -= 2) {
    await db.saveWeight(
      dayKey(today0.subtract(Duration(days: i))),
      double.parse((84.9 - (40 - i) * 0.035 + ((i * 7) % 5 - 2) * 0.15).toStringAsFixed(1)),
    );
  }
}

class FakeHW implements HomeWidgetBridge {
  @override
  Future<void> publish(WidgetSnapshot s) async {}
  @override
  Future<Uri?> initialLaunch() async => null;
  @override
  Stream<Uri?> get clicks => const Stream.empty();
}

Future<void> settle(WidgetTester tester, [int n = 15]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await loadFont('Manrope', 'assets/fonts/Manrope-Variable.ttf');
    await loadFont(
      'MaterialIcons',
      // Das Flutter-SDK setzt FLUTTER_ROOT für Testprozesse.
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
  });

  Future<AppDatabase> start(WidgetTester tester, Map<String, Object> prefs) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    SharedPreferences.setMockInitialValues(prefs);
    final db = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() => seed(db));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWith((ref) => db), homeWidgetProvider.overrideWithValue(FakeHW())],
        child: const MuScaleApp(),
      ),
    );
    await settle(tester);
    return db;
  }

  Future<void> shot(WidgetTester tester, String name) =>
      expectLater(find.byType(MaterialApp), matchesGoldenFile('$out/$name.png'));

  Future<void> finish(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  }

  testWidgets('1 Tagebuch', (tester) async {
    final db = await start(tester, {'theme_mode': 'light'});
    await shot(tester, '1_tagebuch');
    await finish(tester, db);
  });

  testWidgets('2 Details', (tester) async {
    final db = await start(tester, {'theme_mode': 'light'});
    await tester.tap(find.text('Details'));
    await settle(tester, 8);
    await shot(tester, '2_details');
    await finish(tester, db);
  });

  testWidgets('3 Gewicht', (tester) async {
    final db = await start(tester, {'theme_mode': 'light'});
    await tester.tap(find.text('Gewicht').last);
    await settle(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, -150));
    await settle(tester, 6);
    await shot(tester, '3_gewicht');
    await finish(tester, db);
  });

  testWidgets('4 Menge', (tester) async {
    final db = await start(tester, {'theme_mode': 'light'});
    final context = tester.element(find.byType(TodayScreen));
    showAmountSheet(context, food: skyr, day: dayKey(today()), meal: Meal.snacks);
    await settle(tester, 8);
    await shot(tester, '4_menge');
    await finish(tester, db);
  });

  testWidgets('5 Dunkel', (tester) async {
    final db = await start(tester, {'theme_mode': 'dark', 'palette_primary': 'black', 'palette_accent': 'gold'});
    await shot(tester, '5_dunkel');
    await finish(tester, db);
  });

  testWidgets('6 Farben', (tester) async {
    final db = await start(tester, {'theme_mode': 'light'});
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => const AppearanceScreen()));
    await settle(tester, 8);
    await shot(tester, '6_farben');
    await finish(tester, db);
  });
}
