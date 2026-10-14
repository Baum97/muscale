import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home_shell.dart';
import 'features/onboarding/profile_form_screen.dart';
import 'providers.dart';
import 'theme.dart';

class MuScaleApp extends ConsumerWidget {
  const MuScaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MuScale',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: const Locale('de'),
      supportedLocales: const [Locale('de')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _StartGate(),
    );
  }
}

/// Ohne Profil → Onboarding, sonst die App.
class _StartGate extends ConsumerWidget {
  const _StartGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(profileProvider)
        .when(
          data: (profile) => profile == null ? const ProfileFormScreen(onboarding: true) : const HomeShell(),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Datenbank konnte nicht geöffnet werden.\n$e'))),
        );
  }
}
