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

import '../../../service/ui/i_ui_service.dart';
import 'open_screen_command.dart';
import 'session_command.dart';

class ReloadMenuCommand extends SessionCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String? screenLongName;

  final String? screenClassName;

  ReloadMenuCommand({
    required super.reason,
    this.screenLongName,
    this.screenClassName,
  }) {
    onFinish = () {
      if (screenLongName != null) {
        if (IUiService().getMenuModel().containsScreen(screenLongName!)) {
          IUiService().sendCommand(OpenScreenCommand(
            screenLongName: screenLongName!,
            reason: reason,
          ));
        }
      } else if (screenClassName != null) {
        if (IUiService().getMenuModel().getMenuItemByClassName(screenClassName!) != null) {
          IUiService().sendCommand(OpenScreenCommand(
            screenClassName: screenClassName!,
            reason: reason,
          ));
        }
      }
    };
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String toString() {
    return "ReloadMenuCommand{${super.toString()}}";
  }
}
