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

import 'package:flutter/material.dart';

import '../../model/command/api/close_screen_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/menu/menu_item_model.dart';
import '../../model/menu/menu_model.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../frame/frame.dart';
import 'grid/grid_menu.dart';
import 'list/list_menu.dart';
import 'menu_page.dart';
import 'tab/tab_menu.dart';

abstract class Menu extends StatelessWidget {
  /// Model of this menu
  final MenuModel menuModel;

  /// Callback when a button was pressed
  final ButtonCallback onClick;

  const Menu({
    super.key,
    required this.menuModel,
    required this.onClick,
  });

  factory Menu.fromMode(
    MenuMode menuMode, {
    Key? key,
    required MenuModel menuModel,
    ButtonCallback onClick = Menu.menuItemPressed,
    bool grouped = false,
    bool sticky = true,
    bool groupOnlyOnMultiple = true,
  }) {
    switch (menuMode) {
      case MenuMode.LIST:
      case MenuMode.LIST_GROUPED:
        return ListMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: grouped,
          sticky: sticky,
          groupOnlyOnMultiple: groupOnlyOnMultiple,
        );
      case MenuMode.TABS:
        return TabMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
        );
      case MenuMode.GRID:
      case MenuMode.GRID_GROUPED:
        return GridMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: grouped,
          sticky: sticky,
          groupOnlyOnMultiple: groupOnlyOnMultiple,
        );
      case MenuMode.DRAWER:
      default:
        return GridMenu(
          key: key,
          menuModel: menuModel,
          onClick: onClick,
          grouped: true,
          sticky: true,
          groupOnlyOnMultiple: false,
        );
    }
  }

  static void menuItemPressed(BuildContext context, {required MenuItemModel item}) {
    // Always close drawer even on route (Flutter Bug sometimes breaks routing with open drawer)
    Scaffold.maybeOf(context)?.closeEndDrawer();

    // Offline screens no not require the server to know that they are open
    if (IUiService().usesNativeRouting(item.screenLongName)) {
      IUiService().routeToCustom(pFullPath: "/workScreen/${item.navigationName}");
    } else {
      IUiService().routeToWorkScreen(pScreenName: item.navigationName);
    }
  }

  /// Returns the action function based on the [item] parameter.
  static ButtonCallback? getCloseScreenAction(MenuItemModel item) {
    return IStorageService().getComponentByNavigationName(item.navigationName) != null
        ? (BuildContext context, {required MenuItemModel item}) async {
            // Always close drawer as this can prevent the navigator from correctly updating the screen.
            // https://github.com/sibvisions/flutter_jvx/issues/145
            Scaffold.maybeOf(context)?.closeEndDrawer();

            FlPanelModel? workscreenModel = IStorageService().getComponentByNavigationName(item.navigationName);
            if (workscreenModel != null) {
              await IUiService()
                  .sendCommand(
                    CloseScreenCommand(
                      screenName: workscreenModel.name,
                      reason: "User requested screen closing",
                    ),
                  )
                  .then((value) => Frame.of(context).rebuild());
            }
          }
        : null;
  }
}

enum MenuMode {
  GRID,
  // Legacy mode
  GRID_GROUPED,
  LIST,
  // Legacy mode
  LIST_GROUPED,
  DRAWER,
  TABS,
}
