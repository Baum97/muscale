import 'package:flutter/services.dart' show appFlavor;

enum Store { fdroid, play }

/// Vertriebsweg aus dem Gradle-Flavor (`--flavor fdroid` / `--flavor play`). Ohne Flavor: F-Droid.
final store = appFlavor == 'play' ? Store.play : Store.fdroid;

/// Spendenseite für die F-Droid-Variante. Null, solange es noch keine gibt.
const String? donationUrl = null;

const sourceCodeUrl = 'https://github.com/Baum97/muscale';
const openFoodFactsUrl = 'https://world.openfoodfacts.org';
