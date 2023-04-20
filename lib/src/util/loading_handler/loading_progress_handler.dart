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

import '../../flutter_ui.dart';
import '../../mask/jvx_overlay.dart';
import '../../model/command/base_command.dart';
import '../../service/config/config_controller.dart';
import 'i_command_progress_handler.dart';

/// The [LoadingProgressHandler] triggers the [LoadingBar] through the [JVxOverlay] when a command
/// reaches its defined wait threshold before completing.
class LoadingProgressHandler implements ICommandProgressHandler {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Amount of commands that have called for a loading progress.
  int _loadingCommandAmount = 0;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void notifyProgressStart(BaseCommand pCommand) {
    if (isSupported(pCommand) && !ConfigController().offline.value) {
      _loadingCommandAmount++;
      JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.showLoading(pCommand.loadingDelay);
    }
  }

  @override
  void notifyProgressEnd(BaseCommand pCommand) {
    if (isSupported(pCommand)) {
      if (_loadingCommandAmount > 0) {
        _loadingCommandAmount--;
      }
      if (_loadingCommandAmount == 0) {
        JVxOverlay.maybeOf(FlutterUI.getCurrentContext())?.hideLoading();
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool isSupported(BaseCommand pCommand) {
    return pCommand.showLoading;
  }
}
