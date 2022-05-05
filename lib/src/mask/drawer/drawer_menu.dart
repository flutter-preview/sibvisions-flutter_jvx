import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/mask/menu/list/app_menu_list_grouped.dart';
import 'package:flutter_client/src/mixin/config_service_mixin.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/menu/menu_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/command/api/open_screen_command.dart';

class DrawerMenu extends StatelessWidget with ConfigServiceMixin, UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold,
  );

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   DrawerMenu({
     Key? key,
   }) : super(key: key);

   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   // Overridden methods
   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).backgroundColor.withAlpha(255),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(child: _buildMenu(context)),
          ..._buildDrawerFooter(context),
        ],
      ),
    );
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Widget _buildDrawerHeader(BuildContext context){
    return DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderText(flex: 7, text: "Demo"),
                  const Padding(padding: EdgeInsets.all(4)),
                  _buildHeaderText(flex: 3, text: "Logged in as: "),
                  const Padding(padding: EdgeInsets.all(10)),
                  _buildHeaderText(flex: 5, text: "John Doe"),
                  const Expanded(flex: 2, child: Padding(padding: EdgeInsets.all(0)))
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: CircleAvatar(
                      child: FaIcon(FontAwesomeIcons.file),
                    ),
                  )
                ],
              ),
            )
          ],
        )
    );
  }

  Widget _buildMenu(BuildContext context){
    MenuModel menuModel = uiService.getMenuModel();
    return AppMenuListGrouped(
        menuModel: menuModel,
        onClick: _menuItemPressed
    );
  }

  List<Widget> _buildDrawerFooter(BuildContext context) {
    return [
      _buildFooterEntry(
        context: context,
        text: "Settings",
        leadingIcon: FontAwesomeIcons.cogs,
        onTap: () => log("asd"),
      ),
      Divider(color: Theme.of(context).primaryColor),
      _buildFooterEntry(
          context: context,
          text: "Change password",
          leadingIcon: FontAwesomeIcons.save,
          onTap: () => log("asd"),
      ),
      Divider(color: Theme.of(context).primaryColor),
      _buildFooterEntry(
          context: context,
          text: "Logout",
          leadingIcon: FontAwesomeIcons.signOutAlt,
          onTap: () => log("asd"),
      ),
    ];
  }

  /// Build a text used in the header of the drawer.
  /// Flex value changes size according to all other header texts(Expanded).
  /// Text will size itself to fill available space(Fitted-Box).
  Widget _buildHeaderText({required int flex, required String text}) {
     return Expanded(
       flex: flex,
       child: FittedBox(
         child: Text(
           text,
           style: boldStyle
         ),
       ),
     );
  }

  /// Build an entry used in the footer of the drawer.
  Widget _buildFooterEntry({
    required BuildContext context,
    required String text,
    required IconData leadingIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: FaIcon(leadingIcon),
      title: Text(text),
      trailing: const FaIcon(FontAwesomeIcons.arrowRight),
    );
  }
  
  void _menuItemPressed({required String componentId}) {
    OpenScreenCommand command = OpenScreenCommand(componentId: componentId, reason: "Menu Item was pressed");
    uiService.sendCommand(command);
  }


}