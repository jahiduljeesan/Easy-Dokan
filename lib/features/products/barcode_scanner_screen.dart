import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final bool isPopup;
  const BarcodeScannerScreen({super.key, this.isPopup = false});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  bool isDetected = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.isPopup
          ? null
          : AppBar(
              title: const Text('Scan Barcode'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindowSize = constraints.maxWidth * 0.7;
          final scanWindow = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: scanWindowSize,
            height: scanWindowSize,
          );

          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                scanWindow: scanWindow,
                onDetect: (capture) {
                  if (isDetected) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final barcode = barcodes.first;
                    if (barcode.rawValue != null) {
                      isDetected = true;
                      controller.stop();
                      if (widget.isPopup) {
                        Navigator.of(context).pop(barcode.rawValue);
                      } else {
                        context.pop(barcode.rawValue);
                      }
                    }
                  }
                },
              ),
              CustomPaint(
                painter: ScannerOverlayPainter(scanWindow: scanWindow),
                child: Container(),
              ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final currentY =
                      scanWindow.top +
                      (scanWindow.height * _animationController.value);
                  return Positioned(
                    top: currentY,
                    left: scanWindow.left,
                    width: scanWindow.width,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => controller.toggleTorch(),
                      icon: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.switchCamera(),
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isPopup)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanWindow)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const cornerLength = 20.0;

    // Top-Left
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + Offset(cornerLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + Offset(0, cornerLength),
      borderPaint,
    );

    // Top-Right
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + Offset(-cornerLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + Offset(0, cornerLength),
      borderPaint,
    );

    // Bottom-Left
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + Offset(cornerLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + Offset(0, -cornerLength),
      borderPaint,
    );

    // Bottom-Right
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + Offset(-cornerLength, 0),
      borderPaint,
    );
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + Offset(0, -cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return scanWindow != oldDelegate.scanWindow;
  }
}
