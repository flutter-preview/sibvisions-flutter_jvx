/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import '../../../flutter_ui.dart';
import '../../../service/ui/i_ui_service.dart';
import 'api_command.dart';

class StartupCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The username for auto-login.
  ///
  /// This can be used to override the default values from the config.
  final String? username;

  /// The password for auto-login.
  ///
  /// This can be used to override the default values from the config.
  final String? password;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  StartupCommand({
    this.username,
    this.password,
    super.showLoading,
    required super.reason,
  }) {
    beforeProcessing = () => IUiService().getAppManager()?.onInitStartup();
    afterProcessing = () async {
      FlutterUI.clearHistory();
    };
    onFinish = () {
      FlutterUI.clearLocationHistory();
      IUiService().getAppManager()?.onSuccessfulStartup();
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "StartupCommand{username: $username, ${super.toString()}}";
  }
}
