import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
void main() => runApp(MaterialApp(home: QRViewExample(),debugShowCheckedModeBanner: false,));

bool _flashOn = true;
bool _fronCam = true;
const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  var qrText = '';
  var flashState = flashOn;
  var cameraState = frontCamera;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: IconButton(
                          color: Colors.blue,
                          icon:
                              Icon(_flashOn ? Icons.flash_off : Icons.flash_on),
                          onPressed: () {
                            setState(() {
                              _flashOn = !_flashOn;
                            });
                            controller.toggleFlash();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: IconButton(
                          color: Colors.blue,
                          icon: Icon(_fronCam
                              ? Icons.camera_rear
                              : Icons.camera_front),
                          onPressed: () {
                            setState(() {
                              _fronCam = !_fronCam;
                            });
                            controller.flipCamera();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  bool _isBackCamera(String current) {
    return backCamera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _settingModalBottomSheet(context);
        qrText = scanData;
        controller?.pauseCamera();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0, left: 20.0, right: 20.0, bottom: 30.0),
                  child: Center(
                    child: SizedBox(
                        width: 50,
                        height: 4.0,
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          color: Color(0xFFededed),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 30.0, right: 30.0, bottom: 30.0),
                  child: Text('Hasil pemindaian :',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(
                //       top: 10.0, left: 30.0, right: 30.0, bottom: 60.0),
                //   child: SelectableText('$qrText'),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 80.0),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: 
                            SelectableLinkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                              },
                              text: '$qrText',
                            ),
                            // SelectableText('$qrText',
                            //     textAlign: TextAlign.left),
                          )
                        ])),
                  ]),
                ),
              ],
            ),
          );
        }).whenComplete(() {
      controller?.resumeCamera();
    });
  }
}
