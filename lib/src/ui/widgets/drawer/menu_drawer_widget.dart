import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/models/api/requests/change_password_request.dart';
import 'package:flutterclient/src/ui/widgets/dialog/change_password_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../models/api/response_objects/menu/menu_item.dart';
import '../../../models/state/app_state.dart';
import '../../../models/state/routes/pop_arguments/open_screen_page_pop_style.dart';
import '../../../util/color/color_extension.dart';
import '../../../util/translation/app_localizations.dart';
import '../custom/custom_drawer_header.dart';
import '../custom/custom_icon.dart';

class MenuDrawerWidget extends StatefulWidget {
  final List<MenuItem> menuItems;
  final bool groupedMenuMode;
  final bool listMenuItems;
  final String title;
  final AppState appState;
  final void Function(MenuItem) onMenuItemPressed;
  final Function onLogoutPressed;
  final Function onSettingsPressed;

  const MenuDrawerWidget(
      {Key? key,
      this.groupedMenuMode = true,
      this.listMenuItems = true,
      required this.menuItems,
      required this.title,
      required this.appState,
      required this.onMenuItemPressed,
      required this.onLogoutPressed,
      required this.onSettingsPressed})
      : super(key: key);

  @override
  _MenuDrawerWidgetState createState() => _MenuDrawerWidgetState();
}

class _MenuDrawerWidgetState extends State<MenuDrawerWidget> {
  Uint8List? decodedImage;

  _buildListViewForDrawer(BuildContext context, List<MenuItem> menuItems) {
    List<Widget> tiles = <Widget>[];
    ListTile? groupHeader;
    List<Widget> groupItems = <Widget>[];

    if (widget.listMenuItems) {
      String lastGroupName = "";
      for (int i = 0; i < menuItems.length; i++) {
        MenuItem item = menuItems[i];

        if (widget.groupedMenuMode &&
            item.group.isNotEmpty &&
            item.group != lastGroupName) {
          if (groupItems.isNotEmpty) {
            tiles.add(getStickyHeaderGroup(groupHeader!, groupItems));
            groupHeader = null;
            groupItems = <Widget>[];
          }

          groupHeader = getGroupHeader(item);
          lastGroupName = item.group;
        }

        groupItems.add(ListTile(
          title: Text(
            item.text,
            overflow: TextOverflow.ellipsis,
          ),
          leading: item.image != null
              ? new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: CustomIcon(
                      image: item.image!, prefferedSize: Size(32, 32)))
              : new CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: FaIcon(
                    FontAwesomeIcons.clone,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  )),
          onTap: () {
            if (widget.appState.currentMenuComponentId != item.componentId) {
              Navigator.of(context).pop(OpenScreenPagePopStyle.POP);

              widget.onMenuItemPressed(item);
            }
          },
        ));

        if (i < (menuItems.length - 1)) groupItems.add(Divider(height: 1));
      }
    }

    if (groupHeader != null && groupItems.length > 0) {
      tiles.add(getStickyHeaderGroup(groupHeader, groupItems));
      groupHeader = null;
      groupItems = <Widget>[];
    } else if (groupItems.length > 0) {
      tiles.addAll(groupItems);
    }

    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: tiles,
        ));
  }

  ListTile getGroupHeader(MenuItem item) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        title: Text(item.group,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            )));
  }

  StickyHeader getStickyHeaderGroup(Widget child, List<Widget> content) {
    return StickyHeader(
      header: Container(
        color: Colors.white,
        child: child,
      ),
      content: Container(
        child: Column(children: content),
      ),
    );
  }

  _buildDrawerHeader() {
    return CustomDrawerHeader(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
        drawerHeaderHeight: 151,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
                width: 160,
                height: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _getAppName(),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.appState.userData?.username != null &&
                                  widget.appState.userData!.username.isNotEmpty
                              ? Text(
                                  AppLocalizations.of(context)!
                                      .text('Logged in as'),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .textColor(),
                                      fontSize: 12),
                                )
                              : Container(),
                          _getUsername()
                        ])
                  ],
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[_getAvatar()],
            )
          ],
        ));
  }

  Widget _getAppName() {
    String appName = widget.appState.serverConfig!.appName;

    if (widget.appState.applicationStyle != null &&
        widget.appState.applicationStyle?.loginStyle?.title != null) {
      appName = widget.appState.applicationStyle!.loginStyle!.title!;
    }

    return AutoSizeText(appName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 16,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor.textColor(),
        ));
  }

  Widget _getUsername() {
    if (widget.appState.userData != null) {
      String username = widget.appState.userData!.username;
      if (widget.appState.userData?.displayName != null)
        username = widget.appState.userData!.displayName;

      //username = 'Max Mustermann Junior';

      return AutoSizeText(username,
          maxLines: 2,
          overflow: TextOverflow.clip,
          style: TextStyle(
              color: Theme.of(context).primaryColor.textColor(), fontSize: 23),
          minFontSize: 18);
    }

    return Text('');
  }

  ImageProvider getProfileImage() {
    Image img = Image.memory(
      decodedImage!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );

    return img.image;
  }

  Widget _getAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: widget.appState.userData?.profileImage != null &&
              widget.appState.userData!.profileImage.isNotEmpty
          ? getProfileImage()
          : null,
      child: widget.appState.userData?.profileImage != null &&
              widget.appState.userData!.profileImage.isNotEmpty
          ? null
          : FaIcon(
              FontAwesomeIcons.userTie,
              color: Theme.of(context).primaryColor,
              size: 60,
            ),
      radius: 55,
    );
  }

  @override
  void initState() {
    if (widget.appState.userData?.profileImage != null) {
      decodedImage = base64Decode(widget.appState.userData!.profileImage);
    }
    super.initState();
  }

  List<Widget> getBottomMenuItems() {
    List<Widget> items = <Widget>[];

    items.add(Divider(
      height: 1,
    ));

    if (!widget.appState.isOffline) {
      items.add(ListTile(
        title: Text(
          AppLocalizations.of(context)!.text('Change Password'),
          style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
        ),
        leading: FaIcon(
          FontAwesomeIcons.key,
          color: Theme.of(context).primaryColor.textColor(),
        ),
        onTap: () async {
          await showDialog(
              context: context,
              builder: (_) => ChangePasswordDialog(
                    username: widget.appState.userData?.username ?? '',
                    clientId: widget.appState.applicationMetaData!.clientId,
                    login: false,
                  ));
        },
      ));
      items.add(Divider(
        height: 1,
        color: Theme.of(context).primaryColor.textColor(),
      ));
    }

    items.add(ListTile(
      title: Text(
        AppLocalizations.of(context)!.text('Settings'),
        style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
      ),
      leading: FaIcon(
        FontAwesomeIcons.cog,
        color: Theme.of(context).primaryColor.textColor(),
      ),
      onTap: () {
        widget.onSettingsPressed();
      },
    ));

    items.add(Divider(
      height: 1,
      color: Theme.of(context).primaryColor.textColor(),
    ));

    items.add(ListTile(
      title: Text(
        AppLocalizations.of(context)!.text('Logout'),
        style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
      ),
      leading: FaIcon(
        FontAwesomeIcons.signOutAlt,
        color: Theme.of(context).primaryColor.textColor(),
      ),
      onTap: () => widget.onLogoutPressed(),
    ));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            flex: 2,
            child: _buildListViewForDrawer(context, widget.menuItems),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: Column(children: getBottomMenuItems()),
          )
        ],
      ),
    );
  }
}