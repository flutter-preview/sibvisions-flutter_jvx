import '../../../../../../mixin/services.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/layout/register_parent_command.dart';
import '../../i_command_processor.dart';

class RegisterParentCommandProcessor with LayoutServiceMixin implements ICommandProcessor<RegisterParentCommand> {
  @override
  Future<List<BaseCommand>> processCommand(RegisterParentCommand command) {
    return getLayoutService().reportLayout(pLayoutData: command.layoutData);
  }
}
