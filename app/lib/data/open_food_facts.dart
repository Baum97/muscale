import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;

import 'database.dart';

/// Produktsuche per Barcode und Name bei Open Food Facts (Daten unter ODbL).
class OpenFoodFacts {
  OpenFoodFacts({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const userAgent = 'MuScale/0.1 (https://github.com/Baum97/muscale)';
  static const _fields =
      'code,product_name,product_name_de,brands,quantity,product_quantity_unit,serving_quantity,nutriments';

  /// Liefert das Produkt als Datenbank-Eintrag oder null, wenn es nicht bekannt ist.
  Future<FoodsCompanion?> productByBarcode(String barcode) async {
    final uri = Uri.https('world.openfoodfacts.org', '/api/v2/product/$barcode.json', {'fields': _fields});
    final response = await _client.get(uri, headers: {'User-Agent': userAgent});
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw OpenFoodFactsException('HTTP ${response.statusCode}');
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (json['status'] != 1 || json['product'] is! Map) return null;
    return parseProduct(barcode, json['product'] as Map<String, dynamic>);
  }

  /// Sucht Produkte nach Name. Liefert nur Produkte mit Barcode und Kalorienangabe.
  Future<List<FoodsCompanion>> search(String query, {int pageSize = 25}) async {
    final uri = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
      'search_terms': query,
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '$pageSize',
      'fields': _fields,
    });
    final response = await _client.get(uri, headers: {'User-Agent': userAgent});
    if (response.statusCode != 200) throw OpenFoodFactsException('HTTP ${response.statusCode}');
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final products = (json['products'] as List?) ?? const [];
    return [
      for (final p in products.whereType<Map<String, dynamic>>())
        if (_text(p['code']) case final code?)
          if (parseProduct(code, p) case final food when food.kcal.value != null) food,
    ];
  }
}

class OpenFoodFactsException implements Exception {
  OpenFoodFactsException(this.message);
  final String message;

  @override
  String toString() => 'Open Food Facts: $message';
}

/// Wandelt ein Produkt aus der Open-Food-Facts-API in einen Datenbank-Eintrag um.
FoodsCompanion parseProduct(String barcode, Map<String, dynamic> product) {
  final n = (product['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
  double? v(String key) => _number(n['${key}_100g']);

  final kcal = v('energy-kcal') ?? _kjToKcal(v('energy-kj') ?? v('energy'));
  final name = _text(product['product_name_de']) ?? _text(product['product_name']) ?? 'Unbekanntes Produkt';
  final brand = _text(product['brands'])?.split(',').first.trim();
  final serving = _number(product['serving_quantity']);

  return FoodsCompanion.insert(
    barcode: Value(barcode),
    name: name,
    brand: Value(brand),
    isLiquid: Value(isLiquidProduct(product)),
    servingSize: Value(serving != null && serving > 0 ? serving : null),
    source: FoodSource.openFoodFacts,
    kcal: Value(kcal),
    protein: Value(v('proteins')),
    carbs: Value(v('carbohydrates')),
    sugar: Value(v('sugars')),
    fiber: Value(v('fiber')),
    fat: Value(v('fat')),
    saturatedFat: Value(v('saturated-fat')),
    monoUnsaturatedFat: Value(v('monounsaturated-fat')),
    polyUnsaturatedFat: Value(v('polyunsaturated-fat')),
    salt: Value(v('salt')),
  );
}

/// Getränk, wenn die Packungsgröße in ml/cl/l angegeben ist.
bool isLiquidProduct(Map<String, dynamic> product) {
  final unit = _text(product['product_quantity_unit'])?.toLowerCase();
  if (unit != null) return unit == 'ml' || unit == 'cl' || unit == 'l';
  final quantity = _text(product['quantity'])?.toLowerCase() ?? '';
  return RegExp(r'\d\s*(ml|cl|l)\b').hasMatch(quantity);
}

double? _kjToKcal(double? kj) => kj == null ? null : kj / 4.184;

double? _number(Object? value) => switch (value) {
  num n => n.toDouble(),
  String s => double.tryParse(s.replaceAll(',', '.')),
  _ => null,
};

String? _text(Object? value) => value is String && value.trim().isNotEmpty ? value.trim() : null;
