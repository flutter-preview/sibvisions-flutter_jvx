import 'package:flutter_client/src/model/api/response/message_dialog_response.dart';
import 'package:flutter_client/src/model/command/base_command.dart';
import 'package:flutter_client/src/model/command/ui/open_message_dialog_command.dart';
import 'package:flutter_client/src/service/api/shared/i_processor.dart';

class MessageDialogProcessor implements IProcessor<MessageDialogResponse> {
  @override
  List<BaseCommand> processResponse({required MessageDialogResponse pResponse}) {
    return [
      OpenMessageDialogCommand(
        reason: "Message.dialog from server",
        message: pResponse.message,
        messageScreenName: pResponse.messageScreenName,
      )
    ];
  }
}
