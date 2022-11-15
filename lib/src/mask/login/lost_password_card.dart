import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/reset_password_command.dart';

/// Card to be displayed in app-login for resetting the password
class LostPasswordCard extends StatelessWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for Email/Username text field
  final TextEditingController identifierController = TextEditingController(text: "");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LostPasswordCard({super.key});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          FlutterJVx.translate("Welcome"),
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          FlutterJVx.translate("Please enter your e-mail address."),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        TextFormField(
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("Email")}:"),
          controller: identifierController,
          onFieldSubmitted: (_) => _sendRequest(),
        ),
        const Padding(padding: EdgeInsets.all(5)),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _sendRequest(),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.paperPlane),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(FlutterJVx.translate("Reset password")),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(2)),
            ElevatedButton(
              onPressed: () => context.beamBack(),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.arrowLeft),
                  const Padding(padding: EdgeInsets.all(5)),
                  Text(FlutterJVx.translate("Cancel")),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [ResetPasswordCommand]
  void _sendRequest() {
    ResetPasswordCommand resetPasswordCommand =
        ResetPasswordCommand(reason: "User reset password", identifier: identifierController.text);
    IUiService().sendCommand(resetPasswordCommand);
  }
}
