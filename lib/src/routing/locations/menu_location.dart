import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import '../../../mixin/config_service_mixin.dart';
import '../../../mixin/ui_service_mixin.dart';
import '../../mask/frame/frame.dart';
import '../../mask/menu/app_menu.dart';

/// Displays all possible screens of the menu
class MenuLocation extends BeamLocation<BeamState> with ConfigServiceGetterMixin, UiServiceGetterMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    String sValue = "Menu_${getConfigService().isOffline() ? "offline" : "online"}";

    getUiService().getAppManager()?.onMenu();

    final GlobalKey childKey = GlobalKey();

    return [
      BeamPage(
        //Append state to trigger rebuild on online/offline switch
        key: ValueKey(sValue),
        child: Frame.wrapWithFrame(childKey: childKey, child: AppMenu(key: childKey)),
      ),
    ];
  }

  @override
  List<Pattern> get pathPatterns => [
        '/menu',
      ];
}
