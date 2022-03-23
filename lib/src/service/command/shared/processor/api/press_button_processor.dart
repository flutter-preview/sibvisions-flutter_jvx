import 'package:flutter_client/src/model/api/requests/api_press_button_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/button_pressed_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class PressButtonProcessor with ApiServiceMixin, ConfigServiceMixin implements ICommandProcessor<ButtonPressedCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ButtonPressedCommand command) async {
    String? clientId = configService.getClientId();

    if (clientId != null) {
      ApiPressButtonRequest pressButtonRequest = ApiPressButtonRequest(
          componentName: command.componentName,
          clientId: clientId
      );

      return apiService.sendRequest(request: pressButtonRequest);
    } else {
      throw Exception("Cant find Client id, while trying to send PressButton request!");
    }
  }
}
