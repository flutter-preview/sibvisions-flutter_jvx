import 'package:flutter_client/src/model/api/requests/api_open_screen_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';
import '../ui/update_components_processor.dart';

class OpenScreenCommandProcessor
    with ApiServiceMixin, ConfigServiceMixin
    implements ICommandProcessor<OpenScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) async {
    String? clientId = configService.getClientId();
    if (clientId != null) {
      UpdateComponentsProcessor.isOpenScreen = true;

      ApiOpenScreenRequest openScreenRequest = ApiOpenScreenRequest(
          componentId: command.componentId,
          clientId: clientId,
          manualClose: true
      );
      return apiService.sendRequest(request: openScreenRequest);
    } else {
      throw Exception(
          "NO CLIENT ID FOUND, while trying to send openScreen request. CommandID: " + command.id.toString());
    }
  }
}