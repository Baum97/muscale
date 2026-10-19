import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/features/legal/privacy_screen.dart';

void main() {
  final source = File(privacyAsset).readAsStringSync();

  test('Markdown wird in Überschriften, Aufzählungen und Absätze zerlegt', () {
    final blocks = markdownBlocks('# Titel\n\n## Teil\n\n- eins\n- **zwei**\n\nZeile 1\nZeile 2\n');
    expect(blocks.map((b) => b.kind), [
      BlockKind.title,
      BlockKind.heading,
      BlockKind.bullet,
      BlockKind.bullet,
      BlockKind.paragraph,
    ]);
    expect(blocks[3].text, 'zwei');
    expect(blocks[4].text, 'Zeile 1\nZeile 2');
  });

  test('Erklärung deckt alle Datenflüsse der App ab', () {
    for (final topic in ['Open Food Facts', 'Kamera', 'Health Connect', 'Erinnerungen', 'Widget', 'CSV', 'Spenden']) {
      expect(source, contains(topic), reason: topic);
    }
  });

  testWidgets('Bildschirm zeigt die Erklärung und den Entwurfs-Hinweis', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PrivacyScreen(bundle: _StringBundle(source))));
    await tester.pumpAndSettle();
    expect(find.text('Datenschutzerklärung für MuScale'), findsOneWidget);
    expect(find.textContaining('Entwurf'), findsOneWidget);
  });
}

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.text);
  final String text;

  @override
  Future<ByteData> load(String key) async => ByteData(0);

  @override
  Future<String> loadString(String key, {bool cache = true}) async => text;
}
