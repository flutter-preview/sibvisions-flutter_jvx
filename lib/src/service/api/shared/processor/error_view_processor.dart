import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/view/message/open_error_dialog_command.dart';
import '../../../../model/response/view/message/error_view_response.dart';
import '../i_response_processor.dart';

class ErrorViewProcessor implements IResponseProcessor<ErrorViewResponse> {
  @override
  List<BaseCommand> processResponse({required ErrorViewResponse pResponse}) {
    if (!pResponse.silentAbort) {
      return [
        OpenErrorDialogCommand(
          reason: "Server sent error in response",
          title: pResponse.title,
          message: pResponse.message,
          isTimeout: pResponse.isTimeout,
          canBeFixedInSettings: isUserError(pResponse.message!),
        )
      ];
    }
    return [];
  }

  /// Dirty error message check
  isUserError(String message) {
    if (message.toLowerCase().startsWith("invalid application:")) {
      return true;
    }
    return false;
  }
}
