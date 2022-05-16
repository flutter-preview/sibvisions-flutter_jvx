import 'package:flutter_client/src/model/api/response/dal_data_provider_changed_response.dart';
import 'package:flutter_client/src/model/command/api/fetch_command.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/data/change_selected_row_command.dart';
import 'package:flutter_client/src/model/command/data/delete_provider_data_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class DalDataProviderChangedProcessor extends IProcessor<DalDataProviderChangedResponse> {
  @override
  List<BaseCommand> processResponse({required DalDataProviderChangedResponse pResponse}) {
    List<BaseCommand> commands = [];

    // If -1 then delete all saved data and re-fetch
    if (pResponse.reload == -1) {
      DeleteProviderDataCommand deleteProviderDataCommand = DeleteProviderDataCommand(
        dataProvider: pResponse.dataProvider,
        reason: "Data provider changed response was reload -1",
        deleteAll: true,
      );
      commands.add(deleteProviderDataCommand);

      FetchCommand fetchCommand = FetchCommand(
        reason: "Data provider changed response was reload -1",
        fromRow: 0,
        rowCount: 100,
        dataProvider: pResponse.dataProvider,
      );
      commands.add(fetchCommand);
    } else if (pResponse.reload != null) {
      // If reload not -1/null re-fetch only given row
      FetchCommand fetchCommand = FetchCommand(
        reason: "Data provider changed response was reload -1",
        fromRow: pResponse.reload!,
        rowCount: 1,
        dataProvider: pResponse.dataProvider,
      );
      commands.add(fetchCommand);
    }

    if (pResponse.selectedRow != null) {
      ChangeSelectedRowCommand changeSelectedRowCommand = ChangeSelectedRowCommand(
        dataProvider: pResponse.dataProvider,
        newSelectedRow: pResponse.selectedRow!,
        reason: "Data provider changed - server response",
      );
      commands.add(changeSelectedRowCommand);
    }

    return commands;
  }
}