import 'dart:collection';
import 'dart:developer';

import '../../../../util/extensions/list_extensions.dart';
import '../../../model/api/api_object_property.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/ui/update_components_command.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/component/panel/fl_panel_model.dart';
import '../../../model/menu/menu_model.dart';
import '../i_storage_service.dart';

class ComponentStore implements IStorageService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// MenuModel of current app.
  MenuModel? _menuModel;

  /// Map of all active components received from server, key set to id of [FlComponentModel].
  final HashMap<String, FlComponentModel> _componentMap = HashMap();

  /// Map of all components with "[ApiObjectProperty.remove]" flag to true, these components are not yet to be deleted.
  final HashMap<String, FlComponentModel> _removedComponents = HashMap();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Future<MenuModel> getMenu() async {
    MenuModel? menuModel = _menuModel;
    if (menuModel != null) {
      return menuModel;
    } else {
      throw Exception("No Menu was found");
    }
  }

  @override
  Future<bool> saveMenu(MenuModel menuModel) async {
    _menuModel = menuModel;

    return true;
  }

  @override
  Future<List<FlComponentModel>> getScreenByScreenClassName(String screenClassName) async {
    // Get Screen (Top-most Panel)
    FlComponentModel? screenModel =
        _componentMap.values.firstWhereOrNull((componentModel) => _isScreen(screenClassName, componentModel));

    if (screenModel != null) {
      List<FlComponentModel> screen = [];

      screen.add(screenModel);
      screen.addAll(_getAllComponentsBelow(screenModel.id));
      return screen;
    }

    throw Exception("No Screen with screenClassName: $screenClassName was found");
  }

  @override
  Future<List<BaseCommand>> updateComponents(
      List<dynamic>? componentsToUpdate, List<FlComponentModel>? newComponents, String screenName) async {
    // List of all changed models
    Set<String> changedModels = {};
    // List of all deleted models
    Set<String> deletedModels = {};
    // List of all affected models
    Set<String> affectedModels = {};

    // Handle new Components
    if (newComponents != null) {
      for (FlComponentModel componentModel in newComponents) {
        // Notify parent that a new component has been added.
        String? parentId = componentModel.parent;
        if (parentId != null) {
          affectedModels.add(parentId);
        }
        _addNewComponent(componentModel);
      }
    }

    List<FlComponentModel> oldScreenComps = _getAllComponentsBelowByName(name: screenName);

    // Handle components to Update
    if (componentsToUpdate != null) {
      for (dynamic changedData in componentsToUpdate) {
        // Get old Model
        FlComponentModel? oldModel = _componentMap[changedData[ApiObjectProperty.id]];
        if (oldModel != null) {
          // Update Component and add to changedModels
          FlComponentModel newModel = oldModel.updateComponent(oldModel, changedData);
          changedModels.add(newModel.id);

          // Handle component removed
          if (newModel.isRemoved) {
            _componentMap.remove(newModel.id);
            _removedComponents[newModel.id] = newModel;
          } else {
            _componentMap[newModel.id] = newModel;
          }



          // Handle parent change, notify old parent of change
          if (newModel.parent != oldModel.parent) {
            var oldParent = _componentMap[oldModel.parent]!;
            affectedModels.add(oldParent.id);
          }
        }
      }
    }

    List<FlComponentModel> newScreenComps = _getAllComponentsBelowByName(name: screenName);

    List<FlComponentModel> newUiComponents = [];
    List<FlComponentModel> changedUiComponents = [];
    Set<String> deletedUiComponents = {};
    Set<String> affectedUiComponents = {};

    // Build UI Notification
    // Check for new or changed active components
    for (FlComponentModel newModel in newScreenComps) {
      // Was model already sent once, present in oldScreen
      bool isExisting = oldScreenComps.any((oldModel) => oldModel.id == newModel.id);

      if (oldScreenComps.isEmpty) {
        isExisting = false;
      }

      // IF component has not been rendered before it is new.
      if (!isExisting) {
        newUiComponents.add(newModel);
      } else {
        // IF component has been rendered, check if it has been changed.
        bool hasChanged = changedModels.any((changedModels) => changedModels == newModel.id);
        if (hasChanged) {
          changedUiComponents.add(newModel);
        }
      }
    }

    // Check for components which are not active anymore, e.g. not visible, removed or destroyed
    for (FlComponentModel oldModel in oldScreenComps) {
      bool isExisting = newScreenComps.any((newModel) => newModel.id == oldModel.id);

      if (!isExisting) {
        deletedUiComponents.add(oldModel.id);
      }
    }

    // Components can only be affected if any other component has either changed, was deleted or is new. -Special Case for opening a screen
    // Only add Models to affected if they are not new or changed, to avoid unnecessary re-renders.
    if(newUiComponents.isNotEmpty || changedUiComponents.isNotEmpty || deletedUiComponents.isNotEmpty){
      for (String affectedModel in affectedModels) {
        bool isChanged = changedUiComponents.any((changedModel) => changedModel.id == affectedModel);
        bool isNew = newUiComponents.any((newModel) => newModel.id == affectedModel);
        if (!isChanged && !isNew) {
          affectedUiComponents.add(affectedModel);
        }
      }
    }


    // log("----------DeletedUiComponents: $deletedUiComponents ");
    // log("----------affected: $affectedUiComponents ");
    // log("----------changed: $changedUiComponents ");
    // log("----------newUiComponents: $newUiComponents ");

    UpdateComponentsCommand updateComponentsCommand = UpdateComponentsCommand(
        affectedComponents: affectedUiComponents,
        changedComponents: changedUiComponents,
        deletedComponents: deletedUiComponents,
        newComponents: newUiComponents,
        reason: "Server Changed Components");

    return [updateComponentsCommand];
  }

  @override
  Future<void> deleteScreen({required String screenName}) async {
    _componentMap.removeWhere((key, value) => value.name == screenName);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if [componentModel] does have the [ApiObjectProperty.screenClassName] property
  /// and it matches the [screenClassName]
  bool _isScreen(String screenClassName, FlComponentModel componentModel) {
    FlPanelModel? componentPanelModel;

    if (componentModel is FlPanelModel) {
      componentPanelModel = componentModel;
    }

    if (componentPanelModel != null) {
      if (componentPanelModel.screenClassName == screenClassName) {
        return true;
      }
    }
    return false;
  }

  /// Returns List of all [FlComponentModel] below it, recursively.
  List<FlComponentModel> _getAllComponentsBelow(String id) {
    List<FlComponentModel> children = [];

    for (FlComponentModel componentModel in _componentMap.values) {
      String? parentId = componentModel.parent;
      if (parentId != null && parentId == id && componentModel.isVisible) {
        children.add(componentModel);
        children.addAll(_getAllComponentsBelow(componentModel.id));
      }
    }
    return children;
  }

  List<FlComponentModel> _getAllComponentsBelowByName({required String name}) {
    FlComponentModel? componentModel;
    _componentMap.forEach((key, value) {
      if (value.name == name) {
        componentModel = value;
      }
    });

    if (componentModel != null && componentModel!.isVisible) {
      var list = _getAllComponentsBelow(componentModel!.id);
      list.add(componentModel!);
      return list;
    } else {
      return [];
    }
  }

  /// Adds new Component
  void _addNewComponent(FlComponentModel newComponent) {
    _componentMap[newComponent.id] = newComponent;
    newComponent;
  }
}
