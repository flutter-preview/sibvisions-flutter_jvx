import 'package:collection/collection.dart';

import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

enum LayoutMode {
  /// minimal layout mode (e.g. smartphone).
  Mini,

  /// small layout mode (e.g. tablet).
  Small,

  /// full layout mode (e.g. desktop).
  Full,
}

class DeviceStatusResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final LayoutMode? layoutMode;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DeviceStatusResponse({
    required this.layoutMode,
    required super.name,
  });

  DeviceStatusResponse.fromJson(super.json)
      : layoutMode = json[ApiObjectProperty.layoutMode] != null
            ? LayoutMode.values.firstWhereOrNull((e) => e.name == json[ApiObjectProperty.layoutMode])
            : null,
        super.fromJson();
}
