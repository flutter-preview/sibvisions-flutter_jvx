import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../main.dart';
import '../../../mixin/config_service_mixin.dart';
import '../../../util/image/image_loader.dart';
import '../drawer/web_menu.dart';
import '../setting/settings_page.dart';
import 'frame.dart';

class WebFrame extends Frame {
  WebFrame({
    super.key,
    required super.builder,
  });

  @override
  void openSettings(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  FrameState createState() => WebFrameState();
}

class WebFrameState extends FrameState with ConfigServiceGetterMixin {
  static const double spacing = 15.0;
  bool showWebMenu = true;

  void toggleWebMenu() {
    showWebMenu = !showWebMenu;
    setState(() {});
  }

  @override
  PreferredSizeWidget getAppBar(List<Widget>? actions) {
    var profileImage = getConfigService().getUserInfo()?.profileImage;

    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars),
          onPressed: () => toggleWebMenu(),
        ),
      ),
      titleSpacing: 0.0,
      title: SizedBox(
        height: kToolbarHeight,
        child: Image.asset(
          ImageLoader.getAssetPath(
            FlutterJVx.package,
            'assets/images/logo.png',
          ),
          fit: BoxFit.scaleDown,
        ),
      ),
      centerTitle: false,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear),
            onPressed: () => widget.openSettings(context),
          ),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.key),
          onPressed: () => widget.changePassword(),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
          onPressed: () => widget.logout(),
        ),
        const Padding(padding: EdgeInsets.only(right: spacing)),
        Builder(builder: (context) {
          return CircleAvatar(
            backgroundColor: Theme.of(context).backgroundColor,
            backgroundImage: profileImage != null ? MemoryImage(profileImage) : null,
            child: profileImage == null
                ? FaIcon(
                    FontAwesomeIcons.solidUser,
                    color: Colors.grey.shade400,
                    size: 23,
                  )
                : null,
          );
        }),
        const Padding(padding: EdgeInsets.only(right: spacing)),
      ],
      backgroundColor: getConfigService().isOffline() ? Colors.grey.shade500 : null,
      elevation: getConfigService().isOffline() ? 0 : null,
    );
  }

  @override
  Widget wrapBody(Widget body) {
    return Builder(builder: (context) {
      return Row(children: [
        RepaintBoundary(
          child: WebMenu(
            showWebMenu: showWebMenu,
            onSettingsPressed: () => widget.openSettings(context),
            onChangePasswordPressed: widget.changePassword,
            onLogoutPressed: widget.logout,
          ),
        ),
        Expanded(
          flex: 1,
          child: body,
        ),
      ]);
    });
  }

  @override
  Widget? getEndDrawer() => Builder(
        builder: (context) => SizedBox(
          width: MediaQuery.of(context).size.width / 4,
          child: const SettingsPage(),
        ),
      );
}