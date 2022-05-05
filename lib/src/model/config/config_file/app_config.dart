import 'package:flutter_client/src/model/config/config_file/remote_config.dart';
import 'package:flutter_client/src/model/config/config_file/startup_parameters.dart';
import 'package:flutter_client/src/model/config/config_file/ui_config.dart';

class AppConfig {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final StartupParameters? startupParameters;

  final RemoteConfig? remoteConfig;

  final UiConfig? uiConfig;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  AppConfig({
    required this.uiConfig,
    required this.remoteConfig,
    required this.startupParameters,
  });

  AppConfig.fromJson({required Map<String, dynamic> json}) :
    uiConfig = json["uiConfig"] != null ? UiConfig.fromJson(json: json["uiConfig"]) : null,
    startupParameters = json["startupParameters"] != null ? StartupParameters.fromJson(json: json["startupParameters"]) : null,
    remoteConfig = json["remoteConfig"] != null ? RemoteConfig.fromJson(json: json["remoteConfig"]) : null;
}