import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers.dart';
import '../../widgets/format.dart';

/// Suche nach Name: erst gespeicherte Lebensmittel, dann Open Food Facts. Gibt das gewählte Lebensmittel zurück.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounce = Duration(milliseconds: 500);

  final _controller = TextEditingController();
  Timer? _timer;
  String _query = '';
  List<Food> _local = const [];
  List<FoodsCompanion>? _online;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => _search(text.trim()));
  }

  Future<void> _search(String query) async {
    if (query == _query) return;
    _query = query;
    if (query.length < 2) {
      setState(() {
        _local = const [];
        _online = null;
        _error = null;
      });
      return;
    }
    final local = await ref.read(databaseProvider).searchFoods(query);
    if (!mounted || query != _query) return;
    setState(() {
      _local = local;
      _online = null;
      _loading = true;
      _error = null;
    });
    try {
      final online = await ref.read(openFoodFactsProvider).search(query);
      if (!mounted || query != _query) return;
      final known = {for (final f in local) f.barcode};
      setState(() => _online = online.where((f) => !known.contains(f.barcode.value)).toList());
    } catch (_) {
      if (mounted && query == _query) setState(() => _error = 'Open Food Facts nicht erreichbar.');
    } finally {
      if (mounted && query == _query) setState(() => _loading = false);
    }
  }

  Future<void> _pickOnline(FoodsCompanion product) async {
    final food = await ref.read(databaseProvider).upsertFood(product);
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final online = _online;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Lebensmittel suchen', border: InputBorder.none),
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (t) => _search(t.trim()),
        ),
      ),
      body: ListView(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_local.isNotEmpty) ...[
            const ListTile(dense: true, title: Text('Gespeichert')),
            for (final f in _local)
              _ResultTile(
                name: f.name,
                brand: f.brand,
                kcalPer100: f.kcal,
                isLiquid: f.isLiquid,
                onTap: () => Navigator.of(context).pop(f),
              ),
          ],
          if (online != null && online.isNotEmpty) ...[
            const ListTile(dense: true, title: Text('Open Food Facts')),
            for (final f in online)
              _ResultTile(
                name: f.name.value,
                brand: f.brand.value,
                kcalPer100: f.kcal.value,
                isLiquid: f.isLiquid.value,
                onTap: () => _pickOnline(f),
              ),
          ],
          if (_error != null) ListTile(leading: const Icon(Icons.cloud_off), title: Text(_error!)),
          if (!_loading && _query.length >= 2 && _local.isEmpty && (online?.isEmpty ?? false))
            const ListTile(title: Text('Nichts gefunden.')),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.name,
    required this.brand,
    required this.kcalPer100,
    required this.isLiquid,
    required this.onTap,
  });

  final String name;
  final String? brand;
  final double? kcalPer100;
  final bool isLiquid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text([?brand, '${kcal(kcalPer100?.round())} / 100 ${isLiquid ? 'ml' : 'g'}'].join(' · ')),
      onTap: onTap,
    );
  }
}
