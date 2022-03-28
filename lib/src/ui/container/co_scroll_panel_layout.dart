import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/ui/layout/layout/layout_model.dart';

import '../component/model/component_model.dart';
import '../layout/widgets/co_layout_render_box.dart';
import 'models/container_component_model.dart';

class CoScrollPanelLayout extends MultiChildRenderObjectWidget {
  final CoScrollPanelConstraints preferredConstraints;
  final ContainerComponentModel? container;

  CoScrollPanelLayout(
      {Key? key,
      List<CoScrollPanelLayoutId> children: const [],
      required this.preferredConstraints,
      this.container})
      : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderScrollPanelLayout(this.container);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderScrollPanelLayout renderObject) {
    /// Force Layout, if some of the settings have changed
    if (renderObject.preferredConstraints != this.preferredConstraints) {
      renderObject.preferredConstraints = this.preferredConstraints;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class RenderScrollPanelLayout extends CoLayoutRenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox? child;
  CoScrollPanelConstraints? preferredConstraints;
  ContainerComponentModel? container;

  RenderScrollPanelLayout(this.container, {List<RenderBox>? children}) {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {
    this.debugInfo = "ScrollLayout in container ${container?.componentId}";

    RenderBox? renderBox = firstChild;
    while (renderBox != null) {
      final MultiChildLayoutParentData childParentData =
          renderBox.parentData as MultiChildLayoutParentData;
      this.child = renderBox;
      this.preferredConstraints =
          childParentData.id as CoScrollPanelConstraints;
      renderBox = childParentData.nextSibling;
    }

    this.preferredLayoutSize = this.constraints.biggest;
    this.maximumLayoutSize = this.constraints.biggest;
    this.minimumLayoutSize = this.constraints.biggest;

    Size? preferredSize;

    if (child != null) {
      preferredSize =
          getPreferredSize(child!, preferredConstraints!.componentModel);
      if (preferredSize == null) {
        this.layoutRenderBox(child!, BoxConstraints.tightForFinite());
        preferredSize = child!.size;
      }

      double? newHeight;
      double? newWidth;

      if (preferredSize.height <
              preferredConstraints!.parentConstraints.maxHeight &&
          preferredConstraints!.parentConstraints.maxHeight !=
              double.infinity) {
        newHeight = preferredConstraints!.parentConstraints.maxHeight;
      }

      if (this.preferredConstraints?.preferredSize != null &&
          preferredSize.width <
              this.preferredConstraints!.preferredSize!.width) {
        newWidth = this.preferredConstraints!.preferredSize!.width;
      }

      if (newHeight != null || newWidth != null) {
        BoxConstraints newConstraints = BoxConstraints(
            minWidth: (newWidth != null ? newWidth : this.constraints.minWidth),
            maxWidth: (newWidth != null ? newWidth : this.constraints.maxWidth),
            minHeight:
                (newHeight != null ? newHeight : this.constraints.minHeight),
            maxHeight:
                (newHeight != null ? newHeight : this.constraints.maxHeight));

        this.layoutRenderBox(child!, newConstraints);
      } else {
        this.layoutRenderBox(
            child!,
            BoxConstraints(
                minWidth: this.constraints.minWidth,
                maxWidth: this.constraints.maxWidth,
                minHeight: this.constraints.minHeight,
                maxHeight: this.constraints.maxHeight));
      }

      final MultiChildLayoutParentData childParentData =
          child!.parentData as MultiChildLayoutParentData;
      childParentData.offset = Offset(0, 0);
      this.size = this
          .constraints
          .constrainDimensions(child!.size.width, child!.size.height);
    } else {
      this.size = this.constraints.constrainDimensions(
          this.preferredConstraints!.parentConstraints.biggest.width,
          this.preferredConstraints!.parentConstraints.biggest.height);
    }
    dev.log(DateTime.now().toString() +
        ';' +
        "ScrollLayout;${container?.name};${container?.componentId};${this.constraints};1;${this.size}");
  }

  Size? getPreferredSize(RenderBox renderBox, ComponentWidget comp) {
    if (!comp.componentModel.isPreferredSizeSet) {
      Size? size = getChildLayoutPreferredSize(
          comp,
          BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity));
      if (size != null) {
        return size;
      } else {
        if (_childSize(comp) != null)
          size = _childSize(comp)!;
        else {
          size = layoutRenderBox(
              renderBox,
              BoxConstraints(
                  minHeight: 0,
                  minWidth: 0,
                  maxHeight: double.infinity,
                  maxWidth: double.infinity));

          if (size.width == double.infinity || size.height == double.infinity) {
            print(
                "CoBorderLayout: getPrefererredSize: Infinity height or width for BorderLayout!");
          }
          _setChildSize(comp, size);
        }
        return size;
      }
    } else {
      return comp.componentModel.preferredSize;
    }
  }

  Size? _childSize(ComponentWidget comp) {
    if (comp is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          comp.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null) {
        return containerComponentModel.layout!.layoutModel.layoutSize;
      }
    }

    return null;
  }

  void _setChildSize(ComponentWidget comp, Size size) {
    if (comp is CoContainerWidget) {
      ContainerComponentModel containerComponentModel =
          comp.componentModel as ContainerComponentModel;

      if (containerComponentModel.layout != null) {
        containerComponentModel.layout!.layoutModel.layoutSize = size;
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class CoScrollPanelLayoutId
    extends ParentDataWidget<MultiChildLayoutParentData> {
  CoScrollPanelLayoutId(
      {Key? key, required this.constraints, required Widget child})
      : super(key: key ?? ValueKey<Object>(constraints), child: child);

  final CoScrollPanelConstraints constraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData =
        renderObject.parentData as MultiChildLayoutParentData;
    if (parentData.id != constraints) {
      parentData.id = constraints;
      final AbstractNode targetParent = renderObject.parent as AbstractNode;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', constraints));
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MultiChildLayoutParentData;
}

class CoScrollPanelConstraints {
  BoxConstraints parentConstraints;
  ComponentWidget componentModel;
  Size? preferredSize;

  CoScrollPanelConstraints(this.parentConstraints, this.componentModel,
      [this.preferredSize]);
}