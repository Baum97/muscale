import 'package:flutter/material.dart';

/// Kurze Wissensartikel. Inhalte sind allgemeine Richtwerte, keine medizinische Beratung.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wissen')),
      body: ListView(
        children: [
          for (final a in articles)
            ListTile(
              leading: Icon(a.icon),
              title: Text(a.title),
              subtitle: Text(a.teaser),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ArticleScreen(article: a))),
            ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Allgemeine Richtwerte für gesunde Erwachsene – keine medizinische Beratung. '
              'Bei Erkrankungen, in der Schwangerschaft oder bei einer Essstörung bitte ärztlich beraten lassen.',
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (heading, text) in article.sections) ...[
            if (heading.isNotEmpty) ...[Text(heading, style: theme.textTheme.titleMedium), const SizedBox(height: 4)],
            Text(text, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class Article {
  const Article({required this.icon, required this.title, required this.teaser, required this.sections});
  final IconData icon;
  final String title;
  final String teaser;

  /// (Überschrift, Text); leere Überschrift = Fließtext.
  final List<(String, String)> sections;
}

const articles = [
  Article(
    icon: Icons.fitness_center,
    title: 'Eiweiß im Kraftsport',
    teaser: 'Wie viel, wann und warum',
    sections: [
      (
        '',
        'Eiweiß liefert die Bausteine für Muskeln. Für Kraftsportler gelten 1,6–2,2 g pro kg Körpergewicht und Tag '
            'als sinnvoller Bereich; mehr bringt für den Muskelaufbau kaum zusätzlichen Nutzen. MuScale startet mit '
            '2,0 g/kg – im Profil kannst du den Wert anpassen.',
      ),
      (
        'In der Diät',
        'Im Kaloriendefizit hilft eher das obere Ende (um 2,2 g/kg), Muskelmasse zu erhalten. Eiweiß sättigt '
            'außerdem gut.',
      ),
      (
        'Verteilung',
        'Mehrere eiweißreiche Mahlzeiten über den Tag (z. B. 3–5 × 25–40 g) sind praktischer als eine große. '
            'Entscheidend bleibt die Tagesmenge.',
      ),
      ('Energie', '1 g Eiweiß liefert etwa 4 kcal.'),
    ],
  ),
  Article(
    icon: Icons.grain,
    title: 'Zucker, Stärke, Ballaststoffe',
    teaser: 'Kurz- und langkettige Kohlenhydrate',
    sections: [
      (
        'Kurzkettig: Zucker',
        'Einfach- und Zweifachzucker wie Traubenzucker, Fruchtzucker, Haushaltszucker oder Milchzucker. Sie gehen '
            'schnell ins Blut. Auf dem Etikett steht das als „davon Zucker“. Empfehlung: freien Zucker (zugesetzt, '
            'Säfte, Honig) unter 10 % der Kalorien halten.',
      ),
      (
        'Langkettig: Stärke',
        'Lange Ketten aus Traubenzucker, z. B. in Brot, Reis, Nudeln, Kartoffeln, Haferflocken. Sie werden '
            'langsamer verdaut. Auf EU-Etiketten steht Stärke meist nicht – MuScale rechnet sie als '
            'Kohlenhydrate minus Zucker aus und markiert den Wert mit „≈“.',
      ),
      (
        'Ballaststoffe',
        'Pflanzenfasern, die kaum verdaut werden. Sie sättigen und sind gut für die Verdauung. Richtwert: '
            'mindestens 30 g pro Tag. Auf dem Etikett sind sie freiwillig – fehlt die Angabe, zeigt MuScale „k. A.“.',
      ),
      ('Energie', '1 g verdauliche Kohlenhydrate liefert etwa 4 kcal, Ballaststoffe etwa 2 kcal.'),
    ],
  ),
  Article(
    icon: Icons.water_drop_outlined,
    title: 'Fettqualität',
    teaser: 'Gesättigte und ungesättigte Fettsäuren',
    sections: [
      (
        'Gesättigte Fettsäuren',
        'Vor allem in Butter, Käse, fettem Fleisch, Kokos- und Palmfett. Empfehlung: unter 10 % der Kalorien. '
            'MuScale zeigt dir die Grenze in der Tagesansicht.',
      ),
      (
        'Ungesättigte Fettsäuren',
        'Einfach ungesättigt (z. B. Oliven-, Rapsöl, Nüsse, Avocado) und mehrfach ungesättigt (z. B. Lein-, '
            'Walnussöl, fetter Fisch – darunter Omega-3). Sie sollten den Großteil des Fetts ausmachen.',
      ),
      (
        'Auf dem Etikett',
        'Pflicht sind nur „Fett“ und „davon gesättigte Fettsäuren“. MuScale rechnet ungesättigte Fette als '
            'Fett minus gesättigte (≈). Sind einfach und mehrfach ungesättigte angegeben, nimmt MuScale die genauen Werte.',
      ),
      (
        'Wie viel Fett?',
        'Mindestens etwa 0,8 g pro kg Körpergewicht bzw. 20 % der Kalorien. 1 g Fett liefert etwa 9 kcal.',
      ),
    ],
  ),
  Article(
    icon: Icons.insights,
    title: 'Wie MuScale deinen Bedarf misst',
    teaser: 'Check-in nach 14 Tagen',
    sections: [
      (
        'Startschätzung',
        'Zu Beginn schätzt MuScale deinen Grundumsatz mit der Mifflin-St-Jeor-Formel aus Größe, Gewicht, Alter und '
            'Geschlecht und multipliziert ihn mit deinem Aktivitätsfaktor. Solche Formeln liegen oft um 10 % und mehr daneben.',
      ),
      (
        'Gemessen statt geschätzt',
        'Wenn du in 14 Tagen an mindestens 7 Tagen vollständig trackst und dich mindestens 7-mal wiegst, vergleicht '
            'MuScale deine durchschnittlichen Kalorien mit deiner Gewichtsänderung. 1 kg Körpergewicht entspricht '
            'grob 7700 kcal. Nimmst du bei 2600 kcal in 14 Tagen 0,6 kg ab, lag dein Bedarf bei etwa 2930 kcal.',
      ),
      (
        'Warum „Tag vollständig“?',
        'Halb getrackte Tage würden deinen Bedarf zu niedrig erscheinen lassen. Deshalb zählen nur Tage, die du '
            'abends abhakst.',
      ),
      (
        'Anpassungen',
        'MuScale schlägt höchstens 200 kcal Änderung pro Schritt vor und ändert dein Ziel nie ohne deine Bestätigung.',
      ),
    ],
  ),
  Article(
    icon: Icons.monitor_weight_outlined,
    title: 'Richtig wiegen',
    teaser: 'Warum die Waage schwankt',
    sections: [
      (
        '',
        'Dein Gewicht schwankt von Tag zu Tag um 1–2 kg – durch Wasser, Salz, Kohlenhydrate, Verdauung und den Zyklus. '
            'Das ist kein Fett. Deshalb zeigt MuScale einen geglätteten Trend.',
      ),
      (
        'Tipps',
        'Morgens nach dem Aufstehen und nach der Toilette wiegen, vor dem Essen und Trinken, immer mit derselben '
            'Waage. Täglich ist ideal, jeden zweiten Tag reicht.',
      ),
      (
        'Diätbeginn',
        'In der ersten Woche einer Diät fällt das Gewicht oft schnell – das ist großteils Wasser und Glykogen. '
            'Lass dich davon nicht täuschen; aussagekräftig ist der Verlauf über Wochen.',
      ),
    ],
  ),
  Article(
    icon: Icons.storage_outlined,
    title: 'Woher die Daten kommen',
    teaser: 'Open Food Facts und eigene Einträge',
    sections: [
      (
        'Open Food Facts',
        'Gescannte und gesuchte Produkte kommen aus Open Food Facts, einer freien, von Freiwilligen gepflegten '
            'Datenbank (Lizenz ODbL). Die Angaben stammen von den Etiketten und können Fehler enthalten.',
      ),
      (
        'Werte mit „≈“',
        'Stärke und ungesättigte Fette stehen meist nicht auf dem Etikett. MuScale rechnet sie aus den Pflichtangaben '
            'aus und markiert sie mit „≈“.',
      ),
      (
        'Deine Daten',
        'Alles, was du einträgst, bleibt auf deinem Gerät. Ins Internet geht nur der Barcode bzw. Suchbegriff an Open Food Facts.',
      ),
    ],
  ),
];
