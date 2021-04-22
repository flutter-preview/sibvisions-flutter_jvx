import 'dart:convert';

/// Global qr code formatter
///
/// If you want to use your own just overwrite the class
/// and set the global instance
class QRCodeFormatter {
  static final errorMsg = 'Couldn\'t parse qr code!';
  static QRCodeFormatter global = QRCodeFormatter();

  Map<String, dynamic> formatQRCode(String qrString) {
    Map<String, dynamic> _properties = <String, dynamic>{};

    if (qrString.isNotEmpty) {
      try {
        _properties = _fromJson(qrString);
      } on FormatException {
        _properties = _fromParameters(qrString);
      }
    } else {
      throw FormatException(errorMsg);
    }

    return _properties;
  }

  Map<String, dynamic> _fromJson(String qrString) {
    try {
      Map<String, dynamic> parsed = json.decode(qrString);

      if (parsed.isNotEmpty &&
          (parsed.containsKey('APPNAME') ||
              parsed.containsKey('URL') ||
              parsed.containsKey('USER'))) {
        return parsed;
      } else {
        throw FormatException(errorMsg);
      }
    } on FormatException {
      throw FormatException(errorMsg);
    }
  }

  Map<String, dynamic> _fromParameters(String qrString) {
    Map<String, dynamic> properties = <String, dynamic>{};

    List<String> result = qrString.split('\n');

    for (final res in result) {
      if (_checkQRString(res)) {
        if (res.contains('URL')) {
          properties['URL'] = _getStringFromQRData(res);
        } else if (res.contains('APPNAME') || res.contains('Application')) {
          properties['APPNAME'] = _getStringFromQRData(res);
        } else if (res.contains('USER')) {
          properties['USER'] = _getStringFromQRData(res);
        } else if (res.contains('URL')) {
          properties['PWD'] = _getStringFromQRData(res);
        }
      }
    }

    return properties;
  }

  bool _checkQRString(String? qrString) {
    return (qrString != null &&
        qrString.isNotEmpty &&
        (qrString.contains(': ') || qrString.contains('=')));
  }

  String _getStringFromQRData(String data) {
    try {
      if (data.contains(': '))
        return data.substring(data.indexOf(': ') + 2);
      else
        return data.substring(data.indexOf('=') + 1);
    } on Exception {
      return data.substring(data.indexOf('=') + 1);
    }
  }
}
