import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/link_reference.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class LazyDropdown extends StatefulWidget {
  final allowNull;
  final ValueChanged<dynamic> onSave;
  final VoidCallback onCancel;
  final VoidCallback onScrollToEnd;
  final ValueChanged<String> onFilter;
  final BuildContext context;
  final double fetchMoreYOffset;
  final ComponentData data;
  final LinkReference linkReference;
  final ColumnView columnView;

  LazyDropdown(
      { //@required this.data,
      @required this.allowNull,
      @required this.context,
      this.data,
      this.onSave,
      this.onCancel,
      this.onScrollToEnd,
      this.onFilter,
      this.columnView,
      this.linkReference,
      this.fetchMoreYOffset = 0});

  @override
  _LazyDropdownState createState() => _LazyDropdownState();
}

class _LazyDropdownState extends State<LazyDropdown> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode node = FocusNode();
  Timer filterTimer; // 200-300 Milliseconds
  dynamic lastChangedFilter;
  List<int> visibleColumnIndex = <int>[];

  @override
  void initState() {
    super.initState();
    widget.data.registerDataChanged(updateData);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.data.unregisterDataChanged(updateData);
    super.dispose();
  }

  void updateData() {
    this.visibleColumnIndex = this.getVisibleColumnIndex(widget.data.data);
    this.setState(() {});
  }

  void startTimerValueChanged(dynamic value) {
    lastChangedFilter = value;
    if (filterTimer != null && filterTimer.isActive) filterTimer.cancel();

    filterTimer =
        new Timer(Duration(milliseconds: 300), onTextFieldValueChanged);
  }

  void onTextFieldValueChanged() {
    if (this.widget.onFilter != null) this.widget.onFilter(lastChangedFilter);
  }

  void _onCancel() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onCancel != null) this.widget.onCancel();
  }

  void _onDelete() {
    Navigator.of(this.widget.context).pop();
    if (this.widget.onSave != null) this.widget.onSave(null);
  }

  void _onRowTapped(int index) {
    Navigator.of(this.widget.context).pop();
    JVxData data = widget.data.getData(context, null, 0);
    if (this.widget.onSave != null && data.records.length > index) {
      dynamic value = data.getRow(index);
      this.widget.onSave(value);
      this.updateData();
    }
  }

  Widget itemBuilder(BuildContext ctxt, int index) {
    //return Text("Na oida");
    JVxData data = widget.data.data;
    return getDataRow(data, index);
  }

  Widget getDataRow(JVxData data, int index) {
    List<Widget> children = new List<Widget>();

    if (data != null && data.records != null && index < data.records.length) {
      List<dynamic> columns = data.records[index];

      this.visibleColumnIndex.asMap().forEach((i, j) {
        if (j < columns.length)
          children.add(getTableColumn(
              columns[j] != null ? columns[j].toString() : "", index, i));
        else
          children.add(getTableColumn("", index, j));
      });

      return getTableRow(children, index, false);
    }

    return Container();
  }

  Container getTableRow(List<Widget> children, int index, bool isHeader) {
    if (isHeader) {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: UIData.ui_kit_color_2[200],
          ),
          child: ListTile(title: Row(children: children)));
    } else {
      return Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[400], spreadRadius: 1)],
            color: Colors.white,
          ),
          child: ListTile(
            title: Row(children: children),
            onTap: () => _onRowTapped(index),
          ));
    }
  }

  Widget getTableColumn(String text, int rowIndex, int columnIndex) {
    int flex = 1;

    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: Text(Properties.utf8convert(text)),
              padding: EdgeInsets.all(5)),
        ));
  }

  List<int> getVisibleColumnIndex(JVxData data) {
    List<int> visibleColumnsIndex = <int>[];
    if (data != null && data.records.isNotEmpty) {
      data.columnNames.asMap().forEach((i, v) {
        if (widget.columnView != null &&
            widget.columnView.columnNames != null) {
          if (widget.columnView.columnNames.contains(v)) {
            visibleColumnsIndex.add(i);
          }
        } else if (widget.linkReference != null &&
            widget.linkReference.referencedColumnNames != null &&
            widget.linkReference.referencedColumnNames.contains(v)) {
          visibleColumnsIndex.add(i);
        }
      });
    }

    return visibleColumnsIndex;
  }

  _scrollListener() {
    if (_scrollController.offset + this.widget.fetchMoreYOffset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (this.widget.onScrollToEnd != null) this.widget.onScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = 0;
    JVxData data = widget.data.data;
    if (data != null && data.records != null) itemCount = data.records.length;

    return Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          child: Container(
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              children: <Widget>[
                ButtonBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new RaisedButton(
                        child: Text("Clear"),
                        onPressed: _onDelete,
                        color: UIData.ui_kit_color_2[200],
                      ),
                      new RaisedButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _onCancel,
                        color: UIData.ui_kit_color_2,
                      ),
                    ]),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: UIData.ui_kit_color_2, width: 1.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: UIData.ui_kit_color_2, width: 0.0)),
                    ),
                    key: widget.key,
                    controller: _controller,
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    onChanged: startTimerValueChanged,
                    focusNode: node,
                  ),
                )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: itemCount,
                      itemBuilder: itemBuilder,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
