import 'offline_config.dart';
import 'server_config.dart';
import 'ui_config.dart';
import 'version_config.dart';

class AppConfig {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? title;
  final Uri? privacyPolicy;
  final int? requestTimeout;
  final bool? autoRestartOnSessionExpired;

  final UiConfig? uiConfig;
  final ServerConfig? serverConfig;
  final VersionConfig? versionConfig;
  final OfflineConfig? offlineConfig;

  final Map<String, dynamic>? startupParameters;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const AppConfig({
    this.title,
    this.privacyPolicy,
    this.requestTimeout,
    this.autoRestartOnSessionExpired,
    this.uiConfig,
    this.serverConfig,
    this.versionConfig,
    this.offlineConfig,
    this.startupParameters,
  });

  const AppConfig.empty()
      : this(
          title: "JVx Mobile",
          requestTimeout: 10,
          autoRestartOnSessionExpired: true,
          uiConfig: const UiConfig.empty(),
          serverConfig: const ServerConfig.empty(),
          versionConfig: const VersionConfig.empty(),
          offlineConfig: const OfflineConfig.empty(),
        );

  AppConfig.fromJson(Map<String, dynamic> json)
      : this(
          title: json['title'],
          privacyPolicy: json['privacyPolicy'] != null ? Uri.tryParse(json['privacyPolicy']) : null,
          requestTimeout: json['requestTimeout'],
          autoRestartOnSessionExpired: json['autoRestartOnSessionExpired'],
          uiConfig: json['uiConfig'] != null ? UiConfig.fromJson(json['uiConfig']) : null,
          serverConfig: json['serverConfig'] != null ? ServerConfig.fromJson(json['serverConfig']) : null,
          versionConfig: json['versionConfig'] != null ? VersionConfig.fromJson(json['versionConfig']) : null,
          offlineConfig: json['offlineConfig'] != null ? OfflineConfig.fromJson(json['offlineConfig']) : null,
          startupParameters: json['startupParameters'],
        );

  AppConfig merge(AppConfig? other) {
    if (other == null) return this;

    return AppConfig(
      title: other.title ?? title,
      privacyPolicy: other.privacyPolicy ?? privacyPolicy,
      requestTimeout: other.requestTimeout ?? requestTimeout,
      autoRestartOnSessionExpired: other.autoRestartOnSessionExpired ?? autoRestartOnSessionExpired,
      uiConfig: uiConfig?.merge(other.uiConfig) ?? other.uiConfig,
      serverConfig: serverConfig?.merge(other.serverConfig) ?? other.serverConfig,
      versionConfig: versionConfig?.merge(other.versionConfig) ?? other.versionConfig,
      offlineConfig: offlineConfig?.merge(other.offlineConfig) ?? other.offlineConfig,
      startupParameters: (startupParameters ?? {})..addAll(other.startupParameters ?? {}),
    );
  }
}
