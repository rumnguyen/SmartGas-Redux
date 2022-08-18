import 'dart:async';

import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

typedef ScannerFunction = void Function(String data);

class QrScannerPage extends StatefulWidget {
  final Color? appBarBackgroundColor;
  final String appBarTitle;
  final TextStyle? appBarTextStyle;
  final bool centerTitle;
  final bool enableFlash;
  final bool initialFrontCamera;
  final bool enableFrontCamera;
  final QrScannerOverlayShape? overlayShape;
  final ScannerFunction? function;
  final bool enableDataStream;
  final double iconSize;

  QrScannerPage({
    Key? key,
    this.appBarBackgroundColor,
    required this.appBarTitle,
    this.appBarTextStyle,
    this.centerTitle = true,
    this.enableFlash = false,
    this.initialFrontCamera = false,
    this.enableFrontCamera = false,
    this.overlayShape,
    this.function,
    this.enableDataStream = false,
    this.iconSize = 25.0,
  })  : assert(appBarTitle.isNotEmpty && iconSize > 0.0),
        super(key: key);

  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey _qrKey = GlobalKey();
  QRViewController? _qrController;
  bool _flashStatus = false;
  bool _frontCameraStatus = false;
  late QrScannerOverlayShape _overlayShape;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _flashStatus = widget.enableFlash;
    _frontCameraStatus =
        (widget.enableFrontCamera && widget.initialFrontCamera);
    _initOverlayShape();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  void _initOverlayShape() {
    if (widget.overlayShape == null) {
      _overlayShape = QrScannerOverlayShape(
        borderColor: Color(0xFFFFFFFF),
        borderRadius: 0.0,
        borderLength: 20,
        borderWidth: 10,
        cutOutSize: 250,
        overlayColor: Color.fromRGBO(0, 0, 0, 80),
      );
    } else {
      _overlayShape = widget.overlayShape!;
    }
  }

  void flipCamera() {
    _qrController?.flipCamera();
  }

  void toggleFlash() {
    _qrController?.toggleFlash();
  }

  void pauseCamera() {
    _qrController?.pauseCamera();
  }

  void resumeCamera() {
    _qrController?.resumeCamera();
  }

  void _onQrViewCreated(QRViewController controller) {
    _qrController = controller;

    if (_flashStatus) {
      _qrController?.toggleFlash();
    }

    if (_frontCameraStatus) {
      _qrController?.flipCamera();
    }

    _subscription = _qrController?.scannedDataStream.listen((scanData) {
      if (!widget.enableDataStream && _subscription != null) {
        _subscription?.cancel();
      }

      if (widget.function != null) {
        widget.function!(scanData.code ?? '');
      }
    });
  }

  Widget _renderFlipCameraButton() {
    if (!widget.enableFrontCamera) {
      return Container();
    }

    return SizedBox(
      width: 55,
      child: TextButton(
        onPressed: () {
          setState(() {
            _frontCameraStatus = !_frontCameraStatus;
          });
          flipCamera();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0.0),
          splashFactory: InkRipple.splashFactory,
          textStyle: const TextStyle(
            color: Colors.white,
          )
        ),
        child: Icon(
          _frontCameraStatus ? Icons.camera_front : Icons.camera_rear,
          color: Colors.white,
          size: widget.iconSize,
        ),
      ),
    );
  }

  Widget _renderFlashButton() {
    return SizedBox(
      width: 55,
      child: TextButton(
        onPressed: () {
          setState(() {
            _flashStatus = !_flashStatus;
          });
          toggleFlash();
        },
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0.0),
            splashFactory: InkRipple.splashFactory,
            textStyle: const TextStyle(
              color: Colors.white,
            )
        ),
        child: Icon(
          _flashStatus ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: widget.iconSize,
        ),
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    return AppBar(
      title: Text(
        widget.appBarTitle,
        textScaleFactor: 1.0,
        style: widget.appBarTextStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: widget.centerTitle,
      backgroundColor: widget.appBarBackgroundColor ?? GlobalManager.colors.majorColor(),
      leading: TextButton(
        onPressed: () => pop(context),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0.0),
            splashFactory: InkRipple.splashFactory,
            textStyle: const TextStyle(
              color: Colors.white,
            )
        ),
        child: const FaIcon(
          FontAwesomeIcons.solidCircleLeft,
          size: 20,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        _renderFlipCameraButton(),
        _renderFlashButton(),
      ],
    );
  }

  Widget _renderBody() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQrViewCreated,
      overlay: _overlayShape,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(),
      backgroundColor: Colors.white,
      body: _renderBody(),
    );
  }
}
