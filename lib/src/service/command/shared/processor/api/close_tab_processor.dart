import 'package:flutter_client/src/model/api/requests/api_close_tab_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/close_tab_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class CloseTabProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<CloseTabCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(CloseTabCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiCloseTabRequest closeTabRequest = ApiCloseTabRequest(
          index: command.index,
          componentName: command.componentName,
          clientId: clientId
      );
      return apiService.sendRequest(request: closeTabRequest);
    }

    return [];
  }
}