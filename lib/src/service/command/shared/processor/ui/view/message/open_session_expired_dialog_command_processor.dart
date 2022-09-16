import 'dart:async';

import '../../../../../../../../mixin/services.dart';
import '../../../../../../../mask/error/server_session_expired.dart';
import '../../../../../../../model/command/base_command.dart';
import '../../../../../../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../../../../i_command_processor.dart';

class OpenSessionExpiredDialogCommandProcessor extends ICommandProcessor<OpenSessionExpiredDialogCommand>
    with UiServiceMixin {
  @override
  Future<List<BaseCommand>> processCommand(OpenSessionExpiredDialogCommand command) async {
    unawaited(getUiService().openDialog(
      pBuilder: (_) => ServerSessionExpired(command: command),
      pIsDismissible: false,
    ));

    return [];
  }
}
