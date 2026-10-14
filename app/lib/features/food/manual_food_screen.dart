import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../../widgets/format.dart';

/// Eingabe eines Lebensmittels wie auf der Nährwerttabelle (pro 100 g / 100 ml). Gibt das Lebensmittel zurück.
class ManualFoodScreen extends ConsumerStatefulWidget {
  const ManualFoodScreen({super.key, this.barcode});

  final String? barcode;

  @override
  ConsumerState<ManualFoodScreen> createState() => _ManualFoodScreenState();
}

class _ManualFoodScreenState extends ConsumerState<ManualFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _serving = TextEditingController();
  final _fields = {for (final f in _NutrientField.values) f: TextEditingController()};
  bool _isLiquid = false;

  @override
  void dispose() {
    for (final c in [_name, _brand, _serving, ..._fields.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Value<double?> _v(_NutrientField f) => Value(parseNumber(_fields[f]!.text));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final food = await ref
        .read(databaseProvider)
        .upsertFood(
          FoodsCompanion.insert(
            barcode: Value(widget.barcode),
            name: _name.text.trim(),
            brand: Value(_brand.text.trim().isEmpty ? null : _brand.text.trim()),
            isLiquid: Value(_isLiquid),
            servingSize: Value(_isLiquid ? null : parseNumber(_serving.text)),
            source: FoodSource.custom,
            kcal: _v(_NutrientField.kcal),
            protein: _v(_NutrientField.protein),
            carbs: _v(_NutrientField.carbs),
            sugar: _v(_NutrientField.sugar),
            fiber: _v(_NutrientField.fiber),
            fat: _v(_NutrientField.fat),
            saturatedFat: _v(_NutrientField.saturatedFat),
            salt: _v(_NutrientField.salt),
          ),
        );
    if (mounted) Navigator.of(context).pop(food);
  }

  String? _validate(_NutrientField f, String? text) {
    final v = parseNumber(text ?? '');
    if (v == null) return f.required ? 'Bitte angeben' : null;
    if (v < 0 || (f != _NutrientField.kcal && v > 100)) return 'Ungültiger Wert';
    if (f == _NutrientField.sugar && v > (parseNumber(_fields[_NutrientField.carbs]!.text) ?? double.infinity)) {
      return 'Mehr als Kohlenhydrate';
    }
    if (f == _NutrientField.saturatedFat && v > (parseNumber(_fields[_NutrientField.fat]!.text) ?? double.infinity)) {
      return 'Mehr als Fett';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final unit = _isLiquid ? '100 ml' : '100 g';
    return Scaffold(
      appBar: AppBar(title: const Text('Lebensmittel eingeben')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.barcode != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Barcode ${widget.barcode} ist noch unbekannt. Übertrage die Nährwerttabelle.'),
              ),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (t) => (t ?? '').trim().isEmpty ? 'Bitte angeben' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Marke (optional)'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Getränk (Angaben pro 100 ml)'),
              value: _isLiquid,
              onChanged: (v) => setState(() => _isLiquid = v),
            ),
            if (!_isLiquid)
              TextFormField(
                controller: _serving,
                decoration: const InputDecoration(labelText: 'Portionsgröße (optional)', suffixText: 'g'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            const SizedBox(height: 16),
            Text('Nährwerte pro $unit', style: Theme.of(context).textTheme.titleMedium),
            for (final f in _NutrientField.values)
              Padding(
                padding: EdgeInsets.only(top: 12, left: f.indented ? 24 : 0),
                child: TextFormField(
                  controller: _fields[f],
                  decoration: InputDecoration(labelText: f.label, suffixText: f.unit),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (t) => _validate(f, t),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Speichern')),
          ],
        ),
      ),
    );
  }
}

/// Reihenfolge wie auf der EU-Nährwerttabelle.
enum _NutrientField {
  kcal('Energie', 'kcal', required: true),
  fat('Fett', 'g', required: true),
  saturatedFat('davon gesättigte Fettsäuren', 'g', indented: true),
  carbs('Kohlenhydrate', 'g', required: true),
  sugar('davon Zucker', 'g', indented: true),
  fiber('Ballaststoffe', 'g'),
  protein('Eiweiß', 'g', required: true),
  salt('Salz', 'g');

  const _NutrientField(this.label, this.unit, {this.required = false, this.indented = false});
  final String label;
  final String unit;
  final bool required;
  final bool indented;
}
