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
import '../../widgets/progress_ring.dart';
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
            color: complete ? Theme.of(context).colorScheme.secondaryContainer : null,
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

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.totals, required this.targets});
  final NutrientTotals totals;
  final Targets targets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final b = theme.brightness;
    final eaten = totals.kcal.round();
    final left = targets.calorieTarget - eaten;
    final m = targets.macros;
    final numberStyle = theme.textTheme.displaySmall?.copyWith(fontFeatures: tabularFigures, height: 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          children: [
            Row(
              children: [
                ProgressRing(
                  progress: eaten / targets.calorieTarget,
                  colors: ringColors(scheme, ref.watch(paletteProvider)),
                  size: 156,
                  strokeWidth: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(number(left.abs().toDouble()), style: numberStyle),
                      const SizedBox(height: 2),
                      Text(
                        left >= 0 ? 'kcal übrig' : 'kcal drüber',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: left >= 0 ? scheme.onSurfaceVariant : scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(label: 'Gegessen', value: kcal(eaten)),
                      const SizedBox(height: 12),
                      _Stat(label: 'Tagesziel', value: kcal(targets.calorieTarget)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          targets.fromCheckIn ? 'Aus deinem Check-in' : 'Startschätzung',
                          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _MacroGauge(
                    label: 'Eiweiß',
                    color: MacroColors.protein(b),
                    value: totals.protein,
                    target: m.protein,
                  ),
                ),
                Expanded(
                  child: _MacroGauge(
                    label: 'Kohlenhydrate',
                    color: MacroColors.carbs(b),
                    value: totals.carbs,
                    target: m.carbs,
                  ),
                ),
                Expanded(
                  child: _MacroGauge(label: 'Fett', color: MacroColors.fat(b), value: totals.fat, target: m.fat),
                ),
              ],
            ),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 12),
                title: Text('Details', style: theme.textTheme.labelLarge),
                children: [
                  _DetailGroup(
                    title: 'Kohlenhydrate',
                    color: MacroColors.carbs(b),
                    rows: [
                      ('Kurzkettig (Zucker)', grams(totals.sugar)),
                      ('Langkettig (Stärke) ≈', grams(totals.starch)),
                      ('Ballaststoffe · Richtwert ${grams(MacroTargets.fiberGuide)}', grams(totals.fiber)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailGroup(
                    title: 'Fett',
                    color: MacroColors.fat(b),
                    rows: [
                      (
                        'Gesättigt · unter '
                            '${grams(MacroTargets.saturatedFatLimit(targets.calorieTarget.toDouble()).roundToDouble())}',
                        grams(totals.saturatedFat),
                      ),
                      ('Ungesättigt ≈', grams(totals.unsaturatedFat)),
                    ],
                  ),
                  if (totals.incomplete)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Bei manchen Lebensmitteln fehlen Angaben.',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontFeatures: tabularFigures)),
      ],
    );
  }
}

/// Kleiner Ring pro Makro mit Prozent in der Mitte und „gegessen / Ziel“ darunter.
class _MacroGauge extends StatelessWidget {
  const _MacroGauge({required this.label, required this.color, required this.value, required this.target});
  final String label;
  final Color color;
  final double value;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target <= 0 ? 0.0 : value / target;
    return Column(
      children: [
        ProgressRing(
          progress: progress,
          colors: [color],
          size: 64,
          strokeWidth: 7,
          child: Text(
            '${(progress * 100).round()} %',
            style: theme.textTheme.labelMedium?.copyWith(fontFeatures: tabularFigures),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          '${number(value.roundToDouble())} / ${grams(target.roundToDouble())}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: tabularFigures,
          ),
        ),
      ],
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.color, required this.rows});
  final String title;
  final Color color;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.labelLarge),
          ],
        ),
        for (final (name, v) in rows)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Row(
              children: [
                Expanded(child: Text(name, style: theme.textTheme.bodyMedium)),
                Text(v, style: theme.textTheme.bodyMedium?.copyWith(fontFeatures: tabularFigures)),
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

  static IconData _icon(Meal meal) => switch (meal) {
    Meal.breakfast => Icons.wb_twilight_rounded,
    Meal.lunch => Icons.lunch_dining_rounded,
    Meal.dinner => Icons.dinner_dining_rounded,
    Meal.snacks => Icons.cookie_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sum = entries.fold<double>(0, (s, e) => s + (e.nutrients.kcal ?? 0));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                  child: Icon(_icon(meal), color: scheme.onSecondaryContainer, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.label, style: theme.textTheme.titleMedium),
                      Text(
                        entries.isEmpty ? 'Noch nichts eingetragen' : kcal(sum.round()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: '${meal.label} hinzufügen',
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => showAddFoodSheet(context, day: day, meal: meal),
                ),
              ],
            ),
          ),
          for (final e in entries)
            Dismissible(
              key: ValueKey(e.entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: scheme.errorContainer,
                child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
              ),
              onDismissed: (_) => ref.read(databaseProvider).deleteEntry(e.entry.id),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(e.food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${number(e.entry.amount)} ${e.food.isLiquid ? 'ml' : 'g'}'),
                trailing: Text(
                  kcal(e.nutrients.kcal?.round()),
                  style: theme.textTheme.labelLarge?.copyWith(fontFeatures: tabularFigures),
                ),
              ),
            ),
          if (entries.isNotEmpty) const SizedBox(height: 8),
        ],
      ),
    );
  }
}
