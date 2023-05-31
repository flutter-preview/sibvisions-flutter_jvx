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

import 'package:beamer/beamer.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/components_factory.dart';
import '../../components/panel/fl_panel_wrapper.dart';
import '../../custom/custom_screen.dart';
import '../../exceptions/error_view_exception.dart';
import '../../flutter_ui.dart';
import '../../model/command/api/close_screen_command.dart';
import '../../model/command/api/navigation_command.dart';
import '../../model/command/api/open_screen_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/model_subscription.dart';
import '../../model/menu/menu_item_model.dart';
import '../../service/command/i_command_service.dart';
import '../../service/config/i_config_service.dart';
import '../../service/layout/i_layout_service.dart';
import '../../service/storage/i_storage_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../../util/offline_util.dart';
import '../../util/parse_util.dart';
import '../frame/frame.dart';
import '../state/app_style.dart';
import '../state/loading_bar.dart';

/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class WorkScreen extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// ScreenName of an online-screen - used for sending [ApiNavigationRequest]
  final String screenName;

  const WorkScreen({
    super.key,
    required this.screenName,
  });

  static Widget buildBackground(Color? backgroundColor, String? backgroundImage) {
    return SizedBox.expand(
      child: Container(
        color: backgroundColor,
        child: Center(
          child: backgroundImage != null
              ? ImageLoader.loadImage(
                  backgroundImage,
                  pFit: BoxFit.scaleDown,
                )
              : null,
        ),
      ),
    );
  }

  @override
  WorkScreenState createState() => WorkScreenState();
}

class WorkScreenState extends State<WorkScreen> {
  /// Debounce re-layouts if keyboard opens.
  final BehaviorSubject<Size> subject = BehaviorSubject<Size>();
  FlPanelModel? model;

  /// Title displayed on the top
  String screenTitle = "Loading...";

  /// Navigating booleans.
  bool isNavigating = false;
  bool isForced = false;

  bool sentScreen = false;

  MenuItemModel? item;
  Future<void>? future;

  CustomScreen? customScreen;

  String get screenLongName => item?.screenLongName ?? widget.screenName;

  @override
  void initState() {
    super.initState();

    IUiService().getAppManager()?.onScreenPage(widget.screenName);
    subject.throttleTime(const Duration(milliseconds: 8), trailing: true).listen((size) => _setScreenSize(size));

    item = IUiService().getMenuItem(widget.screenName);
    if (item != null) {
      String className = IStorageService().convertLongScreenToClassName(item!.screenLongName);

      model = IStorageService().getComponentByScreenClassName(pScreenClassName: item!.screenLongName);
      customScreen = IUiService().getCustomScreen(item!.screenLongName);

      // Listen to new models with the same class names (needed for work screen reload, model id changes)
      IUiService().registerModelSubscription(ModelSubscription(
        subbedObj: this,
        check: (model) => model is FlPanelModel && model.screenClassName == className,
        onNewModel: (model) {
          if (model.id != this.model?.id) {
            this.model = model as FlPanelModel?;
            FlutterUI.logUI.d("Received new model for className: $className");
            rebuild();
          }
        },
      ));

      _initScreen();
    }
  }

  void _initScreen() {
    future = () async {
      // Send only if model is missing (which it always is in a custom screen) and the possible custom screen has send = true.
      if (model == null &&
          (customScreen == null || (customScreen!.sendOpenScreenRequests && !IConfigService().offline.value))) {
        await ICommandService().sendCommand(OpenScreenCommand(
          screenLongName: item!.screenLongName,
          reason: "Screen was opened",
        ));
      }
    }()
        .catchError((e, stack) {
      FlutterUI.log.e("Open screen failed", e, stack);
      if (e is ErrorViewException) {
        // Server failed to open this screen, beam back to old location.
        context.beamBack();
      }
      throw e;
    });
  }

  @override
  void dispose() {
    subject.close();
    IUiService().disposeSubscriptions(pSubscriber: this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WorkScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    sentScreen = false;
  }

  void rebuild() {
    IUiService().closeJVxDialogs();

    Navigator.of(FlutterUI.getCurrentContext()!).popUntil((route) => route is! PopupRoute);

    sentScreen = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Frame.wrapWithFrame(
      builder: (context, isOffline) {
        return WillPopScope(
          onWillPop: () => _onWillPop(context),
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              FrameState? frame = Frame.maybeOf(context);
              List<Widget>? actions = frame?.getActions();

              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                Widget body = _buildBody(context, isOffline);
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: frame?.getAppBar(
                    leading: _buildLeading(),
                    titleSpacing: 0,
                    title: Text(screenTitle),
                    actions: actions,
                  ),
                  drawerEnableOpenDragGesture: false,
                  endDrawerEnableOpenDragGesture: false,
                  drawer: frame?.getDrawer(context),
                  endDrawer: frame?.getEndDrawer(context),
                  body: frame?.wrapBody(body) ?? body,
                );
              } else {
                Widget body;
                if (snapshot.connectionState == ConnectionState.none) {
                  // Invalid screen name
                  body = Center(
                    child: Text(
                      FlutterUI.translate("Screen not found."),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  body = Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: snapshot.error.toString(),
                          child: Text(
                            FlutterUI.translate("Error occurred while opening the screen."),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (item != null) const SizedBox(height: 20),
                        if (item != null)
                          ElevatedButton(
                            onPressed: () {
                              _initScreen();
                              setState(() {});
                            },
                            child: Text(FlutterUI.translate("Retry")),
                          )
                      ],
                    ),
                  );
                } else {
                  const Duration animationDuration = Duration(milliseconds: 750 + 550);
                  const Duration animationDurationTwo = Duration(milliseconds: 450 + 550);
                  body = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CardLoading(
                        height: 25,
                        width: 100,
                        animationDuration: animationDuration,
                        animationDurationTwo: animationDurationTwo,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        margin: EdgeInsets.only(bottom: 10),
                      ),
                      CardLoading(
                        height: 50,
                        animationDuration: animationDuration,
                        animationDurationTwo: animationDurationTwo,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        margin: EdgeInsets.only(bottom: 10),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CardLoading(
                          height: 50,
                          width: 120,
                          animationDuration: animationDuration,
                          animationDurationTwo: animationDurationTwo,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      CardLoading(
                        height: 25,
                        width: 100,
                        animationDuration: animationDuration,
                        animationDurationTwo: animationDurationTwo,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        margin: EdgeInsets.only(bottom: 10),
                      ),
                      Expanded(
                        child: CardLoading(
                          height: double.infinity,
                          animationDuration: animationDuration,
                          animationDurationTwo: animationDurationTwo,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                    ],
                  );
                }

                body = Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: body,
                );

                // Skeleton scaffold shown while loading.
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: frame?.getAppBar(
                    leading: _buildLeading(),
                    titleSpacing: 0,
                    title: Text(customScreen?.screenTitle ?? item?.label ?? FlutterUI.translate(screenTitle)),
                    actions: actions,
                  ),
                  drawerEnableOpenDragGesture: false,
                  endDrawerEnableOpenDragGesture: false,
                  drawer: frame?.getDrawer(context),
                  endDrawer: frame?.getEndDrawer(context),
                  body: frame?.wrapBody(body) ?? body,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLeading() {
    return InkResponse(
      radius: kToolbarHeight / 2,
      onTap: () => _onBack(),
      onDoubleTap: () => _onBack(true),
      child: Tooltip(
        message: MaterialLocalizations.of(context).backButtonTooltip,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: BackButtonIcon()),
        ),
      ),
    );
  }

  Widget _wrapJVxScreen(
    BuildContext context,
    WrappedScreen wrappedScreen,
  ) {
    var appStyle = AppStyle.of(context).applicationStyle;
    Color? backgroundColor = ParseUtil.parseHexColor(appStyle?['desktop.color']);
    String? backgroundImageString = appStyle?['desktop.icon'];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // If true, rebuilds and therefore can activate scrolling or not.
      appBar: wrappedScreen.header,
      bottomNavigationBar: wrappedScreen.footer,
      backgroundColor: Colors.transparent,
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) => LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = EdgeInsets.fromWindowPadding(
              WidgetsBinding.instance.window.viewInsets,
              WidgetsBinding.instance.window.devicePixelRatio,
            );

            final viewPadding = EdgeInsets.fromWindowPadding(
              WidgetsBinding.instance.window.viewPadding,
              WidgetsBinding.instance.window.devicePixelRatio,
            );

            double screenHeight = constraints.maxHeight;

            if (isKeyboardVisible) {
              screenHeight += viewInsets.bottom;
              screenHeight -= viewPadding.bottom;
            }

            Widget screenWidget = wrappedScreen.screen!;
            if (!wrappedScreen.customScreen && screenWidget is FlPanelWrapper) {
              Size size = Size(constraints.maxWidth, screenHeight);
              if (!sentScreen) {
                _setScreenSize(size);
                sentScreen = true;
              } else {
                subject.add(size);
              }
            } else {
              // Wrap custom screen in Positioned
              screenWidget = Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: screenWidget,
              );
            }
            return SingleChildScrollView(
              physics: isKeyboardVisible ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Stack(
                children: [
                  SizedBox(
                    height: screenHeight,
                    width: constraints.maxWidth,
                    child: WorkScreen.buildBackground(backgroundColor, backgroundImageString),
                  ),
                  screenWidget
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isOffline) {
    WrappedScreen? builtScreen;

    // Replace the model if a new one is found.
    // If there is no model, then just use the old one.
    // Happens when you close a screen but Flutter rebuilds it.
    FlPanelModel? newModel = item != null
        ? IStorageService().getComponentByScreenClassName(pScreenClassName: item!.screenLongName) //
        : null;
    model = newModel ?? model;

    if (model != null) {
      builtScreen = _buildScreen();
    }

    // Custom config for this screen
    CustomScreen? customScreen = IUiService().getCustomScreen(item!.screenLongName);
    if (customScreen != null) {
      builtScreen = _buildCustomScreen(context, customScreen, builtScreen);
    }

    // Update screenTitle
    screenTitle = builtScreen?.screenTitle ?? "No title";

    if (builtScreen?.screen == null) {
      FlutterUI.logUI.wtf("Model/Custom screen not found for work screen: $screenLongName");
      return Center(
        child: Text(
          FlutterUI.translate("Failed to load screen, please try again."),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return FocusTraversalGroup(
      child: SafeArea(
        child: Column(
          children: [
            if (isOffline) OfflineUtil.getOfflineBar(context),
            Expanded(
              child: _wrapJVxScreen(
                context,
                builtScreen!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  WrappedScreen? _buildScreen() {
    return WrappedScreen(
      screen: ComponentsFactory.buildWidget(model!),
      screenTitle: model!.screenTitle!,
    );
  }

  WrappedScreen _buildCustomScreen(
    BuildContext context,
    CustomScreen customScreen,
    WrappedScreen? screen,
  ) {
    Widget? replaceScreen = customScreen.screenBuilder?.call(context, screen?.screen);

    return WrappedScreen(
      header: customScreen.headerBuilder?.call(context),
      footer: customScreen.footerBuilder?.call(context),
      screen: replaceScreen ?? screen?.screen,
      screenTitle: customScreen.screenTitle ?? screen?.screenTitle ?? "Custom Screen",
      customScreen: replaceScreen != null,
    );
  }

  /// Is being called by Back button in [AppBar].
  Future<void> _onBack([bool pForced = false]) async {
    if (isNavigating) {
      return;
    }

    isForced = pForced;

    NavigatorState navigator = Navigator.of(context);
    if (!(await navigator.maybePop())) {
      if (!mounted) return;
      context.beamBack();
    }
  }

  /// Is being called by [WillPopScope].
  Future<bool> _onWillPop(BuildContext context) async {
    if (isNavigating || (LoadingBar.maybeOf(context)?.show ?? false)) {
      return false;
    }

    isNavigating = true;

    // We have no working screen, allow back.
    if (item?.screenLongName == null || (model == null && customScreen == null)) {
      return true;
    }

    await IUiService()
        .saveAllEditors(pReason: "Closing Screen", pFunction: _closeScreen)
        .catchError(IUiService().handleAsyncError)
        .whenComplete(() {
      isForced = false;
      isNavigating = false;
    });

    return IUiService().usesNativeRouting(item!.screenLongName);
  }

  List<BaseCommand> _closeScreen() {
    List<BaseCommand> commands = [];
    if (!IUiService().usesNativeRouting(item!.screenLongName)) {
      if (isForced) {
        commands.add(
          CloseScreenCommand(
            reason: "Work screen back",
            screenName: model!.name,
          ),
        );
      } else {
        commands.add(
          NavigationCommand(
            reason: "Back button pressed",
            openScreen: model!.name,
          ),
        );
      }
    }
    return commands;
  }

  void _setScreenSize(Size size) {
    ILayoutService()
        .setScreenSize(
          pScreenComponentId: model!.id,
          pSize: size,
        )
        .then((value) => value.forEach((e) async => await IUiService().sendCommand(e)));
  }
}

class WrappedScreen {
  /// Title displayed on the top
  final String screenTitle;

  /// Header
  final PreferredSizeWidget? header;

  /// Footer
  final Widget? footer;

  /// Screen Widget
  final Widget? screen;

  final bool customScreen;

  const WrappedScreen({
    required this.screenTitle,
    this.header,
    this.footer,
    this.screen,
    this.customScreen = false,
  });
}
