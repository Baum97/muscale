import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/energy.dart';
import '../domain/nutrients.dart';

part 'database.g.dart';

// Enums werden als Index gespeichert (auch in Sicherungen): neue Werte nur hinten anhängen, nie umsortieren.

enum Meal {
  breakfast('Frühstück'),
  lunch('Mittagessen'),
  dinner('Abendessen'),
  snacks('Snacks');

  const Meal(this.label);
  final String label;
}

enum FoodSource { openFoodFacts, custom, recipe }

/// Profil – genau eine Zeile (id = 1).
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get sex => intEnum<Sex>()();
  IntColumn get birthYear => integer()();
  RealColumn get heightCm => real()();
  IntColumn get activity => intEnum<ActivityLevel>()();
  IntColumn get goal => intEnum<Goal>()();

  /// Tempo in Prozent des Körpergewichts pro Woche.
  RealColumn get pacePercent => real()();
  RealColumn get proteinPerKg => real()();

  /// Vom Nutzer bestätigtes Kalorienziel aus dem Check-in; null = Startschätzung verwenden.
  IntColumn get calorieTargetOverride => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Lebensmittel: Zwischenspeicher von Open Food Facts und eigene Einträge. Nährwerte pro 100 g / 100 ml.
class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  BoolColumn get isLiquid => boolean().withDefault(const Constant(false))();
  RealColumn get servingSize => real().nullable()();
  IntColumn get source => intEnum<FoodSource>()();

  /// Nur Rezepte: Gewicht des fertigen Gerichts in g.
  RealColumn get recipeTotalWeight => real().nullable()();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  RealColumn get kcal => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get carbs => real().nullable()();
  RealColumn get sugar => real().nullable()();
  RealColumn get fiber => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get monoUnsaturatedFat => real().nullable()();
  RealColumn get polyUnsaturatedFat => real().nullable()();
  RealColumn get salt => real().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Zutaten eines Rezepts. Das Rezept selbst ist ein Lebensmittel (Quelle „recipe“) mit Nährwerten pro 100 g.
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer().references(Foods, #id)();
  IntColumn get foodId => integer().references(Foods, #id)();

  /// Gramm bzw. Milliliter.
  RealColumn get amount => real()();
}

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Kalendertag „2026-10-14“.
  TextColumn get day => text()();
  IntColumn get meal => intEnum<Meal>()();
  IntColumn get foodId => integer().references(Foods, #id)();

  /// Gramm bzw. Milliliter.
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Vom Nutzer als „vollständig getrackt“ abgehakte Tage.
class CompletedDays extends Table {
  TextColumn get day => text()();

  @override
  Set<Column> get primaryKey => {day};
}

/// Höchstens eine Wiegung pro Tag.
class WeightEntries extends Table {
  TextColumn get day => text()();
  RealColumn get kg => real()();

  @override
  Set<Column> get primaryKey => {day};
}

extension FoodNutrients on Food {
  Nutrients get nutrients => Nutrients(
    kcal: kcal,
    protein: protein,
    carbs: carbs,
    sugar: sugar,
    fiber: fiber,
    fat: fat,
    saturatedFat: saturatedFat,
    monoUnsaturatedFat: monoUnsaturatedFat,
    polyUnsaturatedFat: polyUnsaturatedFat,
    salt: salt,
  );
}

class Ingredient {
  const Ingredient(this.food, this.amount);
  final Food food;
  final double amount;
}

class EntryWithFood {
  const EntryWithFood(this.entry, this.food);
  final DiaryEntry entry;
  final Food food;

  Nutrients get nutrients => food.nutrients.forAmount(entry.amount);
}

@DriftDatabase(tables: [Profiles, Foods, DiaryEntries, CompletedDays, WeightEntries, RecipeIngredients])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'muscale'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(foods, foods.recipeTotalWeight);
        await m.createTable(recipeIngredients);
      }
      if (from < 3) await m.addColumn(foods, foods.isFavorite);
    },
  );

  // Profil

  Stream<Profile?> watchProfile() => select(profiles).watchSingleOrNull();

  Future<void> saveProfile(ProfilesCompanion profile) => into(profiles).insertOnConflictUpdate(profile);

  Future<void> setCalorieTargetOverride(int? kcal) =>
      update(profiles).write(ProfilesCompanion(calorieTargetOverride: Value(kcal)));

  // Lebensmittel

  Future<Food?> foodByBarcode(String barcode) =>
      (select(foods)..where((f) => f.barcode.equals(barcode))).getSingleOrNull();

  /// Legt ein Lebensmittel an oder aktualisiert es (bei gleichem Barcode).
  Future<Food> upsertFood(FoodsCompanion food) async {
    final barcode = food.barcode.present ? food.barcode.value : null;
    if (barcode != null) {
      final existing = await foodByBarcode(barcode);
      if (existing != null) {
        await (update(
          foods,
        )..where((f) => f.id.equals(existing.id))).write(food.copyWith(updatedAt: Value(DateTime.now())));
        return (await foodByBarcode(barcode))!;
      }
    }
    return into(foods).insertReturning(food);
  }

  /// Gespeicherte Lebensmittel, deren Name oder Marke den Suchtext enthält.
  Future<List<Food>> searchFoods(String query, {int limit = 30}) {
    final pattern = '%${query.trim()}%';
    return (select(foods)
          ..where((f) => f.name.like(pattern) | f.brand.like(pattern))
          ..orderBy([(f) => OrderingTerm.asc(f.name)])
          ..limit(limit))
        .get();
  }

  /// Zuletzt gegessene Lebensmittel, neueste zuerst, ohne Duplikate.
  Stream<List<Food>> watchRecentFoods({int limit = 20}) {
    final lastUse = diaryEntries.createdAt.max();
    final query = select(foods).join([innerJoin(diaryEntries, diaryEntries.foodId.equalsExp(foods.id))])
      ..groupBy([foods.id])
      ..orderBy([OrderingTerm.desc(lastUse)])
      ..limit(limit);
    return query.watch().map((rows) => [for (final r in rows) r.readTable(foods)]);
  }

  // Favoriten

  Stream<List<Food>> watchFavorites() =>
      (select(foods)
            ..where((f) => f.isFavorite.equals(true))
            ..orderBy([(f) => OrderingTerm.asc(f.name)]))
          .watch();

  Stream<bool> watchIsFavorite(int foodId) =>
      (select(foods)..where((f) => f.id.equals(foodId))).watchSingle().map((f) => f.isFavorite);

  Future<void> setFavorite(int foodId, bool favorite) =>
      (update(foods)..where((f) => f.id.equals(foodId))).write(FoodsCompanion(isFavorite: Value(favorite)));

  // Rezepte

  Stream<List<Food>> watchRecipes() =>
      (select(foods)
            ..where((f) => f.source.equalsValue(FoodSource.recipe))
            ..orderBy([(f) => OrderingTerm.asc(f.name)]))
          .watch();

  Future<List<Ingredient>> recipeIngredientsOf(int recipeId) async {
    final query = select(recipeIngredients).join([innerJoin(foods, foods.id.equalsExp(recipeIngredients.foodId))])
      ..where(recipeIngredients.recipeId.equals(recipeId))
      ..orderBy([OrderingTerm.asc(recipeIngredients.id)]);
    final rows = await query.get();
    return [for (final r in rows) Ingredient(r.readTable(foods), r.readTable(recipeIngredients).amount)];
  }

  /// Legt ein Rezept an oder überschreibt es. [totalWeight] = Gewicht des fertigen Gerichts (nach dem Kochen).
  Future<Food> saveRecipe({
    int? recipeId,
    required String name,
    required int portions,
    required double totalWeight,
    required List<Ingredient> ingredients,
  }) {
    final n = recipeNutrientsPer100([for (final i in ingredients) (i.food.nutrients, i.amount)], totalWeight);
    final row = FoodsCompanion(
      name: Value(name),
      source: const Value(FoodSource.recipe),
      isLiquid: const Value(false),
      servingSize: Value(totalWeight / portions),
      recipeTotalWeight: Value(totalWeight),
      kcal: Value(n.kcal),
      protein: Value(n.protein),
      carbs: Value(n.carbs),
      sugar: Value(n.sugar),
      fiber: Value(n.fiber),
      fat: Value(n.fat),
      saturatedFat: Value(n.saturatedFat),
      monoUnsaturatedFat: Value(n.monoUnsaturatedFat),
      polyUnsaturatedFat: Value(n.polyUnsaturatedFat),
      salt: Value(n.salt),
      updatedAt: Value(DateTime.now()),
    );
    return transaction(() async {
      final int id;
      if (recipeId == null) {
        id = await into(foods).insert(row);
      } else {
        id = recipeId;
        await (update(foods)..where((f) => f.id.equals(id))).write(row);
        await (delete(recipeIngredients)..where((r) => r.recipeId.equals(id))).go();
      }
      for (final i in ingredients) {
        await into(recipeIngredients)
            .insert(RecipeIngredientsCompanion.insert(recipeId: id, foodId: i.food.id, amount: i.amount));
      }
      return (select(foods)..where((f) => f.id.equals(id))).getSingle();
    });
  }

  // Tagebuch

  Stream<List<EntryWithFood>> watchDay(String day) {
    final query = select(diaryEntries).join([innerJoin(foods, foods.id.equalsExp(diaryEntries.foodId))])
      ..where(diaryEntries.day.equals(day))
      ..orderBy([OrderingTerm.asc(diaryEntries.createdAt)]);
    return query.watch().map(
      (rows) => [for (final r in rows) EntryWithFood(r.readTable(diaryEntries), r.readTable(foods))],
    );
  }

  /// Alle Einträge in einem Zeitraum (Tagesschlüssel, einschließlich).
  Future<List<EntryWithFood>> entriesBetween(String from, String to) async {
    final query = select(diaryEntries).join([innerJoin(foods, foods.id.equalsExp(diaryEntries.foodId))])
      ..where(diaryEntries.day.isBetweenValues(from, to));
    final rows = await query.get();
    return [for (final r in rows) EntryWithFood(r.readTable(diaryEntries), r.readTable(foods))];
  }

  Future<void> addEntry({required String day, required Meal meal, required int foodId, required double amount}) =>
      into(diaryEntries).insert(DiaryEntriesCompanion.insert(day: day, meal: meal, foodId: foodId, amount: amount));

  Future<void> deleteEntry(int id) => (delete(diaryEntries)..where((e) => e.id.equals(id))).go();

  Stream<bool> watchDayComplete(String day) =>
      (select(completedDays)..where((d) => d.day.equals(day))).watchSingleOrNull().map((d) => d != null);

  Future<void> setDayComplete(String day, bool complete) async {
    if (complete) {
      await into(completedDays).insertOnConflictUpdate(CompletedDaysCompanion.insert(day: day));
    } else {
      await (delete(completedDays)..where((d) => d.day.equals(day))).go();
    }
  }

  Stream<List<CompletedDay>> watchCompletedDays() => select(completedDays).watch();

  // Gewicht

  Stream<List<WeightEntry>> watchWeights() =>
      (select(weightEntries)..orderBy([(w) => OrderingTerm.asc(w.day)])).watch();

  Future<void> saveWeight(String day, double kg) =>
      into(weightEntries).insertOnConflictUpdate(WeightEntriesCompanion.insert(day: day, kg: kg));

  Future<void> deleteWeight(String day) => (delete(weightEntries)..where((w) => w.day.equals(day))).go();
}
