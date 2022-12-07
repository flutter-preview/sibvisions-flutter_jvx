import '../../service/api/shared/api_object_property.dart';
import 'api_response.dart';

class ApplicationMetaDataResponse extends ApiResponse {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// SessionId
  final String clientId;

  /// Version of the remote app
  final String version;

  /// Lang code of the app
  final String langCode;

  /// Time zone code of the app
  final String? timeZoneCode;

  /// Whether lost password feature is enabled.
  final bool lostPasswordEnabled;

  /// Whether lost password feature is enabled.
  final bool? rememberMeEnabled;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApplicationMetaDataResponse({
    required this.clientId,
    required this.version,
    required this.langCode,
    this.timeZoneCode,
    required this.lostPasswordEnabled,
    this.rememberMeEnabled,
    required super.name,
  });

  ApplicationMetaDataResponse.fromJson(super.json)
      : clientId = json[ApiObjectProperty.clientId],
        version = json[ApiObjectProperty.version],
        langCode = json[ApiObjectProperty.langCode],
        timeZoneCode = json[ApiObjectProperty.timeZoneCode],
        lostPasswordEnabled = json[ApiObjectProperty.lostPasswordEnabled],
        rememberMeEnabled = json[ApiObjectProperty.rememberMe],
        super.fromJson();

  @override
  String toString() {
    return 'ApplicationMetaDataResponse{clientId: $clientId, version: $version, langCode: $langCode, timeZoneCode: $timeZoneCode, lostPasswordEnabled: $lostPasswordEnabled, rememberMeEnabled: $rememberMeEnabled}';
  }
}
