import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/days.dart';
import '../../domain/macros.dart';
import '../../domain/nutrients.dart';
import '../../domain/targets.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets/format.dart';
import '../food/add_food.dart';
import '../info/info_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final key = dayKey(day);
    final entries = ref.watch(dayEntriesProvider(key)).value ?? const [];
    final complete = ref.watch(dayCompleteProvider(key)).value ?? false;
    final targets = ref.watch(targetsProvider);
    final totals = NutrientTotals.of(entries.map((e) => e.nutrients));
    final isToday = day == today();

    return Scaffold(
      appBar: AppBar(
        title: Text(isToday ? 'Heute' : weekdayDate(day)),
        actions: [
          IconButton(
            tooltip: 'Wissen',
            icon: const Icon(Icons.school_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoScreen())),
          ),
          IconButton(
            tooltip: 'Vorheriger Tag',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedDayProvider.notifier).shift(-1),
          ),
          IconButton(
            tooltip: 'Nächster Tag',
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday ? null : () => ref.read(selectedDayProvider.notifier).shift(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scannen'),
        onPressed: () async {
          final food = await scanAndLookup(context, ref);
          if (food != null && context.mounted) {
            await showAmountSheet(context, food: food, day: key, meal: _mealForNow());
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (targets != null) _SummaryCard(totals: totals, targets: targets),
          const SizedBox(height: 16),
          for (final meal in Meal.values)
            _MealSection(meal: meal, day: key, entries: entries.where((e) => e.entry.meal == meal).toList()),
          const SizedBox(height: 8),
          Card(
            child: CheckboxListTile(
              value: complete,
              onChanged: (v) => ref.read(databaseProvider).setDayComplete(key, v ?? false),
              title: const Text('Tag vollständig getrackt'),
              subtitle: const Text('Nur vollständige Tage zählen für deinen gemessenen Bedarf.'),
            ),
          ),
        ],
      ),
    );
  }
}

Meal _mealForNow() {
  final hour = DateTime.now().hour;
  if (hour < 11) return Meal.breakfast;
  if (hour < 15) return Meal.lunch;
  if (hour >= 17 && hour < 22) return Meal.dinner;
  return Meal.snacks;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.totals, required this.targets});
  final NutrientTotals totals;
  final Targets targets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = targets.calorieTarget - totals.kcal.round();
    final m = targets.macros;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: (totals.kcal / targets.calorieTarget).clamp(0, 1),
                        strokeWidth: 10,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                      Center(child: Text(number(totals.kcal.roundToDouble()), style: theme.textTheme.titleLarge)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ziel ${kcal(targets.calorieTarget)}', style: theme.textTheme.titleMedium),
                      Text(left >= 0 ? 'Noch ${kcal(left)}' : '${kcal(-left)} drüber'),
                      Text(
                        targets.fromCheckIn ? 'Aus deinem Check-in' : 'Startschätzung',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MacroTile(
              label: 'Eiweiß',
              color: AppColors.protein,
              value: totals.protein,
              target: m.protein,
              details: const [],
            ),
            _MacroTile(
              label: 'Kohlenhydrate',
              color: AppColors.carbs,
              value: totals.carbs,
              target: m.carbs,
              details: [
                ('Kurzkettig (Zucker)', grams(totals.sugar)),
                ('Langkettig (Stärke) ≈', grams(totals.starch)),
                ('Ballaststoffe (Richtwert ${grams(MacroTargets.fiberGuide)})', grams(totals.fiber)),
              ],
            ),
            _MacroTile(
              label: 'Fett',
              color: AppColors.fat,
              value: totals.fat,
              target: m.fat,
              details: [
                (
                  'Gesättigt (< ${grams(MacroTargets.saturatedFatLimit(targets.calorieTarget.toDouble()).roundToDouble())})',
                  grams(totals.saturatedFat),
                ),
                ('Ungesättigt ≈', grams(totals.unsaturatedFat)),
              ],
            ),
            if (totals.incomplete)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Bei manchen Lebensmitteln fehlen Angaben.', style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.color,
    required this.value,
    required this.target,
    required this.details,
  });

  final String label;
  final Color color;
  final double value;
  final double target;
  final List<(String, String)> details;

  @override
  Widget build(BuildContext context) {
    final bar = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('${number(value.roundToDouble())} / ${grams(target.roundToDouble())}'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: target <= 0 ? 0 : (value / target).clamp(0, 1),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
    if (details.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: bar);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 12, bottom: 8),
      shape: const Border(),
      title: bar,
      children: [
        for (final (name, v) in details)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(name)),
                Text(v),
              ],
            ),
          ),
      ],
    );
  }
}

class _MealSection extends ConsumerWidget {
  const _MealSection({required this.meal, required this.day, required this.entries});
  final Meal meal;
  final String day;
  final List<EntryWithFood> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sum = entries.fold<double>(0, (s, e) => s + (e.nutrients.kcal ?? 0));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(meal.label, style: Theme.of(context).textTheme.titleMedium),
            subtitle: entries.isEmpty ? null : Text(kcal(sum.round())),
            trailing: IconButton(
              tooltip: '${meal.label} hinzufügen',
              icon: const Icon(Icons.add),
              onPressed: () => showAddFoodSheet(context, day: day, meal: meal),
            ),
          ),
          for (final e in entries)
            Dismissible(
              key: ValueKey(e.entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete),
              ),
              onDismissed: (_) => ref.read(databaseProvider).deleteEntry(e.entry.id),
              child: ListTile(
                dense: true,
                title: Text(e.food.name),
                subtitle: Text('${number(e.entry.amount)} ${e.food.isLiquid ? 'ml' : 'g'}'),
                trailing: Text(kcal(e.nutrients.kcal?.round())),
              ),
            ),
        ],
      ),
    );
  }
}
