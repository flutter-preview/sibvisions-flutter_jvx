import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../../../../model/layout/layout_data.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

class UpdateLayoutPositionCommandProcessor implements ICommandProcessor<UpdateLayoutPositionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateLayoutPositionCommand command) {
    for (LayoutData element in command.layoutDataList) {
      IUiService().setLayoutPosition(layoutData: element);
    }

    return Future.value([]);
  }
}
