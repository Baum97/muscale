import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../data/backup.dart';
import '../../data/csv_export.dart';
import '../../data/database.dart';
import '../../domain/days.dart';
import '../../providers.dart';
import '../../services/reminders.dart';
import '../../widgets/format.dart';
import '../food/recipe_screen.dart';
import '../info/info_screen.dart';
import '../onboarding/profile_form_screen.dart';
import '../weight/scale_actions.dart';
import 'appearance_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final targets = ref.watch(targetsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final palette = ref.watch(paletteProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _Section('Du', [
            if (profile != null)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profil und Ziel'),
                subtitle: Text(
                  [profile.goal.label, if (targets != null) '${kcal(targets.calorieTarget)} pro Tag'].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileFormScreen())),
              ),
            if (profile?.calorieTargetOverride != null)
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Zurück zur Startschätzung'),
                subtitle: const Text('Verwirft das Tagesziel aus dem Check-in.'),
                onTap: () => ref.read(databaseProvider).setCalorieTargetOverride(null),
              ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Meine Rezepte'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipesScreen())),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.monitor_weight_outlined),
              title: const Text('Waage (Health Connect)'),
              subtitle: const Text('Gewicht aus deiner Waagen-App'),
              value: ref.watch(scaleEnabledProvider),
              onChanged: (on) => on ? connectScale(context, ref) : ref.read(scaleEnabledProvider.notifier).set(false),
            ),
          ]),
          _Section('Erinnerungen', [for (final kind in ReminderKind.values) _ReminderTile(kind)]),
          _Section('App', [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Darstellung'),
              subtitle: Text(
                '${palette.primary.label} · ${palette.accent.label} · ${switch (themeMode) {
                  ThemeMode.light => 'Hell',
                  ThemeMode.dark => 'Dunkel',
                  ThemeMode.system => 'System',
                }}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppearanceScreen())),
            ),
            const _DonationTile(),
          ]),
          _Section('Datensicherung', [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Daten exportieren'),
              subtitle: const Text('Speichert alle Daten als Datei, z. B. für ein neues Handy.'),
              onTap: () => _export(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Tagebuch als CSV'),
              subtitle: const Text('Für Excel oder LibreOffice'),
              onTap: () => _exportCsv(context, ref, 'tagebuch', diaryCsv),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Gewicht als CSV'),
              onTap: () => _exportCsv(context, ref, 'gewicht', weightCsv),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Daten importieren'),
              subtitle: const Text('Ersetzt alle Daten auf diesem Gerät durch eine Sicherung.'),
              onTap: () => _import(context, ref),
            ),
          ]),
          _Section('Info', [
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Wissen'),
              subtitle: const Text('Eiweiß, Zucker vs. Stärke, Fettqualität, Wiegen'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Quellcode (GPL-3.0)'),
              subtitle: const Text(sourceCodeUrl),
              onTap: () => launchUrl(Uri.parse(sourceCodeUrl), mode: LaunchMode.externalApplication),
            ),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Produktdaten: Open Food Facts'),
              subtitle: const Text('Freie Datenbank unter der Open Database License (ODbL)'),
              onTap: () => launchUrl(Uri.parse(openFoodFactsUrl), mode: LaunchMode.externalApplication),
            ),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Datenschutz'),
              subtitle: Text(
                'Alle Daten bleiben auf diesem Gerät. Ins Internet geht nur der gescannte Barcode '
                '(an Open Food Facts). Kein Konto, kein Tracking, keine Werbung.',
              ),
            ),
            const AboutListTile(
              icon: Icon(Icons.info_outline),
              applicationName: 'MuScale',
              applicationLegalese: 'GPL-3.0 · Kommerzielle Lizenz auf Anfrage',
            ),
          ]),
        ],
      ),
    );
  }
}

Future<void> _export(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final json = await exportBackup(ref.read(databaseProvider));
    final saved = await FilePicker.saveFile(
      fileName: 'muscale-${dayKey(today())}.json',
      bytes: utf8.encode(json),
      mimeType: 'application/json',
    );
    if (saved != null) messenger.showSnackBar(const SnackBar(content: Text('Sicherung gespeichert.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
  }
}

Future<void> _exportCsv(
  BuildContext context,
  WidgetRef ref,
  String name,
  Future<String> Function(AppDatabase) build,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final csv = await build(ref.read(databaseProvider));
    final saved = await FilePicker.saveFile(
      fileName: 'muscale-$name-${dayKey(today())}.csv',
      bytes: utf8.encode(csv),
      mimeType: 'text/csv',
    );
    if (saved != null) messenger.showSnackBar(const SnackBar(content: Text('CSV gespeichert.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export fehlgeschlagen: $e')));
  }
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Daten importieren?'),
      content: const Text('Alle Daten auf diesem Gerät werden durch die Sicherung ersetzt.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Auswählen')),
      ],
    ),
  );
  if (ok != true) return;
  try {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
    if (file == null) return;
    await importBackup(ref.read(databaseProvider), utf8.decode(await file.readAsBytes()));
    messenger.showSnackBar(const SnackBar(content: Text('Sicherung wiederhergestellt.')));
  } on BackupException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Import fehlgeschlagen: $e')));
  }
}

/// F-Droid: Link zur Spendenseite · Google Play: Trinkgeld über Play Billing (folgt).
class _DonationTile extends StatelessWidget {
  const _DonationTile();

  @override
  Widget build(BuildContext context) {
    const title = Text('MuScale unterstützen');
    switch (store) {
      case Store.fdroid:
        final url = donationUrl;
        return ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: title,
          subtitle: Text(url == null ? 'Spendenmöglichkeit folgt.' : 'MuScale ist kostenlos und lebt von Spenden.'),
          onTap: url == null ? null : () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        );
      case Store.play:
        return const ListTile(
          leading: Icon(Icons.favorite_outline),
          title: title,
          subtitle: Text('Trinkgeld über Google Play folgt.'),
        );
    }
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile(this.kind);
  final ReminderKind kind;

  Future<void> _set(BuildContext context, WidgetRef ref, {bool? enabled, TimeOfDay? time}) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(remindersProvider.notifier).set(kind, enabled: enabled, time: time);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Bitte erlaube Benachrichtigungen in den Android-Einstellungen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(remindersProvider)[kind]!;
    return SwitchListTile(
      secondary: Icon(kind == ReminderKind.weighIn ? Icons.alarm : Icons.task_alt),
      title: Text(kind.title),
      subtitle: InkWell(
        onTap: () async {
          final time = await showTimePicker(context: context, initialTime: setting.time);
          if (time != null && context.mounted) await _set(context, ref, time: time);
        },
        child: Text('täglich um ${setting.time.format(context)} Uhr · ändern'),
      ),
      value: setting.enabled,
      onChanged: (on) => _set(context, ref, enabled: on),
    );
  }
}

/// Abschnitt: Überschrift in der Hauptfarbe, Einträge gesammelt in einer Karte.
class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(title, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
