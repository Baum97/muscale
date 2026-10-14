import 'package:intl/intl.dart';

final _oneDecimal = NumberFormat('#,##0.#', 'de');
final _noDecimal = NumberFormat('#,##0', 'de');

/// „12,5 g“, „k. A.“ bei fehlendem Wert.
String grams(double? g) => g == null ? 'k. A.' : '${_oneDecimal.format(g)} g';

String kcal(num? v) => v == null ? 'k. A.' : '${_noDecimal.format(v)} kcal';

String kg(double v) => '${NumberFormat('0.0', 'de').format(v)} kg';

String signedKg(double v) => '${v > 0 ? '+' : ''}${NumberFormat('0.0#', 'de').format(v)} kg';

String number(double v) => _oneDecimal.format(v);

/// Liest „12,5“ oder „12.5“.
double? parseNumber(String text) {
  final t = text.trim().replaceAll(',', '.');
  return t.isEmpty ? null : double.tryParse(t);
}

String weekdayDate(DateTime day) => DateFormat('EEEE, d. MMMM', 'de').format(day);

String shortDate(DateTime day) => DateFormat('d. MMM', 'de').format(day);
