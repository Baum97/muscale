import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/scale_sync.dart';
import '../../providers.dart';

/// Waage über Health Connect verbinden: prüft Installation, fragt Berechtigung an, übernimmt Messungen.
Future<void> connectScale(BuildContext context, WidgetRef ref) async {
  final scale = ref.read(scaleProvider);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final status = await scale.status();
    if (status != ScaleStatus.available) {
      if (!context.mounted) return;
      final install = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Health Connect benötigt'),
          content: Text(
            status == ScaleStatus.updateRequired
                ? 'Bitte aktualisiere Health Connect. Danach kann MuScale das Gewicht deiner Waage lesen.'
                : 'Deine Waagen-App (z. B. Withings, Garmin, Renpho, Zepp) schreibt das Gewicht in Health Connect. '
                      'MuScale liest es von dort – nur lesend.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Installieren')),
          ],
        ),
      );
      if (install == true) await scale.install();
      return;
    }
    if (!await scale.connect()) {
      messenger.showSnackBar(const SnackBar(content: Text('Ohne Berechtigung kann MuScale nichts lesen.')));
      return;
    }
    await ref.read(scaleEnabledProvider.notifier).set(true);
    final count = await scale.importInto(ref.read(databaseProvider));
    messenger.showSnackBar(
      SnackBar(content: Text('Waage verbunden. $count ${count == 1 ? 'Tag' : 'Tage'} übernommen.')),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Health Connect nicht erreichbar: $e')));
  }
}

/// Neue Messungen übernehmen, wenn die Waage verbunden ist. [quiet]: ohne Meldung (beim App-Start).
Future<void> syncScale(BuildContext context, WidgetRef ref, {bool quiet = false}) async {
  if (!ref.read(scaleEnabledProvider)) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final count = await ref.read(scaleProvider).importInto(ref.read(databaseProvider));
    if (!quiet || count > 0) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'Keine neuen Messungen.'
                : '$count ${count == 1 ? 'Wiegung' : 'Wiegungen'} von der Waage übernommen.',
          ),
        ),
      );
    }
  } catch (_) {
    if (!quiet) messenger.showSnackBar(const SnackBar(content: Text('Health Connect nicht erreichbar.')));
  }
}
