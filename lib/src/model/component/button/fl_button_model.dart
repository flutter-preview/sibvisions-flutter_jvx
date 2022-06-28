import 'package:flutter/material.dart';

import '../../../../util/constants/i_color.dart';
import '../../../../util/parse_util.dart';
import '../../../components/button/fl_button_widget.dart';
import '../../api/api_object_property.dart';
import '../../layout/alignments.dart';
import '../fl_component_model.dart';
import '../label/fl_label_model.dart';

/// The model for [FlButtonWidget]
class FlButtonModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The model of the label widget.
  FlLabelModel labelModel = FlLabelModel();

  /// If the border activates on click.
  bool borderOnMouseEntered = false;

  /// If the border is shown.
  bool borderPainted = true;

  /// The aria label.
  String ariaLabel = "";

  /// If this is the default button to press. // TODO: implement default button behaviour
  bool defaultButton = false;

  /// The image of the button.
  String? image;

  /// The gap between image and text if both exist.
  int imageTextGap = 5;

  /// The image when the button gets pressed.
  String? mousePressedImage;

  /// The image when the button is currently being pressed down.
  String? mouseOverImage;

  /// The paddings between the button and its children.
  EdgeInsets paddings = const EdgeInsets.fromLTRB(10, 10, 10, 10);

  /// The style of the Button.
  String style = "";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlButtonModel]
  FlButtonModel() : super() {
    labelModel.verticalAlignment = VerticalAlignment.CENTER;
    labelModel.horizontalAlignment = HorizontalAlignment.RIGHT;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  set background(Color? pColor) {
    super.background = pColor;
    labelModel.background = pColor;
  }

  @override
  set foreground(Color? pColor) {
    super.foreground = pColor;
    labelModel.foreground = pColor;
  }

  @override
  set fontName(String pFontName) {
    super.fontName = pFontName;
    labelModel.fontName = pFontName;
  }

  @override
  set fontSize(int pFontSize) {
    super.fontSize = pFontSize;
    labelModel.fontSize = pFontSize;
  }

  @override
  set isBold(bool pIsBold) {
    super.isBold = pIsBold;
    labelModel.isBold = pIsBold;
  }

  @override
  set isItalic(bool pIsItalic) {
    super.isItalic = pIsItalic;
    labelModel.isItalic = pIsItalic;
  }

  @override
  FlButtonModel get defaultModel => FlButtonModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    borderOnMouseEntered = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.borderOnMouseEntered,
      pDefault: defaultModel.borderOnMouseEntered,
      pCurrent: borderOnMouseEntered,
    );
    borderPainted = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.borderPainted,
      pDefault: defaultModel.borderPainted,
      pCurrent: borderPainted,
    );

    ariaLabel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.ariaLabel,
      pDefault: defaultModel.ariaLabel,
      pCurrent: ariaLabel,
    );

    image = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.image,
      pDefault: defaultModel.image,
      pCurrent: image,
    );
    imageTextGap = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.imageTextGap,
      pDefault: defaultModel.imageTextGap,
      pCurrent: imageTextGap,
    );
    mousePressedImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.mousePressedImage,
      pDefault: defaultModel.mousePressedImage,
      pCurrent: mousePressedImage,
    );

    mouseOverImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.mouseOverImage,
      pDefault: defaultModel.mouseOverImage,
      pCurrent: mouseOverImage,
    );
    paddings = getPropertyValue(
        pJson: pJson,
        pKey: ApiObjectProperty.margins,
        pDefault: defaultModel.paddings,
        pCurrent: paddings,
        pConversion: (value) => ParseUtil.parseMargins(value));

    // var jsonMargins = ParseUtil.parseMargins(pJson[ApiObjectProperty.margins]);
    // if (jsonMargins != null) {
    //   paddings = jsonMargins;
    // }
    style = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.style,
      pDefault: defaultModel.style,
      pCurrent: style,
    );

    // Label parsing
    // Label alignment gets sent in 2 different keys than when sending a label directly.

    // If the button is disabled
    if (_isGrey) {
      foreground = IColorConstants.COMPONENT_DISABLED;
    }

    Map<String, dynamic> labelJson = <String, dynamic>{};
    if (pJson.containsKey(ApiObjectProperty.horizontalAlignment)) {
      labelJson[ApiObjectProperty.horizontalAlignment] = pJson[ApiObjectProperty.horizontalTextPosition];
    }
    if (pJson.containsKey(ApiObjectProperty.verticalAlignment)) {
      labelJson[ApiObjectProperty.verticalAlignment] = pJson[ApiObjectProperty.verticalAlignment];
    }
    if (pJson.containsKey(ApiObjectProperty.text)) {
      labelJson[ApiObjectProperty.text] = pJson[ApiObjectProperty.text];
    }

    labelModel.applyFromJson(labelJson);
  }

  bool get _isGrey {
    return !(isEnabled && isFocusable);
  }
}
