import 'package:flutter_client/src/mixin/ui_service_getter_mixin.dart';

import '../../../../../mixin/data_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../i_command_processor.dart';

class SaveFetchDataProcessor with DataServiceMixin, UiServiceGetterMixin implements ICommandProcessor<SaveFetchDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SaveFetchDataCommand command) async {
    await dataService.updateData(pFetch: command.response);

    getUiService().notifyDataChange(
      pDataProvider: command.response.dataProvider,
      pFrom: command.response.from,
      pTo: command.response.to,
    );

    return [];
  }
}
