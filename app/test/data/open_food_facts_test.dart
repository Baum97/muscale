import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muscale/data/database.dart';
import 'package:muscale/data/open_food_facts.dart';

void main() {
  test('Produkt wird mit allen Nährwerten übernommen', () async {
    late http.Request request;
    final client = MockClient((r) async {
      request = r;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Haferflocken',
              'product_name_de': 'Zarte Haferflocken',
              'brands': 'Kölln, Peter Kölln',
              'quantity': '500 g',
              'product_quantity_unit': 'g',
              'serving_quantity': '40',
              'nutriments': {
                'energy-kcal_100g': 372,
                'proteins_100g': 13.5,
                'carbohydrates_100g': 58.7,
                'sugars_100g': 0.7,
                'fiber_100g': 10,
                'fat_100g': 7,
                'saturated-fat_100g': 1.3,
                'salt_100g': '0,01',
              },
            },
          }),
        ),
        200,
      );
    });

    final food = (await OpenFoodFacts(client: client).productByBarcode('4000540000108'))!;
    expect(request.headers['User-Agent'], startsWith('MuScale/'));
    expect(food.name.value, 'Zarte Haferflocken');
    expect(food.brand.value, 'Kölln');
    expect(food.isLiquid.value, isFalse);
    expect(food.servingSize.value, 40);
    expect(food.kcal.value, 372);
    expect(food.sugar.value, 0.7);
    expect(food.saturatedFat.value, 1.3);
    expect(food.monoUnsaturatedFat.value, isNull);
    expect(food.salt.value, 0.01);
    expect(food.source.value, FoodSource.openFoodFacts);
  });

  test('Unbekanntes Produkt → null', () async {
    final client = MockClient((_) async => http.Response(jsonEncode({'status': 0}), 200));
    expect(await OpenFoodFacts(client: client).productByBarcode('123'), isNull);
  });

  test('Kalorien werden aus kJ berechnet, wenn kcal fehlt', () {
    final food = parseProduct('1', {
      'product_name': 'X',
      'nutriments': {'energy-kj_100g': 418.4},
    });
    expect(food.kcal.value, closeTo(100, 1e-9));
  });

  group('Getränk erkennen', () {
    test('per Einheit', () => expect(isLiquidProduct({'product_quantity_unit': 'ml'}), isTrue));
    test('per Packungsgröße', () => expect(isLiquidProduct({'quantity': '1,5 l'}), isTrue));
    test('fest', () => expect(isLiquidProduct({'quantity': '250 g'}), isFalse));
  });

  test('Suche liefert nur Produkte mit Barcode und Kalorien', () async {
    late Uri uri;
    final client = MockClient((r) async {
      uri = r.url;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'products': [
              {
                'code': '111',
                'product_name': 'Skyr',
                'nutriments': {'energy-kcal_100g': 63, 'proteins_100g': 11},
              },
              {'code': '222', 'product_name': 'Ohne Nährwerte'},
              {
                'product_name': 'Ohne Barcode',
                'nutriments': {'energy-kcal_100g': 100},
              },
            ],
          }),
        ),
        200,
      );
    });
    final results = await OpenFoodFacts(client: client).search('skyr');
    expect(uri.queryParameters['search_terms'], 'skyr');
    expect(results.map((f) => f.name.value), ['Skyr']);
    expect(results.single.barcode.value, '111');
  });
}
