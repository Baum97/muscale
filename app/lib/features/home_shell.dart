import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/days.dart';
import '../providers.dart';
import '../services/home_widget_sync.dart';
import 'food/add_food.dart';
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
  StreamSubscription<Uri?>? _widgetClicks;

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

    // Homescreen-Widget: Werte bei jeder Änderung übergeben, Scan-Knopf auswerten.
    final widget = ref.read(homeWidgetProvider);
    ref.listenManual(widgetSnapshotProvider, (previous, next) {
      if (next != null && next != previous) widget.publish(next).catchError((_) {});
    }, fireImmediately: true);
    widget.initialLaunch().then(_onWidgetLink, onError: (_) {});
    _widgetClicks = widget.clicks.listen(_onWidgetLink, onError: (_) {});
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _widgetClicks?.cancel();
    super.dispose();
  }

  /// Scan-Knopf im Widget: Tagebuch von heute zeigen und direkt den Scanner öffnen.
  Future<void> _onWidgetLink(Uri? uri) async {
    if (!mounted || uri == null) return;
    setState(() => _index = 0);
    ref.read(selectedDayProvider.notifier).showToday();
    if (!isScanLink(uri)) return;
    final food = await scanAndLookup(context, ref);
    if (food != null && mounted) {
      await showAmountSheet(context, food: food, day: dayKey(today()), meal: mealForNow());
    }
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
