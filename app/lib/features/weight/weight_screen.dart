import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/days.dart';
import '../../domain/trend.dart';
import '../../providers.dart';
import '../../widgets/format.dart';
import 'scale_actions.dart';
import 'weight_chart.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(weightTrendProvider);
    final checkIn = ref.watch(checkInProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewicht'),
        actions: [
          if (ref.watch(scaleEnabledProvider))
            IconButton(
              tooltip: 'Von der Waage übernehmen',
              icon: const Icon(Icons.sync),
              onPressed: () => syncScale(context, ref),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _WeighInCard(),
          const SizedBox(height: 16),
          if (trend.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WeightChart(points: trend),
              ),
            ),
          const SizedBox(height: 16),
          if (checkIn != null) _CheckInCard(checkIn),
          const SizedBox(height: 16),
          if (trend.isNotEmpty) Text('Alle Wiegungen', style: Theme.of(context).textTheme.titleMedium),
          for (final p in trend.reversed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(kg(p.kg)),
              subtitle: Text(weekdayDate(p.day)),
              trailing: Text('Trend ${kg(p.trendKg)}'),
              onLongPress: () => _confirmDelete(context, ref, p.day),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, DateTime day) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wiegung löschen?'),
        content: Text(weekdayDate(day)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (ok == true) await ref.read(databaseProvider).deleteWeight(dayKey(day));
  }
}

class _WeighInCard extends ConsumerStatefulWidget {
  const _WeighInCard();

  @override
  ConsumerState<_WeighInCard> createState() => _WeighInCardState();
}

class _WeighInCardState extends ConsumerState<_WeighInCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = parseNumber(_controller.text);
    if (value == null || value < 35 || value > 300) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte ein Gewicht in kg eingeben.')));
      return;
    }
    await ref.read(databaseProvider).saveWeight(dayKey(today()), value);
    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final weighedToday = ref.watch(weightsProvider).value?.any((w) => w.day == dayKey(today())) ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weighedToday ? 'Heute gewogen – neuer Wert ersetzt den alten' : 'Heute wiegen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('Am besten morgens nach dem Aufstehen. Täglich ist ideal, jeden 2. Tag reicht.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Gewicht', suffixText: 'kg'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _save, child: const Text('Speichern')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends ConsumerWidget {
  const _CheckInCard(this.checkIn);
  final CheckIn checkIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = checkIn.evaluation;
    final r = checkIn.recommendation;
    final range = '${shortDate(e.windowStart)} – ${shortDate(e.windowEnd)}';

    final List<Widget> body;
    if (!e.isValid) {
      body = [
        Text('Noch nicht genug Daten für $range'),
        const SizedBox(height: 4),
        Text('Vollständige Tage: ${e.completeDays} von mindestens $minCompleteDays'),
        Text('Wiegungen: ${e.weighIns} von mindestens $minWeighIns'),
      ];
    } else {
      final pace = e.actualPaceKgPerWeek!;
      body = [
        Text(range, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('Ø gegessen: ${kcal(e.averageIntake!.round())}'),
        Text('Gewicht: ${signedKg(pace)} pro Woche'),
        Text('Gemessener Bedarf: ${kcal(e.measuredTdee!.round())}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        switch (r.kind) {
          RecommendationKind.onTrack => const Text('Läuft – du bist im Zielkorridor. Weiter so!'),
          RecommendationKind.insufficientData => const SizedBox.shrink(),
          RecommendationKind.lower || RecommendationKind.raise => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Für dein Wunschtempo: neues Tagesziel ${kcal(r.newTarget)} '
                '(${r.kind == RecommendationKind.lower ? 'weniger' : 'mehr'}, max. 200 kcal pro Schritt).',
              ),
              if (r.belowBmr)
                Text(
                  'Achtung: Das liegt unter deinem Grundumsatz. Überlege, das Tempo zu verringern.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.read(databaseProvider).setCalorieTargetOverride(r.newTarget),
                child: const Text('Übernehmen'),
              ),
            ],
          ),
        },
      ];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Check-in (14 Tage)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...body,
          ],
        ),
      ),
    );
  }
}
