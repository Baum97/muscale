import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscale/providers.dart';
import 'package:muscale/services/reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class FakeScheduler implements ReminderScheduler {
  bool permission = true;
  final scheduled = <ReminderKind, TimeOfDay>{};

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> scheduleDaily(ReminderKind kind, TimeOfDay time) async => scheduled[kind] = time;

  @override
  Future<void> cancel(ReminderKind kind) async => scheduled.remove(kind);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nächster Termin', () {
    setUpAll(tzdata.initializeTimeZones);

    test('heute, wenn die Uhrzeit noch kommt, sonst morgen', () {
      final berlin = tz.getLocation('Europe/Berlin');
      final now = tz.TZDateTime(berlin, 2026, 10, 14, 8, 30);
      expect(nextInstance(now, const TimeOfDay(hour: 21, minute: 0)), tz.TZDateTime(berlin, 2026, 10, 14, 21));
      expect(nextInstance(now, const TimeOfDay(hour: 7, minute: 0)), tz.TZDateTime(berlin, 2026, 10, 15, 7));
    });

    test('Zeitumstellung: 7 Uhr bleibt 7 Uhr Ortszeit', () {
      final berlin = tz.getLocation('Europe/Berlin');
      final now = tz.TZDateTime(berlin, 2026, 10, 24, 22); // Umstellung in der Nacht zum 25.10.
      final next = nextInstance(now, const TimeOfDay(hour: 7, minute: 0));
      expect((next.hour, next.day), (7, 25));
    });
  });

  group('Einstellungen', () {
    late FakeScheduler scheduler;
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      scheduler = FakeScheduler();
      container = ProviderContainer(overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)]);
    });
    tearDown(() => container.dispose());

    test('Einschalten plant ein, Uhrzeit ändern plant neu, Ausschalten löscht', () async {
      final notifier = container.read(remindersProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      expect(await notifier.set(ReminderKind.weighIn, enabled: true), isTrue);
      expect(scheduler.scheduled[ReminderKind.weighIn], const TimeOfDay(hour: 7, minute: 0));

      await notifier.set(ReminderKind.weighIn, time: const TimeOfDay(hour: 6, minute: 30));
      expect(scheduler.scheduled[ReminderKind.weighIn], const TimeOfDay(hour: 6, minute: 30));

      await notifier.set(ReminderKind.weighIn, enabled: false);
      expect(scheduler.scheduled, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('reminder_weighIn_minutes'), 390);
    });

    test('Ohne Berechtigung bleibt die Erinnerung aus', () async {
      scheduler.permission = false;
      final notifier = container.read(remindersProvider.notifier);
      expect(await notifier.set(ReminderKind.closeDay, enabled: true), isFalse);
      expect(container.read(remindersProvider)[ReminderKind.closeDay]!.enabled, isFalse);
      expect(scheduler.scheduled, isEmpty);
    });

    test('Gespeicherte Erinnerungen werden beim Start neu eingeplant', () async {
      SharedPreferences.setMockInitialValues({'reminder_closeDay_enabled': true, 'reminder_closeDay_minutes': 1290});
      final fresh = ProviderContainer(overrides: [reminderSchedulerProvider.overrideWithValue(scheduler)]);
      addTearDown(fresh.dispose);
      fresh.read(remindersProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(scheduler.scheduled, {ReminderKind.closeDay: const TimeOfDay(hour: 21, minute: 30)});
    });
  });
}
