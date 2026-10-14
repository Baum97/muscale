import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum ReminderKind {
  weighIn(1, 'Wiegen', 'Guten Morgen! Zeit fürs Wiegen – am besten vor dem Frühstück.', TimeOfDay(hour: 7, minute: 0)),
  closeDay(
    2,
    'Tag abschließen',
    'Alles eingetragen? Dann hake den Tag als vollständig ab.',
    TimeOfDay(hour: 21, minute: 0),
  );

  const ReminderKind(this.id, this.title, this.body, this.defaultTime);
  final int id;
  final String title;
  final String body;
  final TimeOfDay defaultTime;
}

/// Plant tägliche Erinnerungen. Als Schnittstelle, damit Tests ohne Plattform auskommen.
abstract class ReminderScheduler {
  /// Fragt die Berechtigung für Benachrichtigungen an (Android 13+). True, wenn erlaubt.
  Future<bool> requestPermission();
  Future<void> scheduleDaily(ReminderKind kind, TimeOfDay time);
  Future<void> cancel(ReminderKind kind);
}

/// Lokale Benachrichtigungen, ohne Firebase. Ungefähre Uhrzeit (Android darf um einige Minuten verschieben),
/// dafür keine Sonderberechtigung für exakte Wecker nötig.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= () async {
    tzdata.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
  }();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Erinnerungen',
      channelDescription: 'Erinnerungen ans Wiegen und Tag abschließen',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> scheduleDaily(ReminderKind kind, TimeOfDay time) async {
    await _init();
    await _plugin.zonedSchedule(
      id: kind.id,
      title: kind.title,
      body: kind.body,
      scheduledDate: nextInstance(tz.TZDateTime.now(tz.local), time),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel(ReminderKind kind) async {
    await _init();
    await _plugin.cancel(id: kind.id);
  }
}

/// Nächster Zeitpunkt mit dieser Uhrzeit: heute, wenn noch nicht vorbei, sonst morgen.
tz.TZDateTime nextInstance(tz.TZDateTime now, TimeOfDay time) {
  var next = tz.TZDateTime(now.location, now.year, now.month, now.day, time.hour, time.minute);
  if (!next.isAfter(now)) {
    next = tz.TZDateTime(now.location, now.year, now.month, now.day + 1, time.hour, time.minute);
  }
  return next;
}
