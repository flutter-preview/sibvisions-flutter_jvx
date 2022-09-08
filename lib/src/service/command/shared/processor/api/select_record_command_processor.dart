import '../../../../../../mixin/api_service_mixin.dart';
import '../../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/command/api/select_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/request/api_select_record_request.dart';
import '../../i_command_processor.dart';

class SelectRecordCommandProcessor
    with ApiServiceGetterMixin, ConfigServiceGetterMixin
    implements ICommandProcessor<SelectRecordCommand> {
  @override
  Future<List<BaseCommand>> processCommand(SelectRecordCommand command) async {
    if (getConfigService().isOffline()) {
      return [
        ChangeSelectedRowCommand(
            dataProvider: command.dataProvider, newSelectedRow: command.selectedRecord, reason: command.reason)
      ];
    }

    return getApiService().sendRequest(
        request: ApiSelectRecordRequest(
      dataProvider: command.dataProvider,
      selectedRow: command.selectedRecord,
      fetch: command.fetch,
      filter: command.filter,
      reload: command.reload,
    ));
  }
}
