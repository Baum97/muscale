import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'settings/settings_screen.dart';
import 'today/today_screen.dart';
import 'weight/scale_actions.dart';
import 'weight/weight_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Waage: neue Messungen beim Start (sobald die Einstellung geladen ist) und beim Zurückkehren in die App.
    ref.listenManual(scaleEnabledProvider, (was, enabled) {
      if (enabled && was == false) syncScale(context, ref, quiet: true);
    });
    _lifecycle = AppLifecycleListener(onResume: () => syncScale(context, ref, quiet: true));
    // Erinnerungen laden und neu einplanen.
    ref.read(remindersProvider);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: const [TodayScreen(), WeightScreen(), SettingsScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Tagebuch',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_weight_outlined),
            selectedIcon: Icon(Icons.monitor_weight),
            label: 'Gewicht',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
