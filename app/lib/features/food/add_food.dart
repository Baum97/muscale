import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/portions.dart';
import '../../providers.dart';
import '../../widgets/format.dart';
import '../scan/scan_screen.dart';
import 'manual_food_screen.dart';
import 'recipe_screen.dart';
import 'search_screen.dart';

/// Einstieg „Essen hinzufügen“: Lebensmittel wählen, dann Menge.
Future<void> showAddFoodSheet(BuildContext context, {required String day, required Meal meal}) async {
  final food = await showFoodPicker(context, title: '${meal.label} hinzufügen', offerNewRecipe: true);
  if (food != null && context.mounted) await showAmountSheet(context, food: food, day: day, meal: meal);
}

/// Lebensmittel wählen: scannen, suchen, manuell eingeben, Rezepte oder „Zuletzt gegessen“.
/// [excludeId] blendet ein Lebensmittel aus (das Rezept, das gerade bearbeitet wird).
Future<Food?> showFoodPicker(
  BuildContext context, {
  required String title,
  bool offerNewRecipe = false,
  int? excludeId,
}) {
  return showModalBottomSheet<Food>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FoodPicker(title: title, offerNewRecipe: offerNewRecipe, excludeId: excludeId),
  );
}

class _FoodPicker extends ConsumerWidget {
  const _FoodPicker({required this.title, required this.offerNewRecipe, required this.excludeId});
  final String title;
  final bool offerNewRecipe;
  final int? excludeId;

  /// Führt [open] aus und schließt danach die Auswahl mit dem gewählten Lebensmittel.
  Future<void> _via(BuildContext context, Future<Food?> Function() open) async {
    final food = await open();
    if (food != null && context.mounted) Navigator.of(context).pop(food);
  }

  Future<Food?> _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push<Food>(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool keep(Food f) => f.id != excludeId;
    final recipes = (ref.watch(recipesProvider).value ?? const <Food>[]).where(keep).toList();
    final recent = (ref.watch(recentFoodsProvider).value ?? const <Food>[]).where(keep).toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => ListView(
        controller: controller,
        children: [
          ListTile(title: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Barcode scannen'),
            onTap: () => _via(context, () => scanAndLookup(context, ref)),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Suchen'),
            onTap: () => _via(context, () => _push(context, const SearchScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Manuell eingeben'),
            onTap: () => _via(context, () => _push(context, const ManualFoodScreen())),
          ),
          if (offerNewRecipe)
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Neues Rezept'),
              onTap: () => _via(context, () => _push(context, const RecipeScreen())),
            ),
          if (recipes.isNotEmpty) ...[
            const Divider(),
            const ListTile(dense: true, title: Text('Meine Rezepte')),
            for (final food in recipes) _FoodTile(food, onTap: () => Navigator.of(context).pop(food)),
          ],
          if (recent.isNotEmpty) ...[
            const Divider(),
            const ListTile(dense: true, title: Text('Zuletzt gegessen')),
            for (final food in recent) _FoodTile(food, onTap: () => Navigator.of(context).pop(food)),
          ],
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile(this.food, {required this.onTap});
  final Food food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(food.name),
      subtitle: Text([?food.brand, '${kcal(food.kcal?.round())} / 100 ${food.isLiquid ? 'ml' : 'g'}'].join(' · ')),
      onTap: onTap,
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
