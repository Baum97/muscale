import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

/// Kamera-Scanner für Produkt-Barcodes (zxing-cpp, ohne Google-Dienste). Gibt den Barcode zurück.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _formats = Format.ean13 | Format.ean8 | Format.upca | Format.upce;
  bool _done = false;

  void _onScan(Code code) {
    final text = code.text;
    if (_done || !code.isValid || text == null || text.isEmpty) return;
    _done = true;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode scannen')),
      body: ReaderWidget(
        onScan: _onScan,
        codeFormat: _formats,
        showGallery: false,
        showToggleCamera: false,
        scanDelay: const Duration(milliseconds: 300),
      ),
    );
  }
}
