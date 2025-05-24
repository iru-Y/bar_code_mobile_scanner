import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const BarcodeApp());

class BarcodeApp extends StatelessWidget {
  const BarcodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitor de Códigos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BarcodeScannerPage(),
    );
  }
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final TextEditingController _countController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  int? desiredCount;
  String? lastScannedCode;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _countController.addListener(() {
      final v = int.tryParse(_countController.text);
      setState(() => desiredCount = (v != null && v > 0) ? v : null);
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> sendBarcode(String barcode) async {
    final url = Uri.parse('http://192.168.1.143:5000/add_barcode');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'barcode': barcode}),
      );
      final msg = resp.statusCode == 201
          ? 'Enviado com sucesso!'
          : 'Erro: ${resp.body}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar: $e')),
      );
    }
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (desiredCount == null) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw == lastScannedCode) return;

    lastScannedCode = raw;
    setState(() => isSending = true);

    for (int i = 0; i < desiredCount!; i++) {
      await sendBarcode(raw);
    }

    setState(() => isSending = false);

    _countController.clear();

    Future.delayed(const Duration(seconds: 1), () {
      lastScannedCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner de Código de Barras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantas vezes enviar o mesmo código?',
                border: OutlineInputBorder(),
                hintText: 'Digite um número inteiro',
              ),
            ),
          ),
          if (isSending) const LinearProgressIndicator(),
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: onDetect,
            ),
          ),
        ],
      ),
    );
  }
}
