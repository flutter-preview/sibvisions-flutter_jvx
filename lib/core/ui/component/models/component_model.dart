import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import '../../../utils/app/so_text_style.dart';
import '../../../utils/theme/hex_color.dart';
import '../../container/container_component_model.dart';
import '../../screen/component_screen_widget.dart';
import '../component_widget.dart';

class ComponentModel extends ValueNotifier {
  Queue<ToUpdateComponent> _toUpdateComponents = Queue<ToUpdateComponent>();
  String name;
  String componentId;
  String rawComponentId;
  CoState state = CoState.Free;
  Color background = Colors.transparent;
  Color foreground;
  TextStyle fontStyle = new TextStyle(fontSize: 16.0, color: Colors.black);
  Size _preferredSize;
  Size _minimumSize;
  Size _maximumSize;
  bool isVisible = true;
  bool enabled = true;
  String constraints = "";
  int verticalAlignment = 1;
  int horizontalAlignment = 0;
  String text = "";

  String parentComponentId;
  List<Key> childComponentIds;

  ChangedComponent _changedComponent;
  ComponentWidgetState componentState;
  CoState coState;

  bool get isForegroundSet => foreground != null;
  bool get isBackgroundSet => background != null;
  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size size) => _preferredSize = size;
  Size get minimumSize => _minimumSize;
  set minimumSize(Size size) => _minimumSize = size;
  Size get maximumSize => _maximumSize;
  set maximumSize(Size size) => _maximumSize = size;

  Queue<ToUpdateComponent> get toUpdateComponents => _toUpdateComponents;

  set toUpdateComponents(Queue<ToUpdateComponent> toUpdateComponents) =>
      _toUpdateComponents = toUpdateComponents;

  set compId(String newComponentId) {
    componentId = newComponentId;
  }

  ChangedComponent get changedComponent {
    if (_toUpdateComponents != null && _toUpdateComponents.length > 0) {
      return _toUpdateComponents.last.changedComponent;
    }
    return _changedComponent;
  }

  ChangedComponent get firstChangedComponent {
    return _changedComponent;
  }

  ComponentModel(this._changedComponent) : super(_changedComponent) {
    if (this._changedComponent != null) {
      this.compId = this._changedComponent.id;
      this.toUpdateComponents.add(ToUpdateComponent(
          changedComponent: this._changedComponent,
          componentId: this._changedComponent.id));

      this.updateProperties(changedComponent);
    }
  }

  void updateProperties(ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);
    rawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID);
    background =
        changedComponent.getProperty<HexColor>(ComponentProperty.BACKGROUND);
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name);
    isVisible =
        changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, true);
    fontStyle = SoTextStyle.addFontToTextStyle(
        changedComponent.getProperty<String>(ComponentProperty.FONT, ""),
        fontStyle);
    foreground = changedComponent.getProperty<HexColor>(
        ComponentProperty.FOREGROUND, null);
    fontStyle = SoTextStyle.addForecolorToTextStyle(foreground, fontStyle);
    enabled =
        changedComponent.getProperty<bool>(ComponentProperty.ENABLED, true);
    verticalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment);
    horizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment);
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name);
    text = _changedComponent.getProperty<String>(ComponentProperty.TEXT, text);
  }

  void update() {
    if (changedComponent != null) this.updateProperties(changedComponent);
    notifyListeners();
  }
}
