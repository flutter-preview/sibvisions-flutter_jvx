import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/changed_component.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';
import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/component/model/component_model.dart';
import 'package:flutterclient/src/ui/layout/co_border_layout_container_widget.dart';
import 'package:flutterclient/src/ui/layout/co_form_layout_container_widget.dart';
import 'package:flutterclient/src/ui/layout/co_layout.dart';
import 'package:flutterclient/src/ui/layout/i_layout.dart';
import 'package:flutterclient/src/ui/layout/widgets/co_border_layout_constraint.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';

import '../co_container_widget.dart';

class ContainerComponentModel extends ComponentModel {
  List<ComponentWidget> components = <ComponentWidget>[];

  CoLayout? layout;

  ContainerComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  void add(ComponentWidget pComponent) {
    addWithContraintsAndIndex(pComponent, null, -1);
  }

  void addWithConstraints(ComponentWidget pComponent, String pConstraints) {
    addWithContraintsAndIndex(pComponent, pConstraints, -1);
  }

  void addWithIndex(ComponentWidget pComponent, int pIndex) {
    addWithContraintsAndIndex(pComponent, null, pIndex);
  }

  void addWithContraintsAndIndex(
      ComponentWidget pComponent, String? pConstraints, int pIndex) {
    if (components.contains(pComponent)) {
      components.remove(pComponent);
    }
    if (pIndex < 0) {
      components.add(pComponent);
    } else {
      components.insert(pIndex, pComponent);
    }

    pComponent.componentModel.state = CoState.Added;
    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(pConstraints!);
        layout!.addLayoutComponent(pComponent, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout!.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is Object /*CoFlowLayoutContainerWidget*/) {
        layout!.addLayoutComponent(pComponent, pConstraints);
      } else if (layout is Object /*CoGridLayoutContainerWidget*/) {
        layout!.addLayoutComponent(pComponent, pConstraints);
      }
    }

    notifyListeners();
  }

  void remove(int pIndex) {
    ComponentWidget pComponent = components[pIndex];
    if (layout != null) {
      layout!.removeLayoutComponent(pComponent);
    }
    components.removeAt(pIndex);
  }

  void removeWithComponent(ComponentWidget pComponent) {
    int index = components.indexWhere((c) =>
        c.componentModel.componentId.toString() ==
        pComponent.componentModel.componentId.toString());

    if (index >= 0) {
      remove(index);
      pComponent.componentModel.state = CoState.Free;
    }

    notifyListeners();
  }

  void removeAll() {
    while (components.length > 0) {
      remove(components.length - 1);
    }

    notifyListeners();
  }

  ComponentWidget getComponentWithContraint(String constraint) {
    return components.firstWhere(
        (component) => component.componentModel.constraints == constraint);
  }

  void updateConstraintsWithWidget(
      ComponentWidget componentWidget, String newConstraints) {
    if (layout != null) {
      layout!.removeLayoutComponent(componentWidget);

      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            getBorderLayoutConstraintsFromString(newConstraints);
        layout!.addLayoutComponent(componentWidget, contraints);
      } else if (layout is CoFormLayoutContainerWidget) {
        layout!.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is Object /*CoFlowLayoutContainerWidget*/) {
        layout!.addLayoutComponent(componentWidget, newConstraints);
      } else if (layout is Object /*CoGridLayoutContainerWidget*/) {
        layout!.addLayoutComponent(componentWidget, newConstraints);
      }
    }
  }

  void updateComponentProperties(BuildContext context, String componentId,
      ChangedComponent changedComponent) {
    ComponentWidget pComponent = this
        .components
        .firstWhere((c) => c.componentModel.componentId == componentId);

    pComponent.componentModel.updateProperties(context, changedComponent);

    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, null);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, null);

    if (layout != null) {
      if (layout is CoBorderLayoutContainerWidget) {
        CoBorderLayoutConstraints contraints =
            layout!.getConstraints(pComponent);
        (layout as CoBorderLayoutContainerWidget)
            .addLayoutComponent(pComponent, contraints);
      }
    }

    notifyListeners();
  }

  CoLayout createLayoutForHeaderFooterPanel(
      CoContainerWidget container, String layoutData) {
    return CoBorderLayoutContainerWidget.fromLayoutString(
        container, layoutData, null);
  }

  CoLayout? createLayout(
      CoContainerWidget container, ChangedComponent changedComponent) {
    if (changedComponent.hasProperty(ComponentProperty.LAYOUT)) {
      String? layoutRaw =
          changedComponent.getProperty<String>(ComponentProperty.LAYOUT, null);
      String? layoutData = changedComponent.getProperty<String>(
          ComponentProperty.LAYOUT_DATA, null);

      switch (changedComponent.layoutName) {
        case "BorderLayout":
          {
            return CoBorderLayoutContainerWidget.fromLayoutString(
                container, layoutRaw!, layoutData);
          }
        case "FormLayout":
          {
            return CoFormLayoutContainerWidget.fromLayoutString(
                container, layoutRaw!, layoutData!);
          }
        //   break;
        // case "FlowLayout":
        //   {
        //     return CoFlowLayoutContainerWidget.fromLayoutString(
        //         container, layoutRaw, layoutData);
        //   }
        //   break;
        // case "GridLayout":
        //   {
        //     return CoGridLayoutContainerWidget.fromLayoutString(
        //         container, layoutRaw, layoutData);
        //   }
        //   break;
      }

      return null;
    }
  }
}
