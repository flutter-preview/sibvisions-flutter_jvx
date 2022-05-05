import 'package:flutter_client/src/model/command/api/startup_command.dart';
import 'src/service/data/i_data_service.dart';
import 'src/service/data/impl/data_service.dart';
import 'src/service/layout/i_layout_service.dart';
import 'src/service/layout/impl/layout_service.dart';

import 'data/config/config_generator.dart';
import 'src/model/config/api/api_config.dart';
import 'src/model/config/api/endpoint_config.dart';
import 'src/model/config/api/url_config.dart';
import 'src/service/api/i_api_service.dart';
import 'src/service/api/impl/default/api_service.dart';
import 'src/service/api/shared/controller/api_controller.dart';
import 'src/service/api/shared/i_controller.dart';
import 'src/service/api/shared/i_repository.dart';
import 'src/service/api/shared/repository/online_api_repository.dart';
import 'src/service/command/i_command_service.dart';
import 'src/service/command/impl/command_service.dart';
import 'src/service/config/i_config_service.dart';
import 'src/service/config/impl/config_service.dart';
import 'src/service/service.dart';
import 'src/service/storage/i_storage_service.dart';
import 'src/service/storage/impl/default/storage_service.dart';
import 'src/service/ui/i_ui_service.dart';
import 'src/service/ui/impl/ui_service.dart';

initAppWeb() {
  // API
  UrlConfig urlConfigServer1 = ConfigGenerator.generateMobileServerUrl("127.0.0.1", 8888);
  UrlConfig urlConfigServer2 = ConfigGenerator.generateMobileServerUrl("127.0.0.1", 8090);

  EndpointConfig endpointConfig = ConfigGenerator.generateFixedEndpoints();
  ApiConfig apiConfig = ApiConfig(urlConfig: urlConfigServer2, endpointConfig: endpointConfig);
  IRepository repository = OnlineApiRepository(apiConfig: apiConfig);
  IController controller = ApiController();
  IApiService apiService = ApiService(repository: repository, controller: controller);
  services.registerSingleton(apiService, signalsReady: true);

  // Config
  IConfigService configService = ConfigService(
    appName: "demo",
    apiConfig: apiConfig
  );
  services.registerSingleton(configService, signalsReady: true);

  // Layout
  ILayoutService layoutService = LayoutService();
  services.registerSingleton(layoutService, signalsReady: true);

  // Storage
  IStorageService storageService = DefaultStorageService();
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
}