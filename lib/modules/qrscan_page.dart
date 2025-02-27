
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            allowDuplicates: false,
            // controller: MobileScannerController(
            //   facing: CameraFacing.back,
            //   torchEnabled: true,
            // ),
            onDetect: (barcode, args) {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue;
                Get.back(result: code);
                debugPrint('Barcode found! $code');
              }
            },
          ),
          // SvgPicture.asset(
          //   GlobalAssets.qrCode,
          //   color: Colors.black,
          //   width: 200.w,
          // ),
        ],
      ),
    );
  }
}
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// // 解析二维码的组件
// class QrScan extends StatefulWidget {
//   const QrScan({Key key}) : super(key: key);

//   @override
//   State createState() => _QrScanState();
// }

// class _QrScanState extends State<QrScan> {
//   Barcode result;
//   QRViewController controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       controller.pauseCamera();
//     }
//     controller.resumeCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Expanded(flex: 4, child: _buildQrView(context)),
//         ],
//       ),
//     );
//   }

//   Widget _buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     var scanArea = 300.w;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: _onQRViewCreated,
//       overlay: QrScannerOverlayShape(
//         borderColor: Colors.red,
//         borderRadius: 10.w,
//         borderLength: 30.w,
//         borderWidth: 10.w,
//         cutOutSize: scanArea,
//       ),
//     );
//   }

//   bool poped = false;
//   void _onQRViewCreated(QRViewController controller) {
//     setState(() {
//       this.controller = controller;
//     });
//     controller.scannedDataStream.listen((scanData) {
//       if (!poped) {
//         Get.back(result: scanData.code);
//         poped = true;
//       }
//       Log.e(scanData.code);
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
