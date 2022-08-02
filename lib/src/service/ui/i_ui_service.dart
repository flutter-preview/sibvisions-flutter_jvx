import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../custom/custom_component.dart';
import '../../../custom/custom_screen.dart';
import '../../../custom/custom_screen_manager.dart';
import '../../model/command/base_command.dart';
import '../../model/component/component_subscription.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/menu/menu_model.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../command/i_command_service.dart';

/// Definition of the callback for the QR-scanner
typedef QRCallback = void Function(Barcode qrValue);
typedef ComponentCallback = Function({FlComponentModel? newModel, LayoutData? data});

/// Defines the base construct of a [IUiService]
/// Used to manage all interactions to and from the ui.
abstract class IUiService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  IUiService({required BuildContext pContext});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Communication with other services
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Sends [command] to [ICommandService]
  void sendCommand(BaseCommand command, [VoidCallback? onError]);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Routing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Route to meu page
  /// pReplaceRoute - true if the route should replace the route in its history
  /// false if it should add to it
  void routeToMenu({bool pReplaceRoute = false});

  /// Route to work screen page
  void routeToWorkScreen({required String pScreenName, bool pReplaceRoute = false});

  /// Route to settings page
  void routeToSettings();

  /// Route to Login page
  void routeToLogin({String mode, required Map<String, String?> pLoginProps});

  /// Route to the provided full path, used for routing to offline screens
  void routeToCustom({required String pFullPath});

  /// Sets the buildContext from the current [BeamLocation],
  /// used when server dictates location
  void setRouteContext({required BuildContext pContext});

  /// Sets the current custom manager
  void setCustomManager(CustomScreenManager? pCustomManager);

  /// Opens a [Dialog], the future will complete if the dialog is closed by an
  /// action
  Future<T?> openDialog<T>({
    required Widget pDialogWidget,
    required bool pIsDismissible,
    Function(BuildContext context)? pContextCallback,
    Locale? pLocale,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Meta data management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns the current menu, if none was found - throws exception
  MenuModel getMenuModel();

  /// Set menu model to be used when opening the menu
  void setMenuModel(MenuModel? pMenuModel);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Management of component models
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns all [FlComponentModel] children of provided id.
  List<FlComponentModel> getChildrenModels(String id);

  /// Returns component model with matching componentId,
  /// if none was found returns null
  FlComponentModel? getComponentModel({required String pComponentId});

  /// Get the screen (top-most-parent)
  FlComponentModel? getComponentByName({required String pComponentName});

  /// Returns the top-most panel if a work screen is open
  FlPanelModel? getComponentByScreenName({required String pScreenName});

  /// Save new components to active components,
  /// used for saving components which have not been previously been rendered.
  void saveNewComponents({required List<FlComponentModel> newModels});

  /// Called when the current workScreen is closed, will delete all relevant data(models, subscriptions,...) from [IUiService]
  void closeScreen({required String pScreenName, required bool pBeamBack});

  /// Gets all children and the children below recursively.
  List<FlComponentModel> getAllComponentsBelow(String id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // LayoutData management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify component of new [LayoutData].
  void setLayoutPosition({required LayoutData layoutData});

  /// Returns a list of layoutData from all children.
  List<LayoutData> getChildrenLayoutData({required String pParentId});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Component registration management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Register as an active component, callback will be called when model
  void registerAsLiveComponent({required ComponentSubscription pComponentSubscription});

  /// Register to receive a subscriptions of data from a specific dataProvider
  void registerDataSubscription({required DataSubscription pDataSubscription, bool pShouldFetch = true});

  /// Not to be used from ui, only used when components are no l onger to be displayed in UI
  void deleteInactiveComponent({required Set<String> inactiveIds});

  /// Removes all active subscriptions
  void disposeSubscriptions({required Object pSubscriber});

  /// Removes [DataSubscription] from [IUiService]
  void disposeDataSubscription({required Object pSubscriber, String? pDataProvider});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Methods to notify components about changes to themselves
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Notify affected parents that their children changed, should only be used
  /// when parent model hasn't been changed as well.
  void notifyAffectedComponents({required Set<String> affectedIds});

  /// Notify changed live components that their model has changed, will give
  /// them their new model.
  void notifyChangedComponents({required List<FlComponentModel> updatedModels});

  /// Notify all components belonging to [pDataProvider] that their underlying
  /// data may have changed.
  void notifyDataChange({
    required String pDataProvider,
    required int pFrom,
    required int pTo,
  });

  /// Calls the callback of all subscribed [DataSubscription]s which are subscribed to [pDataProvider]
  void setSelectedData({
    required String pSubId,
    required String pDataProvider,
    required DataRecord? pDataRow,
  });

  /// Calls the callback of all subscribed [DataSubscription]s
  void setChunkData({
    required String pSubId,
    required String pDataProvider,
    required DataChunk pDataChunk,
  });

  void setMetaData({
    required String pSubId,
    required String pDataProvider,
    required DalMetaDataResponse pMetaData,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Custom
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If this screen long name has been replaced by a custom screen
  bool hasReplaced({required String pScreenLongName});

  /// Gets replace-type screen by screenName
  CustomScreen? getCustomScreen({required String pScreenName});

  /// Gets a custom component with given name (ignores screen)
  CustomComponent? getCustomComponent({required String pComponentName});
}
