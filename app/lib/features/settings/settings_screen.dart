import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../providers.dart';
import '../../widgets/format.dart';
import '../onboarding/profile_form_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final targets = ref.watch(targetsProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
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
          const Divider(),
          const ListTile(title: Text('Darstellung')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Hell')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dunkel')),
              ],
              selected: {themeMode},
              onSelectionChanged: (m) => ref.read(themeModeProvider.notifier).set(m.single),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const _DonationTile(),
          const Divider(),
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
        ],
      ),
    );
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
