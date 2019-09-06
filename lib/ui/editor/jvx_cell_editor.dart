import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/column_view.dart';
import 'package:jvx_mobile_v3/model/popup_size.dart';
import 'package:jvx_mobile_v3/ui/editor/i_cell_editor.dart';

class JVxCellEditor implements ICellEditor {
  int horizontalAlignment;
  int verticalAlignment;
  int preferredEditorMode;
  String additionalCondition;
  ColumnView columnView;
  bool displayReferencedColumnName;
  bool displayConcatMask;
  PopupSize popupSize;
  bool searchColumnMapping;
  bool searchTextAnywhere;
  bool sortByColumnName;
  bool tableHeaderVisible;
  bool validationEnabled;
  bool doNotClearColumnNames;
  String className;
  bool tableReadonly;
  bool directCellEditor;
  bool autoOpenPopup;

  @override
  Widget getWidget() {
    // ToDo: Implement getWidget
    return null;
  }
}