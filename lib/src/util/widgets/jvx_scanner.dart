/*
 * Copyright 2022-2023 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../flutter_ui.dart';

/// Definition of the callback for the Scanner.
///
/// In case of [allowMultiScan], this can returns multiple barcodes.
typedef ScannerCallback = FutureOr<void> Function(List<Barcode> barcode);

/// Displays a Scanner with an additional control bar on top.
class JVxScanner extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This callback will be called with the barcode data.
  final ScannerCallback callback;
  final bool allowMultiScan;
  final String title;
  final List<BarcodeFormat> formats;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const JVxScanner({
    super.key,
    required this.callback,
    this.allowMultiScan = false,
    this.title = "QR Scanner",
    this.formats = const [BarcodeFormat.qrCode],
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<JVxScanner> createState() => _JVxScannerState();
}

class _JVxScannerState extends State<JVxScanner> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for the scanner.
  late final MobileScannerController controller;
  final List<Barcode> scannedBarcodes = [];
  bool multiScanEnabled = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: widget.formats,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var result = widget.callback(scannedBarcodes);
        if (result is Future) await result;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: Navigator.canPop(context) ? 0 : null,
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const FaIcon(FontAwesomeIcons.angleLeft),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Text(FlutterUI.translate(widget.title)),
          actions: [
            IconButton(
              onPressed: () => controller.toggleTorch(),
              icon: ValueListenableBuilder(
                  valueListenable: controller.torchState,
                  builder: (context, state, child) {
                    switch (state as TorchState) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off);
                      case TorchState.on:
                        return const Icon(Icons.flash_on);
                    }
                  }),
            ),
            if (widget.allowMultiScan)
              PopupMenuButton(
                onSelected: (value) => setState(() => multiScanEnabled = !multiScanEnabled),
                itemBuilder: (context) {
                  return [
                    CheckedPopupMenuItem(
                      checked: multiScanEnabled,
                      value: 0,
                      padding: EdgeInsets.zero,
                      child: Text(FlutterUI.translate("Multi Scan")),
                    ),
                  ];
                },
              )
          ],
        ),
        body: MobileScanner(
          controller: controller,
          onDetect: _onDetect,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (multiScanEnabled) {
      if (scannedBarcodes.map((e) => e.rawValue).none((e) => capture.barcodes.map((e) => e.rawValue).contains(e))) {
        unawaited(HapticFeedback.vibrate());
        scannedBarcodes.addAll(capture.barcodes);
      }
    } else {
      unawaited(HapticFeedback.vibrate());
      var result = widget.callback(capture.barcodes);
      if (result is Future) await result;
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}