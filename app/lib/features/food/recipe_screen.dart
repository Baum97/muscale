import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/nutrients.dart';
import '../../domain/portions.dart';
import '../../providers.dart';
import '../../widgets/format.dart';
import 'add_food.dart';

/// Rezept anlegen oder bearbeiten. Gibt das gespeicherte Rezept (als Lebensmittel) zurück.
class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key, this.recipe});

  final Food? recipe;

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _portions = TextEditingController(text: '1');
  final _cookedWeight = TextEditingController();
  List<Ingredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    if (recipe != null) {
      _name.text = recipe.name;
      _load(recipe);
    }
    for (final c in [_portions, _cookedWeight]) {
      c.addListener(() => setState(() {}));
    }
  }

  Future<void> _load(Food recipe) async {
    final ingredients = await ref.read(databaseProvider).recipeIngredientsOf(recipe.id);
    if (!mounted) return;
    setState(() {
      _ingredients = ingredients;
      final total = recipe.recipeTotalWeight;
      final serving = recipe.servingSize;
      if (total != null && serving != null && serving > 0) {
        _portions.text = (total / serving).round().toString();
        if ((total - _rawWeight).abs() > 0.5) _cookedWeight.text = number(total);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _portions.dispose();
    _cookedWeight.dispose();
    super.dispose();
  }

  double get _rawWeight => _ingredients.fold(0, (s, i) => s + i.amount);
  double get _totalWeight => parseNumber(_cookedWeight.text) ?? _rawWeight;
  int get _portionCount => int.tryParse(_portions.text.trim()) ?? 0;

  Future<void> _addIngredient() async {
    final food = await showFoodPicker(context, title: 'Zutat hinzufügen', excludeId: widget.recipe?.id);
    if (food == null || !mounted) return;
    final amount = await showIngredientAmountDialog(context, food);
    if (amount != null) setState(() => _ingredients = [..._ingredients, Ingredient(food, amount)]);
  }

  Future<void> _editIngredient(int index) async {
    final current = _ingredients[index];
    final amount = await showIngredientAmountDialog(context, current.food, initial: current.amount);
    if (amount != null) {
      setState(() => _ingredients = [..._ingredients]..[index] = Ingredient(current.food, amount));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bitte mindestens eine Zutat hinzufügen.')));
      return;
    }
    final recipe = await ref
        .read(databaseProvider)
        .saveRecipe(
          recipeId: widget.recipe?.id,
          name: _name.text.trim(),
          portions: _portionCount,
          totalWeight: _totalWeight,
          ingredients: _ingredients,
        );
    if (mounted) Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final per100 = _ingredients.isEmpty || _totalWeight <= 0
        ? null
        : recipeNutrientsPer100([for (final i in _ingredients) (i.food.nutrients, i.amount)], _totalWeight);
    final portion = per100 == null || _portionCount <= 0 ? null : per100.forAmount(_totalWeight / _portionCount);

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe == null ? 'Neues Rezept' : 'Rezept bearbeiten')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addIngredient,
        icon: const Icon(Icons.add),
        label: const Text('Zutat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (t) => (t ?? '').trim().isEmpty ? 'Bitte angeben' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _portions,
                    decoration: const InputDecoration(labelText: 'Portionen'),
                    keyboardType: TextInputType.number,
                    validator: (t) {
                      final v = int.tryParse((t ?? '').trim());
                      return v == null || v < 1 || v > 100 ? '1 bis 100' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cookedWeight,
                    decoration: InputDecoration(
                      labelText: 'Gewicht fertig',
                      suffixText: 'g',
                      hintText: _rawWeight > 0 ? number(_rawWeight) : null,
                      helperText: 'leer = Summe der Zutaten',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (t) {
                      if ((t ?? '').trim().isEmpty) return null;
                      final v = parseNumber(t!);
                      return v == null || v <= 0 ? 'Ungültig' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (portion != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pro Portion (${number(_totalWeight / _portionCount)} g)',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${kcal(portion.kcal?.round())} · Eiweiß ${grams(portion.protein)} · '
                        'KH ${grams(portion.carbs)} · Fett ${grams(portion.fat)}',
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text('Zutaten', style: theme.textTheme.titleMedium),
            if (_ingredients.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Noch keine Zutaten.')),
            for (final (index, i) in _ingredients.indexed)
              Dismissible(
                key: ObjectKey(i),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: theme.colorScheme.errorContainer,
                  child: const Icon(Icons.delete),
                ),
                onDismissed: (_) => setState(() => _ingredients = [..._ingredients]..removeAt(index)),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(i.food.name),
                  subtitle: Text('${number(i.amount)} ${i.food.isLiquid ? 'ml' : 'g'}'),
                  trailing: Text(kcal(i.food.nutrients.forAmount(i.amount).kcal?.round())),
                  onTap: () => _editIngredient(index),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Rezept speichern')),
          ],
        ),
      ),
    );
  }
}

/// Menge einer Zutat abfragen; Schnellauswahl wie beim Tagebuch.
Future<double?> showIngredientAmountDialog(BuildContext context, Food food, {double? initial}) {
  final options = portionOptions(isLiquid: food.isLiquid, servingSize: food.servingSize);
  final controller = TextEditingController(text: number(initial ?? options.first.amount));
  return showDialog<double>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final amount = parseNumber(controller.text);
        return AlertDialog(
          title: Text(food.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in options)
                    ChoiceChip(
                      label: Text(o.label),
                      selected: amount == o.amount,
                      onSelected: (_) => setState(() => controller.text = number(o.amount)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: 'Menge', suffixText: food.isLiquid ? 'ml' : 'g'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: amount == null || amount <= 0 ? null : () => Navigator.pop(context, amount),
              child: const Text('Übernehmen'),
            ),
          ],
        );
      },
    ),
  );
}

/// Liste aller Rezepte zum Bearbeiten.
class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).value ?? const [];
    void open([Food? recipe]) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeScreen(recipe: recipe)));
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Rezepte')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: open,
        icon: const Icon(Icons.add),
        label: const Text('Neues Rezept'),
      ),
      body: recipes.isEmpty
          ? const Center(child: Text('Noch keine Rezepte.'))
          : ListView(
              children: [
                for (final r in recipes)
                  ListTile(
                    title: Text(r.name),
                    subtitle: Text(
                      r.servingSize == null
                          ? '${kcal(r.kcal?.round())} / 100 g'
                          : '${kcal((r.kcal ?? 0) * r.servingSize! / 100)} pro Portion (${number(r.servingSize!)} g)',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => open(r),
                  ),
              ],
            ),
    );
  }
}
