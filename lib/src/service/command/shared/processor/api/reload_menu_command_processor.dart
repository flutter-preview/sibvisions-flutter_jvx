import '../../../../../../mixin/services.dart';
import '../../../../../model/command/api/reload_menu_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_reload_menu_request.dart';
import '../../i_command_processor.dart';

class ReloadMenuCommandProcessor with ApiServiceMixin implements ICommandProcessor<ReloadMenuCommand> {
  @override
  Future<List<BaseCommand>> processCommand(ReloadMenuCommand command) async {
    return getApiService().sendRequest(request: ApiReloadMenuRequest());
  }
}
