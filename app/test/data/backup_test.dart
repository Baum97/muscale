import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/data/backup.dart';
import 'package:muscale/data/database.dart';
import 'package:muscale/domain/energy.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> fill(AppDatabase db) async {
    await db.saveProfile(
      ProfilesCompanion.insert(
        sex: Sex.female,
        birthYear: 1995,
        heightCm: 168,
        activity: ActivityLevel.high,
        goal: Goal.bulk,
        pacePercent: 0.25,
        proteinPerKg: 1.8,
        calorieTargetOverride: const Value(2650),
      ),
    );
    final food = await db.upsertFood(
      FoodsCompanion.insert(
        barcode: const Value('123'),
        name: 'Skyr',
        source: FoodSource.openFoodFacts,
        isLiquid: const Value(false),
        kcal: const Value(63),
        protein: const Value(11),
      ),
    );
    await db.addEntry(day: '2026-10-14', meal: Meal.snacks, foodId: food.id, amount: 150);
    await db.setDayComplete('2026-10-14', true);
    await db.saveWeight('2026-10-14', 65.4);
  }

  test('Export und Import ergeben dieselben Daten', () async {
    await fill(source);
    await target.saveWeight('2020-01-01', 99); // wird ersetzt

    await importBackup(target, await exportBackup(source));

    final profile = (await target.select(target.profiles).getSingle());
    expect(profile.sex, Sex.female);
    expect(profile.goal, Goal.bulk);
    expect(profile.calorieTargetOverride, 2650);
    final entries = await target.watchDay('2026-10-14').first;
    expect(entries.single.food.name, 'Skyr');
    expect(entries.single.entry.meal, Meal.snacks);
    expect(entries.single.nutrients.protein, closeTo(16.5, 1e-9));
    expect(await target.watchDayComplete('2026-10-14').first, isTrue);
    expect((await target.watchWeights().first).map((w) => (w.day, w.kg)), [('2026-10-14', 65.4)]);
  });

  test('Fremde Datei wird abgelehnt, Daten bleiben unverändert', () async {
    await fill(target);
    await expectLater(importBackup(target, '{"hello": 1}'), throwsA(isA<BackupException>()));
    await expectLater(importBackup(target, 'kein json'), throwsA(isA<BackupException>()));
    expect(await target.watchWeights().first, hasLength(1));
  });

  test('Sicherung aus neuerer Version wird abgelehnt', () async {
    await expectLater(
      importBackup(target, '{"format": "$backupFormat", "version": ${backupVersion + 1}}'),
      throwsA(isA<BackupException>().having((e) => e.message, 'message', contains('neueren'))),
    );
  });
}
