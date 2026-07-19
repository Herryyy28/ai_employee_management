import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/attendance_controller.dart';
import '../../../../core/themes/app_colors.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final Barcode? barcode = capture.barcodes.firstOrNull;
    final String? code = barcode?.rawValue;

    if (code != null) {
      setState(() {
        _hasScanned = true;
      });

      // Verify the QR content (Mock parsing)
      if (code.contains('AI_EMS_PORTAL_')) {
        // Trigger check-in with QR verification success
        ref.read(attendanceControllerProvider.notifier).clockIn(qrVerified: true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code verified successfully. Clocked In!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR Code token. Please scan official workspace terminal QR.'),
            backgroundColor: AppColors.error,
          ),
        );
        // Reset scanner after delay
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _hasScanned = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Terminal QR'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default:
                    return const Icon(Icons.flash_auto, color: Colors.blue);
                }
              },
            ),
            iconSize: 26.0,
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // HUD Overlay styling
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.indigoAccent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Text(
              'Align the QR code on the dashboard terminal within the frame to clock in automatically',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
