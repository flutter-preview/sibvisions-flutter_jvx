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

import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import '../../../flutter_ui.dart';
import '../../../model/command/base_command.dart';
import '../../../model/command/layout/preferred_size_command.dart';
import '../../../model/command/layout/register_parent_command.dart';
import '../../../model/command/ui/update_layout_position_command.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/layout/layout_position.dart';
import '../i_layout_service.dart';

class LayoutService implements ILayoutService {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class Members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// The map of all registered components
  final HashMap<String, LayoutData> _layoutDataSet = HashMap<String, LayoutData>();

  /// The map of all layouting components
  final List<String> _currentlyLayouting = [];

  /// If layouting is currently allowed.
  bool _isValid = true;

  /// Last set screen size.
  HashMap<String, Size> screenSizes = HashMap<String, Size>();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LayoutService.create();

  @override
  FutureOr<void> clear(bool pFullClear) {
    _isValid = true;
    _currentlyLayouting.clear();
    _layoutDataSet.clear();
  }

  @override
  Future<List<BaseCommand>> reportLayout({required LayoutData pLayoutData}) async {
    FlutterUI.logLayout.d(
        "${pLayoutData.name}|${pLayoutData.id} reportLayout: [${pLayoutData.bestSize}]; pos: [${pLayoutData.layoutPosition}]");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data, if component isn't a child it's treated as the top most panel
    if (!pLayoutData.isChild) {
      applyScreenSize(pLayoutData);
    }
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout
    if (_isLegalState(pParentLayout: pLayoutData)) {
      return _performLayout(pLayoutData: pLayoutData);
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> reportPreferredSize({required LayoutData pLayoutData}) async {
    FlutterUI.logLayout.d("${pLayoutData.name}|${pLayoutData.id} reportPreferredSize: ${pLayoutData.bestSize}");
    pLayoutData.layoutState = LayoutState.VALID;

    // Set object with new data.
    _layoutDataSet[pLayoutData.id] = pLayoutData;

    // Handle possible re-layout, check if parentId exists -> special case for first panel
    String? parentId = pLayoutData.parentId;
    if (parentId != null) {
      LayoutData? parentData = _layoutDataSet[parentId];
      if (parentData != null) {
        if (_isLegalState(pParentLayout: parentData)) {
          return _performLayout(pLayoutData: parentData);
        }
      }
    }

    return [];
  }

  @override
  Future<List<BaseCommand>> setScreenSize({required String pScreenComponentId, required Size pSize}) async {
    screenSizes[pScreenComponentId] = pSize;

    LayoutData? existingLayout = _layoutDataSet[pScreenComponentId];
    if (existingLayout != null && existingLayout.layoutPosition?.toSize() != pSize) {
      applyScreenSize(existingLayout);

      if (_isLegalState(pParentLayout: existingLayout)) {
        return _performLayout(pLayoutData: existingLayout);
      }
    }

    return [];
  }

  @override
  Future<bool> markLayoutAsDirty({required String pComponentId}) async {
    LayoutData? data = _layoutDataSet[pComponentId];

    if (data != null) {
      FlutterUI.logLayout.d("$pComponentId was marked as DIRTY");
      data.layoutState = LayoutState.DIRTY;

      return true;
    }
    return false;
  }

  @override
  Future<bool> removeLayout({required String pComponentId}) async {
    var deleted = _layoutDataSet.remove(pComponentId);
    return deleted == null ? false : true;
  }

  @override
  Future<bool> layoutInProcess() async {
    return _currentlyLayouting.isNotEmpty;
  }

  @override
  Future<bool> isValid() async {
    return _isValid;
  }

  @override
  Future<bool> setValid({required bool isValid}) async {
    _isValid = isValid;

    return _isValid;
  }

  @override
  Future<bool> deleteScreen({required String pComponentId}) async {
    var deleted = _layoutDataSet.remove(pComponentId);
    if (deleted == null) {
      return false;
    }

    List<LayoutData> descendants = _getDescendants(pParentLayout: deleted);
    descendants.forEach((element) {
      _layoutDataSet.remove(element);
    });

    return true;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  LayoutPosition _getScreenPosition(String pComponentId) {
    Size screenSize = screenSizes[pComponentId] ?? Size.zero;

    return LayoutPosition(
      width: screenSize.width,
      height: screenSize.height,
      top: 0,
      left: 0,
    );
  }

  /// Applies the current screen size to the given [LayoutData]
  void applyScreenSize(LayoutData pLayoutData) {
    pLayoutData.layoutPosition = _getScreenPosition(pLayoutData.id);
    pLayoutData.widthConstrains = {};
    pLayoutData.heightConstrains = {};
  }

  /// Performs a layout operation.
  List<BaseCommand> _performLayout({required LayoutData pLayoutData}) {
    FlutterUI.logLayout.d(
        "${pLayoutData.name}|${pLayoutData.id} performLayout: [${pLayoutData.bestSize}]; pos: [${pLayoutData.layoutPosition}]");
    _currentlyLayouting.add(pLayoutData.id);

    try {
      // Copy of parent
      LayoutData panel = LayoutData.from(pLayoutData);

      // Copy of children with deleted positions
      List<LayoutData> children = _getChildrenOrNull(pParentLayout: panel)!.map((data) {
        return LayoutData.from(data);
      }).toList();

      // All newly constraint children
      List<LayoutData> newlyConstraintChildren = [];

      // Needs to register again if this layout has been newly constraint by its parent.
      panel.lastCalculatedSize = panel.calculatedSize;
      panel.layout!.calculateLayout(panel, children);

      if (panel.hasNewCalculatedSize) {
        FlutterUI.logLayout.d(
            "${pLayoutData.name}|${pLayoutData.id} new calc size ${panel.calculatedSize}; old: ${panel.lastCalculatedSize}");
      }

      // Check if any children have been newly constrained.
      for (LayoutData child in children) {
        _layoutDataSet[child.id] = child;
        if (child.isNewlyConstraint) {
          newlyConstraintChildren.add(child);
          markLayoutAsDirty(pComponentId: child.id);
          child.layoutPosition!.isConstraintCalc = true;
        }
      }

      if (newlyConstraintChildren.isNotEmpty) {
        return [UpdateLayoutPositionCommand(layoutDataList: newlyConstraintChildren, reason: "Was constrained")];
      }

      // Only save information AFTER calculations after constrained children.
      _layoutDataSet[panel.id] = panel;

      // Nothing has been "newly" constrained meaning now, the panel can tell its parent exactly how big it wants to be.
      // So if my calc size has changed - tell parent, if not, tell children their position.
      var commands = <BaseCommand>[];

      if (panel.isChild && panel.hasNewCalculatedSize) {
        return [PreferredSizeCommand(layoutData: panel, reason: "Has new calc size")];
      } else {
        // Bugfix: Update layout position always has to come first.
        commands.add(UpdateLayoutPositionCommand(layoutDataList: [panel, ...children], reason: "New position"));

        for (LayoutData child in children) {
          if (child.isParent) {
            FlutterUI.logLayout.d("${child.name}|${child.id} register after parent calc: ${child.layoutPosition}");
            commands.add(RegisterParentCommand(layoutData: child, reason: "New position"));
          }
        }
      }

      return commands;
    } finally {
      _currentlyLayouting.remove(pLayoutData.id);
    }
  }

  /// Returns true if conditions to perform the layout are met.
  ///
  /// Checks if [pParentLayout] is valid and all it's children layout data are present and valid as well.
  bool _isLegalState({required LayoutData pParentLayout}) {
    if (!_isValid) {
      FlutterUI.logLayout.d("I am not valid. ${pParentLayout.id}");
      return false;
    }

    List<LayoutData>? children = _getChildrenOrNull(pParentLayout: pParentLayout);

    if (pParentLayout.layoutState == LayoutState.VALID && children != null) {
      for (LayoutData child in children) {
        if (!(child.layoutState == LayoutState.VALID && (child.hasCalculatedSize || child.hasPreferredSize))) {
          FlutterUI.logLayout.d(
              "${child.id} is not valid because: ${child.layoutState}, ${child.hasCalculatedSize}, ${child.hasPreferredSize}");
          return false;
        }
      }

      return true;
    }
    return false;
  }

  List<LayoutData>? _getChildrenOrNull({required LayoutData pParentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
      } else {
        return null;
      }
    }
    return childrenData;
  }

  List<LayoutData> _getDescendants({required LayoutData pParentLayout}) {
    List<LayoutData> childrenData = [];

    for (String childId in pParentLayout.children) {
      LayoutData? childData = _layoutDataSet[childId];
      if (childData != null) {
        childrenData.add(childData);
        childrenData.addAll(_getDescendants(pParentLayout: childData));
      }
    }

    return childrenData;
  }
}
