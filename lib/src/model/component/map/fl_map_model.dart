import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../service/api/shared/api_object_property.dart';
import '../../../util/jvx_colors.dart';
import '../../../util/parse_util.dart';
import '../fl_component_model.dart';

class FlMapModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //Where the map should be centered
  LatLng? center = LatLng(48, 17);

  //List of Markers that will be shown on the map
  List<Marker> markers = [];

  //List of Polygons that will be shown on the map
  List<Polygon> polygons = [];

  //Zoom factor of map
  double zoomLevel = 13;

  //Fill Color
  Color fillColor = Colors.white;

  //Line Color
  Color lineColor = JVxColors.LIGHTER_BLACK;

  //bool PointSelectionEnabled
  bool pointSelectionEnabled = true;

  //bool pointSelectionLockedOnCenter
  bool pointSelectionLockedOnCenter = false;

  //TitleProvider
  String tileProvider = "OpenStreetMap";

  String? groupDataBook;
  String? pointsDataBook;

  //layoutVal?:CSSProperties,
  //centerPosition?:MapLocation
  String groupColumnName = "GROUP";

  String latitudeColumnName = "LATITUDE";

  String longitudeColumnName = "LONGITUDE";

  String markerImageColumnName = "MARKER_IMAGE";

  String? markerImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlMapModel() : super() {
    preferredSize = const Size(300, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlMapModel get defaultModel => FlMapModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    fillColor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.fillColor,
      pDefault: defaultModel.fillColor,
      pCurrent: fillColor,
      pConversion: ParseUtil.parseServerColor,
    );

    tileProvider = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.tileProvider,
      pDefault: defaultModel.tileProvider,
      pCurrent: tileProvider,
    );

    lineColor = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.lineColor,
      pDefault: defaultModel.lineColor,
      pCurrent: lineColor,
      pConversion: ParseUtil.parseServerColor,
    );

    groupDataBook = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.groupDataBook,
      pDefault: defaultModel.groupDataBook,
      pCurrent: groupDataBook,
    );

    markerImage = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.marker,
      pDefault: defaultModel.markerImage,
      pCurrent: markerImage,
    );

    center = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.center,
      pDefault: defaultModel.center,
      pCurrent: center,
      pConversion: _parseLatLng,
    );

    pointsDataBook = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.pointsDataBook,
      pDefault: defaultModel.pointsDataBook,
      pCurrent: pointsDataBook,
    );

    groupColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.groupColumnName,
      pDefault: defaultModel.groupColumnName,
      pCurrent: groupColumnName,
    );

    latitudeColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.latitudeColumnName,
      pDefault: defaultModel.latitudeColumnName,
      pCurrent: latitudeColumnName,
    );

    longitudeColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.longitudeColumnName,
      pDefault: defaultModel.longitudeColumnName,
      pCurrent: longitudeColumnName,
    );

    markerImageColumnName = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.markerImageColumnName,
      pDefault: defaultModel.markerImageColumnName,
      pCurrent: markerImageColumnName,
    );

    pointSelectionEnabled = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.pointSelectionEnabled,
      pDefault: defaultModel.pointSelectionEnabled,
      pCurrent: pointSelectionEnabled,
    );

    pointSelectionLockedOnCenter = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.pointSelectionLockedOnCenter,
      pDefault: defaultModel.pointSelectionLockedOnCenter,
      pCurrent: pointSelectionLockedOnCenter,
    );

    zoomLevel = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.zoomLevel,
      pDefault: defaultModel.zoomLevel,
      pCurrent: zoomLevel,
      pConversion: (value) => value.toDouble(),
    );
  }

  LatLng? _parseLatLng(dynamic pValue) {
    if (pValue != null && pValue is String) {
      List<String> centerStrings = pValue.split(";");
      return LatLng(double.tryParse(centerStrings.first) ?? 0, double.tryParse(centerStrings.last) ?? 0);
    }
    return null;
  }
}
