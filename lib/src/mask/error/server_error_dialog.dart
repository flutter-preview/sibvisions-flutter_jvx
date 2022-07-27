import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../../mixin/config_service_mixin.dart';

/// This is a standard template for a server side error message.
class ServerErrorDialog extends StatelessWidget with ConfigServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This message will be displayed in the popup
  final String message;

  /// True if this error is a timeout
  final bool isTimeout;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ServerErrorDialog({
    required this.message,
    this.isTimeout = false,
    Key? key,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor.withAlpha(255),
      title: Text(getConfigService().translateText("SERVER ERROR")),
      content: Text(message),
      actions: _getButtons(context),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Get all possible actions
  List<Widget> _getButtons(BuildContext context) {
    List<Widget> actions = [];

    if (isTimeout) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.beamToReplacementNamed("/setting");
          },
          child: Text(
            getConfigService().translateText("Go to Settings"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return actions;
    }

    actions.add(
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          "OK",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return actions;
  }
}
