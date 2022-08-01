import '../../../../../mixin/config_service_mixin.dart';
import '../../../../model/command/base_command.dart';
import '../../../../model/command/ui/route_to_menu_command.dart';
import '../../../../model/command/ui/save_menu_command.dart';
import '../../../../model/menu/menu_group_model.dart';
import '../../../../model/menu/menu_item_model.dart';
import '../../../../model/menu/menu_model.dart';
import '../../../../model/response/menu_view_response.dart';
import '../i_response_processor.dart';

/// Processes the menu response into a [MenuModel], will try to route to menu,
/// if no other routing actions take precedent.
class MenuViewProcessor with ConfigServiceGetterMixin implements IResponseProcessor<MenuViewResponse> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BaseCommand> processResponse({required MenuViewResponse pResponse}) {
    List<BaseCommand> commands = [];
    MenuViewResponse response = pResponse;

    List<MenuGroupModel> groups = _isolateGroups(response);
    for (MenuGroupModel group in groups) {
      group.items.addAll(_getItemsByGroup(group.name, response.responseMenuItems));
    }
    MenuModel menuModel = MenuModel(menuGroups: groups);

    SaveMenuCommand saveMenuCommand = SaveMenuCommand(menuModel: menuModel, reason: "Server sent menu items");
    commands.add(saveMenuCommand);

    if (!getConfigService().isOffline()) {
      RouteToMenuCommand routeToMenuCommand = RouteToMenuCommand(reason: "Server sent a menu, likely on login");
      commands.add(routeToMenuCommand);
    }

    return commands;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  List<MenuGroupModel> _isolateGroups(MenuViewResponse menu) {
    List<MenuGroupModel> groups = [];
    for (MenuEntryResponse entry in menu.responseMenuItems) {
      if (!groups.any((element) => element.name == entry.group)) {
        groups.add(MenuGroupModel(name: entry.group, items: []));
      }
    }
    return groups;
  }

  List<MenuItemModel> _getItemsByGroup(String groupName, List<MenuEntryResponse> entries) {
    List<MenuItemModel> menuItems = [];
    for (MenuEntryResponse responseMenuEntry in entries) {
      if (responseMenuEntry.group == groupName) {
        MenuItemModel menuItem = MenuItemModel(
            screenId: responseMenuEntry.componentId, label: responseMenuEntry.text, image: responseMenuEntry.image);
        menuItems.add(menuItem);
      }
    }
    return menuItems;
  }
}
