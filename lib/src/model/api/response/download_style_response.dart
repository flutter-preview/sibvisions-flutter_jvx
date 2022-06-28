import 'dart:typed_data';

import 'package:flutter_client/src/model/api/response/api_response.dart';

class DownloadStyleResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Uint8List bodyBytes;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DownloadStyleResponse({
    required this.bodyBytes,
    required String name,
    required Object originalRequest,
  }) : super(
          name: name,
          originalRequest: originalRequest,
        );
}