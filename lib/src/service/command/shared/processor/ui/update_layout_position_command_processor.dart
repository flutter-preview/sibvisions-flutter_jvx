import 'package:flutter/foundation.dart';

import '../../../../../mixin/ui_service_mixin.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/ui/update_layout_position_command.dart';
import '../../../../../model/layout/layout_data.dart';
import '../../i_command_processor.dart';

class UpdateLayoutPositionCommandProcessor
    with UiServiceGetterMixin
    implements ICommandProcessor<UpdateLayoutPositionCommand> {
  @override
  Future<List<BaseCommand>> processCommand(UpdateLayoutPositionCommand command) {
    for (LayoutData element in command.layoutDataList) {
      getUiService().setLayoutPosition(layoutData: element);
    }

    return SynchronousFuture([]);
  }
}