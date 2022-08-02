import 'package:flutter/material.dart';

import 'custom_component.dart';
import 'custom_menu_item.dart';

/// Super class for Custom screens
class CustomScreen {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Title displayed on the top of the screen
  final String? screenTitle;

  /// Builder function for custom header
  final PreferredSizeWidget Function(BuildContext)? buildHeader;

  /// Builder function which returns the custom screen
  final Widget Function(BuildContext)? buildScreen;

  /// Builder function for custom footer
  final Widget Function(BuildContext)? buildFooter;

  /// The menu item to access this screen, if this is left null, will use the
  final CustomMenuItem menuItemModel;

  /// List with components that should be replaced in this screen
  final List<CustomComponent> replaceComponents;

  /// True if this screen is shown in online mode
  final bool showOnline;

  /// True if this screen is shown in offline mode
  final bool showOffline;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const CustomScreen({
    this.showOnline = true,
    this.showOffline = false,
    this.buildScreen,
    this.buildHeader,
    this.buildFooter,
    required this.menuItemModel,
    this.screenTitle,
    this.replaceComponents = const [],
  });
}
