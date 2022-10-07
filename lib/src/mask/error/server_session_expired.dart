import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/ui/view/message/open_session_expired_dialog_command.dart';
import '../frame_dialog.dart';

class ServerSessionExpired extends FrameDialog {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final OpenSessionExpiredDialogCommand command;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const ServerSessionExpired({
    required this.command,
    super.dismissible,
    super.key,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(command.title?.isNotEmpty == true ? command.title! : FlutterJVx.translate("Session Expired")),
      content: Text(command.message!),
      actions: [
        TextButton(
          onPressed: () => _restartApp(),
          child: Text(
            FlutterJVx.translate("Restart App"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _restartApp() {
    IUiService().closeFrameDialog(this);
    FlutterJVxState.of(FlutterJVx.getCurrentContext())?.restart();
  }
}
