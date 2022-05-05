import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../font_awesome_util.dart';
import 'image_loader_stub.dart'
    if (dart.library.io) 'image_loader_mobile.dart'
    if (dart.library.html) 'image_loader_web.dart';

abstract class ImageLoader {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const Widget DEFAULT_IMAGE = FaIcon(
    FontAwesomeIcons.questionCircle,
    size: 16,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  factory ImageLoader() => getImageLoader();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Loads an Image from the filesystem.
  Image loadImageFiles(String pPath,
      {double? pWidth, double? pHeight, Color? pBlendedColor, ImageStreamListener? pImageStreamListener});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Loads any server sent image string.
  static Widget loadImage(String pImageString,
      {Size? pWantedSize, Color? pWantedColor, ImageStreamListener? pImageStreamListener}) {
    if (pImageString.isEmpty) {
      return DEFAULT_IMAGE;
    } else if (IFontAwesome.checkFontAwesome(pImageString)) {
      return IFontAwesome.getFontAwesomeIcon(pText: pImageString, pIconSize: pWantedSize?.width, pColor: pWantedColor);
    } else {
      List<String> arr = pImageString.split(',');

      String path = arr[0];
      Size? size;
      //bool dynamic = false;

      if (arr.length >= 3 && double.tryParse(arr[1]) != null && double.tryParse(arr[2]) != null) {
        size = Size(double.parse(arr[1]), double.parse(arr[2]));
      }

      //if (arr.length >= 4) {
      //  dynamic = ParseUtil.parseBoolFromString(arr[3]) ?? false;
      //}

      if (pWantedSize != null) {
        size = pWantedSize;
      }

      return getImageLoader().loadImageFiles(path,
          pWidth: size?.width,
          pHeight: size?.height,
          pBlendedColor: pWantedColor,
          pImageStreamListener: pImageStreamListener);
    }
  }
}