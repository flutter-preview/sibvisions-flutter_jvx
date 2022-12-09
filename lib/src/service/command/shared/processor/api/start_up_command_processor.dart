import 'package:flutter/foundation.dart';

import '../../../../../flutter_ui.dart';
import '../../../../../model/command/api/startup_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_startup_request.dart';
import '../../../../../util/device_info.dart';
import '../../../../api/i_api_service.dart';
import '../../../../config/i_config_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Used to process [StartupCommand], will call ApiService
class StartUpCommandProcessor implements ICommandProcessor<StartupCommand> {
  @override
  Future<List<BaseCommand>> processCommand(StartupCommand command) async {
    IConfigService configService = IConfigService();

    if (command.appName != null) {
      await configService.setAppName(command.appName!);
    }
    if (command.username != null) {
      await configService.setUsername(command.username!);
    }
    if (command.password != null) {
      await configService.setPassword(command.password!);
    }

    DeviceInfo deviceInfo = await DeviceInfo.fromPlatform();

    //Close frames on (re-)start
    if (FlutterUI.getCurrentContext() != null) {
      IUiService().closeFrames();
      IUiService().closeFrameDialogs();
    }

    ApiStartUpRequest startUpRequest = ApiStartUpRequest(
      appMode: "full",
      applicationName: configService.getAppName()!,
      authKey: configService.getAuthCode(),
      screenHeight: configService.getPhoneSize()?.height.toInt(),
      screenWidth: configService.getPhoneSize()?.width.toInt(),
      readAheadLimit: 100,
      deviceMode:
          (kIsWeb && !IConfigService().isMobileOnly()) || IConfigService().isWebOnly() ? "mobileDesktop" : "mobile",
      username: command.username,
      password: command.password,
      langCode: IConfigService().getUserLanguage() ?? IConfigService().getPlatformLocale(),
      timeZoneCode: IConfigService().getPlatformTimeZone(),
      technology: deviceInfo.technology,
      osName: deviceInfo.osName,
      osVersion: deviceInfo.osVersion,
      appVersion: deviceInfo.appVersion,
      deviceType: deviceInfo.deviceType,
      deviceTypeModel: deviceInfo.deviceTypeModel,
      deviceId: deviceInfo.deviceId,
      serverVersion: FlutterUI.supportedServerVersion,
      startUpParameters: IConfigService().getStartupParameters(),
    );

    return IApiService().sendRequest(startUpRequest);
  }
}
