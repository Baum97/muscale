import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/days.dart';
import '../../domain/energy.dart';
import '../../domain/macros.dart';
import '../../domain/targets.dart';
import '../../providers.dart';
import '../../widgets/format.dart';

/// Profil anlegen (Onboarding) oder bearbeiten.
class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  Goal _goal = Goal.maintain;
  double _pace = 0;
  double _proteinPerKg = defaultProteinPerKg;
  Profile? _existing;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    if (profile != null && !widget.onboarding) {
      _existing = profile;
      _sex = profile.sex;
      _activity = profile.activity;
      _goal = profile.goal;
      _pace = profile.pacePercent;
      _proteinPerKg = profile.proteinPerKg;
      _age.text = (DateTime.now().year - profile.birthYear).toString();
      _height.text = number(profile.heightCm);
    }
    for (final c in [_age, _height, _weight]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? get _weightKg => widget.onboarding ? parseNumber(_weight.text) : ref.read(targetsProvider)?.weightKg;

  Targets? _preview() {
    final age = int.tryParse(_age.text.trim());
    final height = parseNumber(_height.text);
    final weight = _weightKg;
    if (age == null || height == null || weight == null) return null;
    final year = DateTime.now().year;
    return computeTargets(
      sex: _sex,
      birthYear: year - age,
      heightCm: height,
      activity: _activity,
      pacePercent: _pace,
      proteinPerKg: _proteinPerKg,
      weightKg: weight,
      currentYear: year,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final db = ref.read(databaseProvider);
    final age = int.parse(_age.text.trim());
    // Ein bestätigtes Check-in-Ziel gilt nur für das bisherige Ziel und Tempo.
    final keepOverride = _existing != null && _existing!.goal == _goal && _existing!.pacePercent == _pace;
    // Gewicht zuerst: Sobald das Profil existiert, zeigt die App das Tagebuch mit den Zielen.
    if (widget.onboarding) await db.saveWeight(dayKey(today()), parseNumber(_weight.text)!);
    await db.saveProfile(
      ProfilesCompanion.insert(
        sex: _sex,
        birthYear: DateTime.now().year - age,
        heightCm: parseNumber(_height.text)!,
        activity: _activity,
        goal: _goal,
        pacePercent: _pace,
        proteinPerKg: _proteinPerKg,
        calorieTargetOverride: Value(keepOverride ? _existing!.calorieTargetOverride : null),
      ),
    );
    if (!widget.onboarding && mounted) Navigator.of(context).pop();
  }

  String? _range(String? text, num min, num max, String unit) {
    final v = parseNumber(text ?? '');
    if (v == null) return 'Bitte angeben';
    if (v < min || v > max) return 'Zwischen $min und $max $unit';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview();
    final weight = _weightKg;
    return Scaffold(
      appBar: AppBar(title: Text(widget.onboarding ? 'Willkommen bei MuScale' : 'Profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.onboarding) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('assets/branding/logo.png', width: 88, height: 88),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.onboarding)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Aus deinen Angaben schätzen wir deinen Tagesbedarf. Nach 14 Tagen Tracking ersetzt '
                  'MuScale die Schätzung durch deinen gemessenen Bedarf. Alle Daten bleiben auf deinem Gerät.',
                ),
              ),
            SegmentedButton<Sex>(
              segments: [for (final s in Sex.values) ButtonSegment(value: s, label: Text(s.label))],
              selected: {_sex},
              onSelectionChanged: (s) => setState(() => _sex = s.single),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _age,
                    decoration: const InputDecoration(labelText: 'Alter', suffixText: 'Jahre'),
                    keyboardType: TextInputType.number,
                    validator: (t) => _range(t, 14, 100, 'Jahren'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _height,
                    decoration: const InputDecoration(labelText: 'Größe', suffixText: 'cm'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (t) => _range(t, 120, 230, 'cm'),
                  ),
                ),
              ],
            ),
            if (widget.onboarding) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _weight,
                decoration: const InputDecoration(labelText: 'Aktuelles Gewicht', suffixText: 'kg'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (t) => _range(t, 35, 300, 'kg'),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<ActivityLevel>(
              initialValue: _activity,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Aktivität'),
              items: [for (final a in ActivityLevel.values) DropdownMenuItem(value: a, child: Text(a.label))],
              onChanged: (a) => setState(() => _activity = a!),
            ),
            const SizedBox(height: 24),
            Text('Ziel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<Goal>(
              segments: [for (final g in Goal.values) ButtonSegment(value: g, label: Text(g.label))],
              selected: {_goal},
              onSelectionChanged: (g) => setState(() {
                _goal = g.single;
                _pace = _goal.defaultPacePercent;
              }),
            ),
            if (_goal != Goal.maintain) ...[
              const SizedBox(height: 8),
              Text(
                'Tempo: ${number(_pace)} % pro Woche'
                '${weight == null ? '' : ' (${signedKg(paceKgPerWeek(pacePercent: _pace, weightKg: weight))})'}',
              ),
              Slider(
                value: _pace,
                min: _goal.minPacePercent,
                max: _goal.maxPacePercent,
                divisions: ((_goal.maxPacePercent - _goal.minPacePercent) / 0.05).round(),
                onChanged: (v) => setState(() => _pace = _goal.clampPace((v * 20).round() / 20)),
              ),
            ],
            const SizedBox(height: 8),
            Text('Eiweiß: ${number(_proteinPerKg)} g pro kg Körpergewicht'),
            Slider(
              value: _proteinPerKg,
              min: 1.6,
              max: 2.2,
              divisions: 6,
              onChanged: (v) => setState(() => _proteinPerKg = (v * 10).round() / 10),
            ),
            const SizedBox(height: 8),
            if (preview != null) _PreviewCard(preview),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(widget.onboarding ? 'Los geht’s' : 'Speichern')),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard(this.t);
  final Targets t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Startschätzung', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Grundumsatz: ${kcal(t.bmr.round())}'),
            Text('Gesamtbedarf: ${kcal(roundKcal(t.estimatedTdee))}'),
            Text('Tagesziel: ${kcal(t.calorieTarget)}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Eiweiß ${grams(t.macros.protein.roundToDouble())} · '
              'Kohlenhydrate ${grams(t.macros.carbs.roundToDouble())} · '
              'Fett ${grams(t.macros.fat.roundToDouble())}',
            ),
            if (t.belowBmr) ...[
              const SizedBox(height: 8),
              Text(
                'Achtung: Das Ziel liegt unter deinem Grundumsatz. Wähle ein langsameres Tempo.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
