import 'package:flutter_client/src/model/api/requests/api_set_values_request.dart';

import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/set_values_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class SetValuesProcessor with ConfigServiceMixin, ApiServiceMixin implements ICommandProcessor<SetValuesCommand> {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<List<BaseCommand>> processCommand(SetValuesCommand command) {
    String? clientId = configService.getClientId();

    if (clientId != null) {

      ApiSetValuesRequest setValuesRequest = ApiSetValuesRequest(
          componentId: command.componentId,
          clientId: clientId,
          dataProvider: command.dataProvider,
          columnNames: command.columnNames,
          values: command.values
      );

      return apiService.sendRequest(request: setValuesRequest);
    } else {
      throw Exception("NO CLIENT ID FOUND while trying to send setValues request. CommandID: " + command.id.toString());
    }
  }
}