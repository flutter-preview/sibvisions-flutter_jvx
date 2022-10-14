import '../../../../../model/command/api/open_screen_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/request/api_open_screen_request.dart';
import '../../../../api/i_api_service.dart';
import '../../i_command_processor.dart';

class OpenScreenCommandProcessor implements ICommandProcessor<OpenScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(OpenScreenCommand command) {
    return IApiService().sendRequest(
      ApiOpenScreenRequest(
        screenLongName: command.screenLongName,
        screenClassName: command.screenClassName,
        manualClose: true,
      ),
    );
  }
}
