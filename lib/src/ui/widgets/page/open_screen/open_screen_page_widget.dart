import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_object.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/data/data_book.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/data/dataprovider_changed.dart';

import '../../../../../injection_container.dart';
import '../../../../models/api/requests/close_screen_request.dart';
import '../../../../models/api/requests/device_status_request.dart';
import '../../../../models/api/requests/logout_request.dart';
import '../../../../models/api/requests/navigation_request.dart';
import '../../../../models/api/requests/open_screen_request.dart';
import '../../../../models/api/response_objects/close_screen_action_response_object.dart';
import '../../../../models/api/response_objects/device_status_response_object.dart';
import '../../../../models/api/response_objects/download_action_response_object.dart';
import '../../../../models/api/response_objects/menu/menu_item.dart';
import '../../../../models/api/response_objects/response_data/screen_generic_response_object.dart';
import '../../../../models/api/response_objects/upload_action_response_object.dart';
import '../../../../models/state/app_state.dart';
import '../../../../models/state/routes/arguments/login_page_arguments.dart';
import '../../../../models/state/routes/default_page.dart';
import '../../../../models/state/routes/routes.dart';
import '../../../../services/local/shared_preferences/shared_preferences_manager.dart';
import '../../../../services/remote/cubit/api_cubit.dart';
import '../../../../util/app/listener/listener.dart';
import '../../../../util/app/text_utils.dart';
import '../../../screen/core/configuration/so_screen_configuration.dart';
import '../../../screen/core/so_component_creator.dart';
import '../../../screen/core/so_screen.dart';
import '../../../util/error/custom_bloc_listener.dart';
import '../../drawer/menu_drawer_widget.dart';

class OpenScreenPageWidget extends StatefulWidget {
  final AppState appState;
  final SharedPreferencesManager manager;
  final SoScreen screen;

  const OpenScreenPageWidget({
    Key? key,
    required this.appState,
    required this.manager,
    required this.screen,
  }) : super(key: key);

  @override
  _OpenScreenPageWidgetState createState() => _OpenScreenPageWidgetState();
}

class _OpenScreenPageWidgetState extends State<OpenScreenPageWidget>
    with WidgetsBindingObserver {
  List<DefaultPage> _pages = <DefaultPage>[];
  List<SoScreen> _screens = <SoScreen>[];

  late String _currentComponentId;
  ApiResponse? _response;

  late Size _lastScreenSize;
  late Timer _deviceStatusTimer;

  MenuDrawerWidget getMenuDrawer(String title) => MenuDrawerWidget(
        appState: widget.appState,
        menuItems: widget.appState.menuResponseObject.entries,
        onLogoutPressed: _onLogoutPressed,
        onMenuItemPressed: _onMenuItemPressed,
        onSettingsPressed: () =>
            Navigator.of(context).pushNamed(Routes.settings),
        title: title,
      );

  void _listener(BuildContext context, ApiState state) {
    if (state is ApiResponse) {
      _response = state;

      if (state.hasDataObject || state.hasObject<ScreenGenericResponseObject>())
        _updateScreens(state);

      if (state.request is LogoutRequest) {
        Navigator.of(context).pushNamed(Routes.login,
            arguments: LoginPageArguments(lastUsername: ''));
      } else if (state.request is NavigationRequest &&
          !state.hasObject<ScreenGenericResponseObject>()) {
        _pages.removeLast();

        if (_pages.isEmpty) {
          _screens.removeLast();
          Navigator.of(context).pop();
        }
      } else if (state.request is CloseScreenRequest &&
          !state.hasObject<ScreenGenericResponseObject>()) {
        _pages.removeLast();

        if (_pages.isEmpty) {
          _screens.removeLast();
          Navigator.of(context).pop();
        }
      }

      if (state.hasObject<ScreenGenericResponseObject>()) {
        ScreenGenericResponseObject screenGeneric =
            state.getObjectByType<ScreenGenericResponseObject>()!;

        if (screenGeneric.changedComponents.isNotEmpty) {
          SoScreen? screenToUpdate;
          try {
            screenToUpdate = _screens.firstWhere((screen) =>
                screen.configuration.componentId == screenGeneric.componentId);
          } catch (_) {}

          if (screenToUpdate == null) {
            addPage(widget.appState.screenManager.createScreen(
                onPopPage: _onPopPage,
                response: state,
                drawer: getMenuDrawer(state
                    .getObjectByType<ScreenGenericResponseObject>()!
                    .screenTitle!)));
          }
        } else if (!screenGeneric.update) {
          SoScreen soScreen = _screens.firstWhere((screen) =>
              screen.configuration.componentId == screenGeneric.componentId);

          addPage(soScreen, register: false);
        }
      }

      if (state.hasObject<CloseScreenActionResponseObject>()) {
        setState(() {
          _screens.removeWhere((screen) {
            if (screen.configuration.componentId ==
                state
                    .getObjectByType<CloseScreenActionResponseObject>()!
                    .componentId) {
              _pages.removeWhere((page) => page.child == screen);
              return true;
            }

            return false;
          });
        });

        if (_pages.isEmpty) {
          Navigator.of(context).pop();
        }
      }

      if (state.hasObject<DeviceStatusResponseObject>()) {
        setState(() {
          widget.appState.deviceStatus =
              state.getObjectByType<DeviceStatusResponseObject>()!;
        });
      }

      if (state.hasObject<DownloadActionResponseObject>()) {}

      if (state.hasObject<UploadActionResponseObject>()) {}
    }
  }

  void _updateScreens(ApiResponse response) {
    for (final screen in _screens) {
      screen.configuration.value = response;
    }
  }

  void addPage(SoScreen screen, {bool register = true}) {
    if (register) {
      _screens.add(screen);
    }

    if (mounted) {
      setState(() {
        _pages.add(DefaultPage(
            name: screen.configuration.componentId,
            arguments: screen.configuration.value,
            key: ValueKey(screen.configuration.componentId),
            child: screen));
      });
    } else {
      _pages.add(DefaultPage(
          name: screen.configuration.componentId,
          arguments: screen.configuration.value,
          key: ValueKey(screen.configuration.componentId),
          child: screen));
    }
  }

  void addAllScreens(List<SoScreen> screensToAdd) {
    if (screensToAdd.isNotEmpty) {
      screensToAdd.forEach((screen) => addPage(screen));
    }
  }

  void _onPopPage(String componentId) {
    NavigationRequest request = NavigationRequest(
        clientId: widget.appState.applicationMetaData!.clientId,
        componentId: (_pages.last.child as SoScreen).configuration.componentId);

    sl<ApiCubit>().navigation(request);
  }

  void _onLogoutPressed() {
    LogoutRequest request =
        LogoutRequest(clientId: widget.appState.applicationMetaData!.clientId);

    sl<ApiCubit>().logout(request);
  }

  void _onMenuItemPressed(MenuItem menuItem) {
    if (menuItem.componentId != widget.appState.currentMenuComponentId) {
      OpenScreenRequest request = OpenScreenRequest(
          clientId: widget.appState.applicationMetaData!.clientId,
          componentId: menuItem.componentId);

      sl<ApiCubit>().openScreen(request);
    }
  }

  void _addInitialScreen(SoScreen screen) {
    if (screen.configuration.value != null)
      _response = screen.configuration.value as ApiResponse;

    if (screen.configuration.onPopPage == null) {
      screen.configuration.onPopPage = _onPopPage;
    }

    screen.configuration.drawer =
        getMenuDrawer(screen.configuration.screenTitle);

    _currentComponentId = screen.configuration.componentId;

    addPage(screen);
  }

  void _addDeviceStatusTimer(BuildContext context) {
    Size currentSize = MediaQuery.of(context).size;

    if (_lastScreenSize.height != currentSize.height ||
        _lastScreenSize.width != currentSize.width) {
      if (_deviceStatusTimer.isActive) {
        _deviceStatusTimer.cancel();
      }

      _deviceStatusTimer = Timer(const Duration(milliseconds: 300), () {
        DeviceStatusRequest request = DeviceStatusRequest(
            clientId: widget.appState.applicationMetaData!.clientId,
            screenSize: currentSize,
            timeZoneCode: '',
            langCode: '');

        _lastScreenSize = currentSize;

        sl<ApiCubit>().deviceStatus(request);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.appState.listener != null) {
      widget.appState.listener!
          .fireAfterStartupListener(ApplicationApi(context));
    }

    _addInitialScreen(widget.screen);

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _lastScreenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _addDeviceStatusTimer(context);

    return WillPopScope(
      onWillPop: () async {
        NavigationRequest request = NavigationRequest(
            clientId: widget.appState.applicationMetaData!.clientId,
            componentId:
                (_pages.last.child as SoScreen).configuration.componentId);

        await sl<ApiCubit>().navigation(request);

        return false;
      },
      child: GestureDetector(
        onTap: () => TextUtils.unfocusCurrentTextfield(context),
        child: CustomCubitListener(
          appState: widget.appState,
          bloc: sl<ApiCubit>(),
          listener: _listener,
          child: _pages.isNotEmpty
              ? Navigator(
                  pages: [..._pages],
                  onPopPage: (Route<dynamic> route, dynamic val) {
                    NavigationRequest request = NavigationRequest(
                        clientId: widget.appState.applicationMetaData!.clientId,
                        componentId: (_pages.last.child as SoScreen)
                            .configuration
                            .componentId);

                    sl<ApiCubit>().navigation(request);

                    return false;
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}
