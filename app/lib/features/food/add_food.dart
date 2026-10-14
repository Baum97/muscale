import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/portions.dart';
import '../../providers.dart';
import '../../widgets/format.dart';
import '../scan/scan_screen.dart';
import 'manual_food_screen.dart';

/// Einstieg „Essen hinzufügen“: Scannen, manuell eingeben oder aus „Zuletzt gegessen“.
Future<void> showAddFoodSheet(BuildContext context, {required String day, required Meal meal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddFoodSheet(day: day, meal: meal),
  );
}

class _AddFoodSheet extends ConsumerWidget {
  const _AddFoodSheet({required this.day, required this.meal});
  final String day;
  final Meal meal;

  Future<void> _continueWith(BuildContext context, Food? food) async {
    if (food == null || !context.mounted) return;
    final navigator = Navigator.of(context);
    await showAmountSheet(context, food: food, day: day, meal: meal);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentFoodsProvider).value ?? const [];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          ListTile(title: Text('${meal.label} hinzufügen', style: Theme.of(context).textTheme.titleLarge)),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Barcode scannen'),
            onTap: () async {
              final food = await scanAndLookup(context, ref);
              if (context.mounted) await _continueWith(context, food);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Manuell eingeben'),
            onTap: () async {
              final food = await Navigator.of(context)
                  .push<Food>(MaterialPageRoute(builder: (_) => const ManualFoodScreen()));
              if (context.mounted) await _continueWith(context, food);
            },
          ),
          if (recent.isNotEmpty) ...[
            const Divider(),
            const ListTile(dense: true, title: Text('Zuletzt gegessen')),
            for (final food in recent)
              ListTile(
                title: Text(food.name),
                subtitle: Text(
                  [?food.brand, '${kcal(food.kcal?.round())} / 100 ${food.isLiquid ? 'ml' : 'g'}'].join(' · '),
                ),
                onTap: () => _continueWith(context, food),
              ),
          ],
        ],
      ),
    );
  }
}

/// Scannt einen Barcode und sucht das Produkt: erst lokal, dann bei Open Food Facts, sonst manuelle Eingabe.
Future<Food?> scanAndLookup(BuildContext context, WidgetRef ref) async {
  final barcode = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const ScanScreen()));
  if (barcode == null || !context.mounted) return null;

  final db = ref.read(databaseProvider);
  final cached = await db.foodByBarcode(barcode);
  if (cached != null) return cached;

  try {
    final product = await ref.read(openFoodFactsProvider).productByBarcode(barcode);
    if (product != null) return await db.upsertFood(product);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Keine Verbindung zu Open Food Facts. Bitte manuell eingeben.')));
    }
  }
  if (!context.mounted) return null;
  return Navigator.of(context).push<Food>(MaterialPageRoute(builder: (_) => ManualFoodScreen(barcode: barcode)));
}

/// Mengenauswahl: Schnellauswahl (Portion, 50/100/150 g bzw. Getränkegrößen) oder eigene Menge.
Future<void> showAmountSheet(BuildContext context, {required Food food, required String day, required Meal meal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AmountSheet(food: food, day: day, meal: meal),
  );
}

class _AmountSheet extends ConsumerStatefulWidget {
  const _AmountSheet({required this.food, required this.day, required this.meal});
  final Food food;
  final String day;
  final Meal meal;

  @override
  ConsumerState<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends ConsumerState<_AmountSheet> {
  late final List<PortionOption> _options = portionOptions(
    isLiquid: widget.food.isLiquid,
    servingSize: widget.food.servingSize,
  );
  late final _amount = TextEditingController(text: number(_options.first.amount));
  late Meal _meal = widget.meal;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save(double amount) async {
    await ref.read(databaseProvider).addEntry(day: widget.day, meal: _meal, foodId: widget.food.id, amount: amount);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final unit = food.isLiquid ? 'ml' : 'g';
    final amount = parseNumber(_amount.text);
    final n = amount == null ? null : food.nutrients.forAmount(amount);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(food.name, style: Theme.of(context).textTheme.titleLarge),
          if (food.brand != null) Text(food.brand!),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in _options)
                ChoiceChip(
                  label: Text(o.label),
                  selected: amount == o.amount,
                  onSelected: (_) => _amount.text = number(o.amount),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            decoration: InputDecoration(labelText: 'Menge', suffixText: unit),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Meal>(
            initialValue: _meal,
            decoration: const InputDecoration(labelText: 'Mahlzeit'),
            items: [for (final m in Meal.values) DropdownMenuItem(value: m, child: Text(m.label))],
            onChanged: (m) => setState(() => _meal = m!),
          ),
          const SizedBox(height: 12),
          if (n != null)
            Text('${kcal(n.kcal?.round())} · Eiweiß ${grams(n.protein)} · KH ${grams(n.carbs)} · Fett ${grams(n.fat)}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: amount == null || amount <= 0 ? null : () => _save(amount),
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
}
