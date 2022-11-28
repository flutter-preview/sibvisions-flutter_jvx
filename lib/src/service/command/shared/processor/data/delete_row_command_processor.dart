import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/delete_row_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class DeleteRowCommandProcessor implements ICommandProcessor<DeleteRowCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteRowCommand command) async {
    // set selected row of databook
    bool success = await IDataService().deleteRow(
      pDataProvider: command.dataProvider,
      pDeletedRow: command.deletedRow,
      pNewSelectedRow: command.newSelectedRow,
    );

    // Notify components that their selected row changed, if setting the row failed show error dialog.
    if (success) {
      IUiService().notifyDataChange(
        pDataProvider: command.dataProvider,
      );
    } else {
      return [
        OpenErrorDialogCommand(
          message: "Setting new selected row failed",
          reason: "Setting new selected row failed",
        )
      ];
    }
    return [];
  }
}
