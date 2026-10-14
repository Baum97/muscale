import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muscale/data/csv_export.dart';
import 'package:muscale/data/database.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('de'));
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('Tagebuch: Semikolon, Dezimalkomma, sortiert nach Tag und Mahlzeit', () async {
    final skyr = await db.upsertFood(
      FoodsCompanion.insert(
        name: 'Skyr; Natur',
        brand: const Value('Arla'),
        source: FoodSource.custom,
        kcal: const Value(63),
        protein: const Value(11),
        carbs: const Value(4),
        sugar: const Value(4),
        fat: const Value(0.2),
        saturatedFat: const Value(0.1),
      ),
    );
    await db.addEntry(day: '2026-10-02', meal: Meal.breakfast, foodId: skyr.id, amount: 150);
    await db.addEntry(day: '2026-10-01', meal: Meal.snacks, foodId: skyr.id, amount: 100);

    final csv = await diaryCsv(db);
    expect(csv, startsWith('\uFEFFDatum;Mahlzeit;Lebensmittel;'));
    final lines = csv.trimRight().split('\r\n');
    expect(lines, hasLength(3));
    expect(lines[1], '2026-10-01;Snacks;"Skyr; Natur";Arla;100;g;63;11;4;4;0;;0,2;0,1;0,1;');
    expect(lines[2], startsWith('2026-10-02;Frühstück;"Skyr; Natur";Arla;150;g;94,5;16,5;'));
  });

  test('Gewicht mit Trend', () async {
    await db.saveWeight('2026-10-01', 85);
    await db.saveWeight('2026-10-02', 84);
    final lines = (await weightCsv(db)).trimRight().split('\r\n');
    expect(lines, ['\uFEFFDatum;Gewicht (kg);Trend (kg)', '2026-10-01;85;85', '2026-10-02;84;84,9']);
  });
}
