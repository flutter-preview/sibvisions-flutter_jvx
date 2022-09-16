import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_fetch_request.dart';
import '../../i_command_processor.dart';

class FetchCommandProcessor extends ICommandProcessor<FetchCommand> with ApiServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(FetchCommand command) {
    return getApiService().sendRequest(
      request: ApiFetchRequest(
        dataProvider: command.dataProvider,
        fromRow: command.fromRow,
        rowCount: command.rowCount,
        columnNames: command.columnNames,
        includeMetaData: command.includeMetaData,
      ),
    );
  }
}
