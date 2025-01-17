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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/column_definition.dart';
import '../../model/layout/alignments.dart';
import '../../model/response/dal_fetch_response.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import '../editor/cell_editor/fl_dummy_cell_editor.dart';
import '../editor/cell_editor/fl_text_cell_editor.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_widget.dart';

class FlTableCell extends FlStatefulWidget<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The size of the icon.
  static const double iconSize = 16;

  /// The size of the clear icon.
  static const double clearIconSize = 24;

  /// The gap between icons and text
  static const double iconTextGap = 5;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The callback if a value has ended being changed in the table.
  final TableValueChangedCallback? onEndEditing;

  /// The callback if a value has been changed in the table.
  final TableValueChangedCallback? onValueChanged;

  /// Gets called with the index of the row and name of column when the user taps a cell.
  /// Provides the celleditor of this cell, allowing to click the cell editor.
  /// Allows validation of the click before allowing the cell editor to be clicked.
  final TableTapCallback? onTap;

  /// Gets called with the index of the row and name of column when the user long presses a cell.
  final TableLongPressCallback? onLongPress;

  /// The [ColumnDefinition] of this table cell.
  final ColumnDefinition columnDefinition;

  /// The width of the cell.
  final double width;

  /// The cell paddings
  final EdgeInsets paddings;

  /// The value of the cell;
  final dynamic value;

  /// The index of the row this column is in.
  final int rowIndex;

  /// The index of the cell in the row;
  final int cellIndex;

  /// If the cell is not first, has border on the left side.
  final double cellDividerWidth;

  /// The format of the cell.
  final CellFormat? cellFormat;

  /// If this column is selected.
  final bool isSelected;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTableCell({
    super.key,
    required super.model,
    this.onEndEditing,
    this.onValueChanged,
    this.onLongPress,
    this.onTap,
    required this.columnDefinition,
    required this.width,
    required this.paddings,
    this.value,
    this.rowIndex = -1,
    required this.cellIndex,
    required this.cellDividerWidth,
    this.cellFormat,
    this.isSelected = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<FlTableCell> createState() => _FlTableCellState();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// How much a table cell needs to be padded to show the content correctly.
  static double getContentPadding(ICellEditor cellEditor) {
    if (cellEditor.allowedInTable) {
      return cellEditor.getContentPadding(null);
    }

    double dExtraWidth = 0.0;
    if (cellEditor.tableDeleteIcon) {
      dExtraWidth += clearIconSize;
    }
    if (cellEditor.tableEditIcon != null) {
      dExtraWidth += iconSize;
    }
    if (cellEditor.tableDeleteIcon || cellEditor.tableEditIcon != null) {
      dExtraWidth += iconTextGap;
    }
    return dExtraWidth;
  }
}

class _FlTableCellState extends State<FlTableCell> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The celleditor of the cell.
  ICellEditor cellEditor = FlDummyCellEditor();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  initState() {
    super.initState();

    _rebuildCellEditor();
  }

  @override
  void didUpdateWidget(FlTableCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.columnDefinition.cellEditorJson != widget.columnDefinition.cellEditorJson) {
      _rebuildCellEditor();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? cellChild;

    if (widget.cellFormat?.imageString.isNotEmpty == true) {
      cellChild = ImageLoader.loadImage(
        widget.cellFormat!.imageString,
        pWantedColor: widget.cellFormat?.foreground,
      );
    }

    cellChild ??= _createCellEditorWidget();

    cellChild ??= _createTextWidget();

    Border? border;
    if (widget.model.showHorizontalLines) {
      border = Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 0.3,
        ),
      );
    }

    // The first cell does not get a left border
    if (widget.model.showVerticalLines && widget.cellIndex != 0) {
      Border verticalBorder = Border(
          left: BorderSide(
        color: JVxColors.TABLE_VERTICAL_DIVICER,
        width: widget.cellDividerWidth,
      ));

      if (border == null) {
        border = verticalBorder;
      } else {
        border = Border.merge(verticalBorder, border);
      }
    }

    EdgeInsets paddings = widget.paddings;
    if (widget.model.showFocusRect && widget.isSelected) {
      border = Border.all(
        color: JVxColors.TABLE_FOCUS_REACT,
        width: 1,
      );
      paddings = paddings - const EdgeInsets.all(1);
    }

    return GestureDetector(
      onLongPressStart: (widget.onLongPress != null) && widget.model.isEnabled
          ? (details) => widget.onLongPress
              ?.call(widget.rowIndex, widget.columnDefinition.name, cellEditor, details.globalPosition)
          : null,
      onTap: widget.onTap != null && widget.model.isEnabled
          ? () => widget.onTap!(widget.rowIndex, widget.columnDefinition.name, cellEditor)
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: border,
          color: widget.cellFormat?.background,
        ),
        width: max(widget.width, 0.0),
        alignment: FLUTTER_ALIGNMENT[widget.columnDefinition.cellEditorHorizontalAlignment.index]
            [VerticalAlignment.CENTER.index],
        padding: paddings,
        child: Row(
          children: [
            Expanded(
              child: cellChild,
            ),
            ..._createCellIcons(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Builds the cell editor.
  void _rebuildCellEditor() {
    cellEditor.dispose();

    cellEditor = ICellEditor.getCellEditor(
      pName: widget.model.name,
      columnDefinition: widget.columnDefinition,
      columnName: widget.columnDefinition.name,
      dataProvider: widget.model.dataProvider,
      pCellEditorJson: widget.columnDefinition.cellEditorJson,
      onChange: widget.model.isEnabled && widget.model.editable
          ? (value) => widget.onValueChanged?.call(value, widget.rowIndex, widget.columnDefinition.name)
          : _doNothing,
      onEndEditing: widget.model.isEnabled && widget.model.editable
          ? (value) => widget.onEndEditing?.call(value, widget.rowIndex, widget.columnDefinition.name)
          : _doNothing,
      onFocusChanged: (_) {},
      pRecalculateCallback: ([pRecalculate = false]) => setState(() {}),
      isInTable: true,
    );

    cellEditor.cellFormat = widget.cellFormat;

    if (cellEditor.allowedInTable) {
      cellEditor.setValue(widget.value);
    }
  }

  void _doNothing(dynamic pNothing) {}

  /// Creates the cell editor widget for the cell if possible
  Widget? _createCellEditorWidget() {
    if (!cellEditor.allowedInTable) {
      return null;
    }

    Widget tableWidget = cellEditor.createWidget(widget.model.json);

    return AbsorbPointer(
      absorbing: !widget.model.isEnabled || !widget.model.editable,
      child: tableWidget,
    );
  }

  /// Creates a normal text widget for the cell.
  Widget _createTextWidget() {
    String cellText = cellEditor.formatValue(widget.value);
    TextStyle style = widget.model.createTextStyle();

    style = style.copyWith(
      backgroundColor: widget.cellFormat?.background,
      color: widget.cellFormat?.foreground,
      fontWeight: widget.cellFormat?.font?.isBold == true ? FontWeight.bold : null,
      fontStyle: widget.cellFormat?.font?.isItalic == true ? FontStyle.italic : null,
      fontFamily: widget.cellFormat?.font?.fontName,
      fontSize: widget.cellFormat?.font?.fontSize.toDouble(),
    );

    TextAlign textAlign;
    if (cellEditor.model.horizontalAlignment == HorizontalAlignment.RIGHT) {
      textAlign = TextAlign.right;
    } else {
      textAlign = TextAlign.left;
    }

    if (cellEditor.model.className == FlCellEditorClassname.TEXT_CELL_EDITOR &&
        cellEditor.model.contentType == FlTextCellEditor.TEXT_PLAIN_PASSWORD) {
      cellText = "•" * cellText.length;
    }

    return Text(
      cellText,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: widget.model.wordWrapEnabled ? null : 1,
      textAlign: textAlign,
    );
  }

  List<Widget> _createCellIcons() {
    if (cellEditor.allowedInTable) {
      return [];
    }

    List<Widget> icons = [];

    bool isLight = Theme.of(FlutterUI.getCurrentContext()!).brightness == Brightness.light;
    if (cellEditor.tableDeleteIcon &&
        cellEditor.allowedTableEdit &&
        !_isValueNullOrEmpty() &&
        widget.columnDefinition.nullable == false) {
      icons.add(
        Center(
          child: InkWell(
            canRequestFocus: false,
            onTap: () {
              widget.onEndEditing?.call(null, widget.rowIndex, widget.columnDefinition.name);
            },
            child: SizedBox(
              width: FlTableCell.clearIconSize,
              height: FlTableCell.clearIconSize,
              child: Icon(
                Icons.clear,
                size: FlTableCell.iconSize,
                color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
              ),
            ),
          ),
        ),
      );
    }

    if (cellEditor.tableEditIcon != null) {
      icons.add(
        Center(
          child: Icon(
            cellEditor.tableEditIcon,
            size: FlTableCell.iconSize,
            color: isLight ? JVxColors.COMPONENT_DISABLED : JVxColors.COMPONENT_DISABLED_LIGHTER,
          ),
        ),
      );
    }

    if (icons.isNotEmpty) {
      icons = [const SizedBox(width: FlTableCell.iconTextGap), ...icons];
    }

    return icons;
  }

  bool _isValueNullOrEmpty() {
    if (widget.value is Map<String, dynamic> || widget.value is List<dynamic>) {
      return widget.value == null || widget.value.length == 0;
    }
    return widget.value == null || "" == widget.value;
  }
}
