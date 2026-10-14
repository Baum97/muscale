/// Eine Mengen-Schnellauswahl nach dem Scan.
class PortionOption {
  const PortionOption(this.label, this.amount);

  final String label;

  /// Gramm bzw. Milliliter.
  final double amount;

  @override
  bool operator ==(Object other) => other is PortionOption && other.label == label && other.amount == amount;

  @override
  int get hashCode => Object.hash(label, amount);
}

const solidAmounts = [50.0, 100.0, 150.0];
const drinkSizes = [
  PortionOption('Glas · 200 ml', 200),
  PortionOption('Tasse · 250 ml', 250),
  PortionOption('Dose · 330 ml', 330),
  PortionOption('Flasche · 500 ml', 500),
];

/// Feste Lebensmittel: 1 Portion (nur wenn bekannt), 50 g, 100 g, 150 g. Getränke: übliche Größen.
List<PortionOption> portionOptions({required bool isLiquid, double? servingSize}) {
  if (isLiquid) return drinkSizes;
  return [
    if (servingSize != null && servingSize > 0) PortionOption('1 Portion · ${_fmt(servingSize)} g', servingSize),
    for (final g in solidAmounts) PortionOption('${_fmt(g)} g', g),
  ];
}

String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
