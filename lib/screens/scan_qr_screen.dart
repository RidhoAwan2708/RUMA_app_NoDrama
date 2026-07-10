import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/firestore_provider.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _hasScanned = true;

    final raw = barcode!.rawValue!;
    final qrData = raw.startsWith('RUMA:') ? raw.substring(5) : raw;

    final provider = context.read<FirestoreProvider>();
    final room = provider.roomById(qrData) ?? provider.roomByQrData(raw);

    if (room != null) {
      Navigator.of(context)
          .pushReplacementNamed('/room-detail', arguments: room);
    } else {
      _hasScanned = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ruangan tidak ditemukan: $raw'),
          backgroundColor: RumaColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Ruangan')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: RumaColors.primaryBlue, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 32,
                    color: RumaColors.white.withValues(alpha: 0.7)),
                const SizedBox(height: 8),
                Text(
                  'Arahkan kamera ke QR Code di ruangan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: RumaColors.white.withValues(alpha: 0.9),
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
