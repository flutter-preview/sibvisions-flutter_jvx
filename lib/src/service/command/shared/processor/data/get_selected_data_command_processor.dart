import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/data/subscriptions/data_record.dart';
import '../../i_command_processor.dart';

class GetSelectedDataCommandProcessor
    with DataServiceMixin, UiServiceMixin
    implements ICommandProcessor<GetSelectedDataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(GetSelectedDataCommand command) async {
    // Get Data record - is null if databook has no selected row
    DataRecord? record = await getDataService().getSelectedRowData(
      pColumnNames: command.columnNames,
      pDataProvider: command.dataProvider,
    );

    getUiService().setSelectedData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pDataRow: record,
    );

    return [];
  }
}
