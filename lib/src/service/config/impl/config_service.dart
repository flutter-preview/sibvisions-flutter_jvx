import '../i_config_service.dart';

/// Stores all config and session based data.
// Author: Michael Schober
class ConfigService implements IConfigService{

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Name of the visionX app
  String appName;

  /// Url of the remote server
  String url;

  /// Version of the remote server
  String? version;

  /// Current clientId (sessionId)
  String? clientId;

  /// Directory of the installed app, null if launched in web
  String? directory;



  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ConfigService({
    required this.url,
    required this.appName,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String getAppName() {
    return appName;
  }

  @override
  String? getClientId() {
    return clientId;
  }

  @override
  String? getDirectory() {
    return directory;
  }

  @override
  String getUrl() {
    return url;
  }

  @override
  String? getVersion() {
    return version;
  }

  @override
  void setAppName(String pAppName) {
    appName = pAppName;
  }

  @override
  void setClientId(String? pClientId) {
    clientId = pClientId;
  }

  @override
  void setDirectory(String? pDirectory) {
    directory = pDirectory;
  }

  @override
  void setUrl(String pUrl) {
    url = pUrl;
  }

  @override
  void setVersion(String pVersion) {
    version = pVersion;
  }




}