import 'dart:async';

import '../../../../../mixin/storage_service_mixin.dart';
import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/storage/delete_screen_command.dart';
import '../../i_command_processor.dart';

class DeleteScreenProcessor
    with StorageServiceMixin, UiServiceGetterMixin
    implements ICommandProcessor<DeleteScreenCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DeleteScreenCommand command) async {
    await storageService.deleteScreen(screenName: command.screenName);
    getUiService().closeScreen(pScreenName: command.screenName);

    return [];
  }
}
