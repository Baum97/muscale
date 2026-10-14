import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  FoodsCompanion oats({double kcal = 372}) => FoodsCompanion.insert(
    barcode: const Value('4000540000108'),
    name: 'Haferflocken',
    source: FoodSource.openFoodFacts,
    kcal: Value(kcal),
    protein: const Value(13.5),
  );

  test('Gleicher Barcode aktualisiert statt doppelt anzulegen', () async {
    final first = await db.upsertFood(oats());
    final second = await db.upsertFood(oats(kcal: 370));
    expect(second.id, first.id);
    expect(second.kcal, 370);
    expect(await db.select(db.foods).get(), hasLength(1));
  });

  test('Tagebuch liefert Einträge mit Nährwerten für die Menge', () async {
    final food = await db.upsertFood(oats());
    await db.addEntry(day: '2026-10-14', meal: Meal.breakfast, foodId: food.id, amount: 50);
    await db.addEntry(day: '2026-10-15', meal: Meal.breakfast, foodId: food.id, amount: 80);

    final entries = await db.watchDay('2026-10-14').first;
    expect(entries, hasLength(1));
    expect(entries.single.nutrients.kcal, 186);
    expect(await db.entriesBetween('2026-10-01', '2026-10-31'), hasLength(2));
  });

  test('Tag abhaken und wieder lösen', () async {
    await db.setDayComplete('2026-10-14', true);
    expect(await db.watchDayComplete('2026-10-14').first, isTrue);
    await db.setDayComplete('2026-10-14', false);
    expect(await db.watchDayComplete('2026-10-14').first, isFalse);
  });

  test('Eine Wiegung pro Tag – die neue ersetzt die alte', () async {
    await db.saveWeight('2026-10-14', 85.2);
    await db.saveWeight('2026-10-14', 84.9);
    final weights = await db.watchWeights().first;
    expect(weights.single.kg, 84.9);
  });

  test('Suche in gespeicherten Lebensmitteln nach Name und Marke', () async {
    await db.upsertFood(oats());
    await db.upsertFood(
      FoodsCompanion.insert(name: 'Skyr Natur', brand: const Value('Arla'), source: FoodSource.custom),
    );
    expect((await db.searchFoods('hafer')).map((f) => f.name), ['Haferflocken']);
    expect((await db.searchFoods('arla')).map((f) => f.name), ['Skyr Natur']);
    expect(await db.searchFoods('pizza'), isEmpty);
  });
}
