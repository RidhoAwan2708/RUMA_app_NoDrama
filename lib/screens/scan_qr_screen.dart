import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'room_detail_screen.dart';

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
    final roomId = raw.startsWith('RUMA:') ? raw.substring(5) : raw;

    if (!mounted) return;

    // Membuka langsung halaman detail secara aman tanpa lewat routes.dart
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(roomId: roomId),
      ),
    ).then((_) {
      setState(() {
        _hasScanned = false; 
      });
    });
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
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}