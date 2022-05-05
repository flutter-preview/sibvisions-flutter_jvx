import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client/src/model/config/config_file/app_config.dart';

import 'main.dart';
import 'src/model/command/api/startup_command.dart';

import 'src/service/data/i_data_service.dart';
import 'src/service/data/impl/data_service.dart';

import 'data/config/config_generator.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/isolate/isolate_api.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/i_controller.dart';
import 'src/service/api/shared/i_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/isolate/isolate_layout_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/isolate/isolate_storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';

Future<bool> initAppMobile() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();


  // Load Config from file
  String rawConfig = await rootBundle.loadString('assets/config/app.conf.json');
  AppConfig appConfig = AppConfig.fromJson(json: jsonDecode(rawConfig));
  UrlConfig urlConfigServer = UrlConfig.empty();

  if(appConfig.remoteConfig != null && appConfig.remoteConfig!.devUrlConfigs != null) {
    urlConfigServer = appConfig.remoteConfig!.devUrlConfigs![appConfig.remoteConfig!.indexOfUsingUrlConfig];
  }

  EndpointConfig endpointConfig = ConfigGenerator.generateFixedEndpoints();
  UrlConfig urlConfig = urlConfigServer;
  ApiConfig apiConfig = ApiConfig(urlConfig: urlConfig, endpointConfig: endpointConfig);
  IRepository repository = OnlineApiRepository(apiConfig: apiConfig);
  IController controller = ApiController();
  IApiService apiService = await IsolateApi.create(controller: controller, repository: repository);
  services.registerSingleton(apiService, signalsReady: true);

  // Config
  IConfigService configService = ConfigService(
    appName: "demo",
    apiConfig: apiConfig
  );
  services.registerSingleton(configService, signalsReady: true);

  // Layout
  ILayoutService layoutService = await IsolateLayoutService.create();
  services.registerSingleton(layoutService, signalsReady: true);

  // Storage
  IStorageService storageService = await IsolateStorageService.create();
  services.registerSingleton(storageService, signalsReady: true);

  // Data
  IDataService dataService = DataService();
  services.registerSingleton(dataService, signalsReady: true);

  // Command
  ICommandService commandService = CommandService();
  services.registerSingleton(commandService, signalsReady: true);

  // UI
  IUiService uiService = UiService();
  services.registerSingleton(uiService, signalsReady: true);

  StartupCommand startupCommand = StartupCommand(reason: "InitApp");
  commandService.sendCommand(startupCommand);

  return true;
}