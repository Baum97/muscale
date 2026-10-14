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

  test('Rezept speichern, bearbeiten und Zutaten laden', () async {
    final oatsFood = await db.upsertFood(oats());
    final milk = await db.upsertFood(
      FoodsCompanion.insert(
        name: 'Milch',
        source: FoodSource.custom,
        isLiquid: const Value(true),
        kcal: const Value(64),
      ),
    );
    final recipe = await db.saveRecipe(
      name: 'Porridge',
      portions: 2,
      totalWeight: 400,
      ingredients: [Ingredient(oatsFood, 100), Ingredient(milk, 300)],
    );
    expect(recipe.source, FoodSource.recipe);
    expect(recipe.servingSize, 200);
    expect(recipe.recipeTotalWeight, 400);
    expect(recipe.kcal, closeTo((372 + 192) / 4, 1e-9));

    final edited = await db.saveRecipe(
      recipeId: recipe.id,
      name: 'Porridge',
      portions: 1,
      totalWeight: 100,
      ingredients: [Ingredient(oatsFood, 100)],
    );
    expect(edited.id, recipe.id);
    expect(edited.kcal, 372);
    expect((await db.recipeIngredientsOf(recipe.id)).map((i) => (i.food.name, i.amount)), [('Haferflocken', 100.0)]);
    expect(await db.watchRecipes().first, hasLength(1));
  });

  test('Migration von Version 1: Rezept-Spalte und -Tabelle werden angelegt', () async {
    final v1 = NativeDatabase.memory(
      setup: (raw) {
        raw.execute(
          'CREATE TABLE foods (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, barcode TEXT NULL UNIQUE, '
          'name TEXT NOT NULL, brand TEXT NULL, is_liquid INTEGER NOT NULL DEFAULT 0, serving_size REAL NULL, '
          'source INTEGER NOT NULL, kcal REAL NULL, protein REAL NULL, carbs REAL NULL, sugar REAL NULL, '
          'fiber REAL NULL, fat REAL NULL, saturated_fat REAL NULL, mono_unsaturated_fat REAL NULL, '
          'poly_unsaturated_fat REAL NULL, salt REAL NULL, updated_at INTEGER NOT NULL DEFAULT 0)',
        );
        raw.execute("INSERT INTO foods (name, source, kcal) VALUES ('Alt', 1, 100)");
        raw.execute('PRAGMA user_version = 1');
      },
    );
    final migrated = AppDatabase(v1); // Version 1 → aktuelle Version
    addTearDown(migrated.close);
    final old = (await migrated.select(migrated.foods).get()).single;
    expect(old.name, 'Alt');
    final recipe = await migrated.saveRecipe(
      name: 'Neu',
      portions: 1,
      totalWeight: 100,
      ingredients: [Ingredient(old, 100)],
    );
    expect(recipe.kcal, 100);
  });

  test('Favoriten markieren und wieder entfernen', () async {
    final food = await db.upsertFood(oats());
    expect(await db.watchFavorites().first, isEmpty);
    await db.setFavorite(food.id, true);
    expect((await db.watchFavorites().first).single.name, 'Haferflocken');
    expect(await db.watchIsFavorite(food.id).first, isTrue);
    await db.setFavorite(food.id, false);
    expect(await db.watchFavorites().first, isEmpty);
  });
}
