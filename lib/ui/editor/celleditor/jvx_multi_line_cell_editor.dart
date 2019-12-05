import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_linked_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_referenced_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class JVxMultiLineCellEditor extends JVxReferencedCellEditor {
  List<ListTile> _items = <ListTile>[];
  String selectedValue;

  JVxMultiLineCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  List<ListTile> getItems(JVxData data) {
    List<ListTile> items = <ListTile>[];
    List<int> visibleColumnsIndex = <int>[];

    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (this.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });

      data.records.forEach((record) {
        record.asMap().forEach((i, c) {
          items.add(getItem(c.toString(), c.toString()));
        });
      });
    }

    if (items.length == 0) items.add(getItem('loading', 'Loading...'));

    return items;
  }

  ListTile getItem(String val, String text) {
    return ListTile(
      onTap: () {
        selectedValue = val;
        valueChanged(val);
      },
      selected: selectedValue == val ? true : false,
      title: Text(text),
    );
  }

  @override
  void setInitialData(JVxData data) {
    if (data != null &&
        data.selectedRow != null &&
        data.selectedRow >= 0 &&
        data.selectedRow < data.records.length &&
        data.columnNames != null &&
        data.columnNames.length > 0 &&
        this.linkReference != null &&
        this.linkReference.referencedColumnNames != null &&
        this.linkReference.referencedColumnNames.length > 0) {
      int columnIndex = -1;
      data.columnNames.asMap().forEach((i, c) {
        if (this.linkReference.referencedColumnNames[0] == c) columnIndex = i;
      });
      if (columnIndex >= 0) {
        value = data.records[data.selectedRow][columnIndex];
      }
    }

    this.setData(data);
  }

  @override
  void setData(JVxData data) {
    this._items = getItems(data);
  }

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);
    return Container(
      decoration: BoxDecoration(
          color: background != null ? background : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border:
              borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _items[index];
        },
      ),
    );
  }
}
