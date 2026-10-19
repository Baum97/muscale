import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const privacyAsset = 'assets/legal/datenschutz.md';

/// Zeigt die Datenschutzerklärung aus [privacyAsset] – dieselbe Datei, auf die der Store-Eintrag verlinkt.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, this.bundle});

  /// Für Tests austauschbar.
  final AssetBundle? bundle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datenschutz')),
      body: FutureBuilder<String>(
        future: (bundle ?? rootBundle).loadString(privacyAsset),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (text.contains('[')) const _IncompleteNotice(),
              ...markdownBlocks(text).map((b) => _Block(b)),
            ],
          );
        },
      ),
    );
  }
}

enum BlockKind { title, heading, subheading, bullet, paragraph }

class MarkdownBlock {
  const MarkdownBlock(this.kind, this.text);
  final BlockKind kind;
  final String text;
}

/// Einfacher Markdown-Leser für unsere Rechtstexte: Überschriften (#, ##, ###), Aufzählungen (-), Absätze.
/// Aufeinanderfolgende Zeilen eines Absatzes bleiben als Zeilenumbruch erhalten (z. B. die Anschrift).
List<MarkdownBlock> markdownBlocks(String source) {
  final blocks = <MarkdownBlock>[];
  final paragraph = <String>[];
  void flush() {
    if (paragraph.isNotEmpty) blocks.add(MarkdownBlock(BlockKind.paragraph, paragraph.join('\n')));
    paragraph.clear();
  }

  for (final raw in source.split('\n')) {
    final line = raw.trimRight().replaceAll('**', '');
    if (line.trim().isEmpty) {
      flush();
    } else if (line.startsWith('### ')) {
      flush();
      blocks.add(MarkdownBlock(BlockKind.subheading, line.substring(4)));
    } else if (line.startsWith('## ')) {
      flush();
      blocks.add(MarkdownBlock(BlockKind.heading, line.substring(3)));
    } else if (line.startsWith('# ')) {
      flush();
      blocks.add(MarkdownBlock(BlockKind.title, line.substring(2)));
    } else if (line.startsWith('- ')) {
      flush();
      blocks.add(MarkdownBlock(BlockKind.bullet, line.substring(2)));
    } else {
      paragraph.add(line);
    }
  }
  flush();
  return blocks;
}

class _Block extends StatelessWidget {
  const _Block(this.block);
  final MarkdownBlock block;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return switch (block.kind) {
      BlockKind.title => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(block.text, style: t.headlineSmall),
      ),
      BlockKind.heading => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(block.text, style: t.titleLarge),
      ),
      BlockKind.subheading => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(block.text, style: t.titleMedium),
      ),
      BlockKind.bullet => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ', style: t.bodyLarge),
            Expanded(child: SelectableText(block.text, style: t.bodyLarge)),
          ],
        ),
      ),
      BlockKind.paragraph => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SelectableText(block.text, style: t.bodyLarge),
      ),
    };
  }
}

/// Hinweis, solange die Angaben des Anbieters noch Platzhalter sind.
class _IncompleteNotice extends StatelessWidget {
  const _IncompleteNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Entwurf: Die Angaben zum Anbieter sind noch nicht ausgefüllt.',
          style: TextStyle(color: scheme.onErrorContainer),
        ),
      ),
    );
  }
}
