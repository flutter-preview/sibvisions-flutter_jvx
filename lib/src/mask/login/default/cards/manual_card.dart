import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../flutter_jvx.dart';
import '../../../../../services.dart';
import '../../../../../util/jvx_colors.dart';
import '../../../../../util/progress/progress_button.dart';
import '../../../../model/command/api/login_command.dart';
import '../remember_me_checkbox.dart';

class ManualCard extends StatefulWidget {
  const ManualCard({super.key});

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
  /// Controller for username text field
  late TextEditingController usernameController;

  /// Controller for password text field
  late TextEditingController passwordController;

  /// Value holder for the checkbox
  late bool rememberMeChecked;

  ButtonState progressButtonState = ButtonState.idle;

  bool showRememberMe = false;
  bool _passwordHidden = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: IConfigService().getUsername());
    passwordController = TextEditingController();
    rememberMeChecked = IConfigService().getAppConfig()?.uiConfig!.rememberMeChecked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    String? loginTitle = AppStyle.of(context)!.applicationStyle!['login.title'];

    showRememberMe = (IConfigService().getMetaData()?.rememberMeEnabled ?? false) ||
        (IConfigService().getAppConfig()?.uiConfig!.showRememberMe ?? false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loginTitle ?? IConfigService().getAppName()!.toUpperCase(),
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        TextField(
          textInputAction: TextInputAction.next,
          onTap: resetButton,
          onChanged: (_) => resetButton(),
          controller: usernameController,
          decoration: InputDecoration(labelText: "${FlutterJVx.translate("Username")}:"),
        ),
        TextField(
          textInputAction: TextInputAction.done,
          onTap: resetButton,
          onChanged: (_) => resetButton(),
          onSubmitted: (_) => _onLoginPressed(),
          controller: passwordController,
          decoration: InputDecoration(
            labelText: "${FlutterJVx.translate("Password")}:",
            suffixIcon: IconButton(
              icon: Icon(
                _passwordHidden ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordHidden = !_passwordHidden;
                });
              },
            ),
          ),
          obscureText: _passwordHidden,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (showRememberMe)
          Center(
            child: RememberMeCheckbox(
              rememberMeChecked,
              onToggle: () => setState(() => rememberMeChecked = !rememberMeChecked),
            ),
          ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        ProgressButton.icon(
          radius: 4.0,
          progressIndicator: CircularProgressIndicator.adaptive(
            backgroundColor: JVxColors.toggleColor(Theme.of(context).colorScheme.onPrimary),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          stateButtons: {
            ButtonState.idle: StateButton(
              child: IconedButton(
                text: FlutterJVx.translate("Login"),
                icon: const Icon(Icons.login),
              ),
            ),
            ButtonState.fail: StateButton(
              color: Colors.red.shade600,
              textStyle: const TextStyle(color: Colors.white),
              child: IconedButton(
                text: FlutterJVx.translate("Failed"),
                icon: const Icon(Icons.cancel),
              ),
            ),
          },
          onPressed: _onLoginPressed,
          state: LoadingBar.of(context)?.show ?? false ? ButtonState.loading : progressButtonState,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
        if (IConfigService().getMetaData()?.lostPasswordEnabled == true)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => IUiService().routeToLogin(mode: LoginMode.LostPassword),
              child: Text(
                "${FlutterJVx.translate("Reset password")}?",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        _createBottomRow(),
      ],
    );
  }

  void resetButton() {
    setState(() => progressButtonState = ButtonState.idle);
  }

  Widget _createBottomRow() {
    Widget textButton = TextButton.icon(
      onPressed: () => IUiService().routeToSettings(),
      icon: const FaIcon(FontAwesomeIcons.gear),
      label: Text(
        FlutterJVx.translate("Settings"),
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: textButton,
    );
  }

  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();

    LoginPage.doLogin(
      username: usernameController.text,
      password: passwordController.text,
      createAuthKey: showRememberMe && rememberMeChecked,
    ).catchError((error, stackTrace) {
      setState(() => progressButtonState = ButtonState.fail);
      return IUiService().handleAsyncError(error, stackTrace);
    });
  }
}