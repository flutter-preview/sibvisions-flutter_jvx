import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

/// Layout contraints to define widget position:
///           NORTH
/// WEST    CENTER      EAST
///           SOUTH
enum JVxBorderLayoutConstraints {
  North,
  South,
  West,
  East,
  Center
}


JVxBorderLayoutConstraints getJVxBorderLayoutConstraintsFromString(String jvxBorderLayoutConstraintsString) {
  jvxBorderLayoutConstraintsString = 'JVxBorderLayoutConstraints.$jvxBorderLayoutConstraintsString';
  return JVxBorderLayoutConstraints.values.firstWhere((f)=> f.toString() == jvxBorderLayoutConstraintsString, orElse: () => null);
}

///
/// The <code>JVxSequenceLayout</code> can be used as {@link java.awt.FlowLayout} with
/// additional features. The additional features are:
/// <ul>
/// <li>stretch all components to the maximum size of the greatest component</li>
/// <li>en-/disable wrapping when the width/height changes</li>
/// <li>margins</li>
/// </ul>
///
/// @author René Jahn, ported by Jürgen Hörmann
///
class JVxBorderLayoutWidget extends MultiChildRenderObjectWidget {
  final int iHorizontalGap;
  final int iVerticalGap;
  final EdgeInsets insMargin;

  JVxBorderLayoutWidget({
    Key key,
    List<JVxBorderLayoutId> children: const [],
    this.insMargin = EdgeInsets.zero,
    this.iHorizontalGap = 0,
    this.iVerticalGap = 0 }) : super (key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderJVxBorderLayoutWidget(this.insMargin, this.iHorizontalGap, this.iVerticalGap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderJVxBorderLayoutWidget renderObject) {

    /// Force Layout, if some of the settings have changed
    if (renderObject.iHorizontalGap != this.iHorizontalGap) {
      renderObject.iHorizontalGap = this.iHorizontalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.iVerticalGap != this.iVerticalGap) {
      renderObject.iVerticalGap = this.iVerticalGap;
      renderObject.markNeedsLayout();
    }

    if (renderObject.insMargin != this.insMargin) {
      renderObject.insMargin = this.insMargin;
      renderObject.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new IntProperty('iHorizontalGap', iHorizontalGap));
    properties.add(new IntProperty('iVerticalGap', iVerticalGap));
    properties.add(new StringProperty('insMargin', insMargin.toString()));
  }
}

class RenderJVxBorderLayoutWidget extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderBox north;
  RenderBox south;
  RenderBox west;
  RenderBox east;
  RenderBox center;
  EdgeInsets insMargin;
  int iHorizontalGap;
  int iVerticalGap;

  RenderJVxBorderLayoutWidget(this.insMargin, this.iHorizontalGap, this.iVerticalGap, { List<RenderBox> children }) {
    addAll(children);
  }

  void addLayoutComponent(RenderBox pComponent, JVxBorderLayoutConstraints pConstraints)
  {
    if (pConstraints == null || pConstraints==JVxBorderLayoutConstraints.Center)
    {
      center = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.North)
    {
      north = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.South)
    {
      south = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.East)
    {
      east = pComponent;
    }
    else if (pConstraints == JVxBorderLayoutConstraints.West)
    {
      west = pComponent;
    }
    else
    {
      throw new ArgumentError("cannot add to layout: unknown constraint: " + pConstraints.toString());
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData)
      child.parentData = MultiChildLayoutParentData();
  }

  @override
  void performLayout() {

    Size size = this.constraints.biggest;
    /*if (size.width==double.infinity || size.height==double.infinity) {
      print("Infinity height or width for BorderLayout");
      size = Size((size.width==double.infinity?double.maxFinite:size.width),
                  (size.height==double.infinity?double.maxFinite:size.height));
    }*/

    double x = this.insMargin.left;
    double y = this.insMargin.top;

    double width = size.width - x - this.insMargin.right;
    double height = size.height - y - this.insMargin.bottom;

    double layoutWidth = 0;
    double layoutHeight = 0;
    double layoutMiddleWidth = 0;
    double layoutMiddleHeight = 0;

    // Set components
    this.north = null;
    this.south = null;
    this.east = null;
    this.west = null;
    this.center = null;

    RenderBox child = firstChild;
    while (child != null) {
      final MultiChildLayoutParentData childParentData = child.parentData;
      addLayoutComponent(child, childParentData.id);

      child = childParentData.nextSibling;
    }

    // layout NORTH
    if (north != null) {
      double minWidth = width;

      if (minWidth==double.infinity)
        minWidth = 0;

      north.layout(BoxConstraints(minWidth: minWidth, maxWidth: width, minHeight: 0, maxHeight: double.infinity), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = north.parentData;
      childParentData.offset = Offset(x, y);

      y += north.size.height + iVerticalGap;
      height -= north.size.height + iVerticalGap;
      layoutWidth += north.size.width;
      layoutHeight += north.size.height;
    }

    // layout SOUTH
    if (south != null) {
      double minWidth = width;

      if (minWidth==double.infinity)
        minWidth = 0;

      south.layout(BoxConstraints(minWidth: minWidth, maxWidth: width, minHeight: 0, maxHeight: double.infinity), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = south.parentData;
      childParentData.offset = Offset(x, y + height - south.size.height);

      height -= south.size.height + iVerticalGap;
      layoutWidth = max(south.size.width,layoutWidth);
      layoutHeight += south.size.height;
    }

    // layout WEST
    if (west != null) {
      double minHeight = height;

      if (minHeight==double.infinity)
        minHeight = 0;

      west.layout(BoxConstraints(minWidth: 0, maxWidth: double.infinity, minHeight: minHeight, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = west.parentData;
      childParentData.offset = Offset(x, y);

      x += west.size.width + iHorizontalGap;
      width -= west.size.width + iHorizontalGap;
      layoutMiddleWidth += west.size.width + iHorizontalGap;
      layoutMiddleHeight = max(west.size.height + iVerticalGap, layoutMiddleHeight);
    }

    // layout EAST
    if (east != null) {
      double minHeight = height;

      if (minHeight==double.infinity)
        minHeight = 0;

      east.layout(BoxConstraints(minWidth: 0, maxWidth: double.infinity, minHeight: minHeight, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = east.parentData;
      childParentData.offset = Offset(x + width - east.size.width, y);

      width -= east.size.width + iHorizontalGap;
      layoutMiddleWidth += east.size.width + iHorizontalGap;
      layoutMiddleHeight = max(east.size.height + iVerticalGap, layoutMiddleHeight);
    }

    // layout CENTER
    if (center != null) {
      double minHeight = height;
      double minWidth = width;

      if (minHeight==double.infinity)
        minHeight = 0;

      if (minWidth==double.infinity)
        minWidth = 0;

      center.layout(BoxConstraints(minWidth: minWidth, maxWidth: width, minHeight: minHeight, maxHeight: height), parentUsesSize: true);
      final MultiChildLayoutParentData childParentData = center.parentData;
      childParentData.offset = Offset(x, y); 
      layoutMiddleWidth += center.size.width + iHorizontalGap;
      layoutMiddleHeight = max(center.size.height + iVerticalGap, layoutMiddleHeight);
    }

    layoutWidth = max(layoutWidth,layoutMiddleWidth);
    layoutHeight += layoutMiddleHeight;

    // borderLayout uses max space available
    this.size = Size(layoutWidth, layoutHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }


  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

}


class JVxBorderLayoutId extends ParentDataWidget<JVxBorderLayoutWidget> {
  /// Marks a child with an BorderLayoutConstraints layout position.
  ///
  /// The child must not be null.
  JVxBorderLayoutId({
    Key key,
    this.pConstraints,
    @required Widget child
  }) : assert(child != null),
        super(key: key ?? ValueKey<Object>(pConstraints), child: child);

  /// An BorderLayoutConstraints defines the layout position of this child.
  final JVxBorderLayoutConstraints pConstraints;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is MultiChildLayoutParentData);
    final MultiChildLayoutParentData parentData = renderObject.parentData;
    if (parentData.id != pConstraints) {
      parentData.id = pConstraints;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject)
        targetParent.markNeedsLayout();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', pConstraints));
  }
}