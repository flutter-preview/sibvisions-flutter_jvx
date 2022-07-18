import '../../../../../mixin/api_service_mixin.dart';
import '../../../../../mixin/config_service_mixin.dart';
import '../../../../../model/api/requests/api_delete_record_request.dart';
import '../../../../../model/command/api/delete_record_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../i_command_processor.dart';

class DeleteRecordCommandProcessor extends ICommandProcessor<DeleteRecordCommand>
    with ApiServiceGetterMixin, ConfigServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(DeleteRecordCommand command) {
    String clientId = configService.getClientId()!;

    ApiDeleteRecordRequest deleteRecordRequest = ApiDeleteRecordRequest(
      clientId: clientId,
      dataProvider: command.dataProvider,
      selectedRow: command.selectedRow,
      fetch: command.fetch,
      filter: command.filter,
    );
    return getApiService().sendRequest(request: deleteRecordRequest);
  }
}
