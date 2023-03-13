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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/sort_command.dart';
import '../../model/command/ui/function_command.dart';
import '../../model/command/ui/set_focus_command.dart';
import '../../model/component/editor/cell_editor/cell_editor_model.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/sort_definition.dart';
import '../../model/layout/layout_data.dart';
import '../../service/api/shared/fl_component_classname.dart';
import '../../util/offline_util.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../editor/cell_editor/i_cell_editor.dart';
import 'fl_table_edit_dialog.dart';
import 'fl_table_row.dart';

class FlTableWrapper extends BaseCompWrapperWidget<FlTableModel> {
  static const int DEFAULT_ITEM_COUNT_PER_PAGE = 100;

  const FlTableWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlTableWrapperState();
}

class _FlTableWrapperState extends BaseCompWrapperState<FlTableModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The bit signaling the meta data has been loaded.
  static const int LOADED_META_DATA = 1;

  /// The bit signaling the selected data has been loaded.
  static const int LOADED_SELECTED_RECORD = 2;

  /// The bit signaling the data has been loaded.
  static const int LOADED_DATA = 4;

  /// The bit signaling the table size has been loaded.
  static const int CALCULATION_COMPLETE = 8;

  /// The result of all being loaded.
  static const int ALL_COMPLETE = 15;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The current status of the table wrapper.
  int currentState = 0;

  /// How many "pages" of the table data have been loaded multiplied by: [FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE]
  int pageCount = 1;

  /// The currently selected row. -1 is none selected.
  int selectedRow = -1;

  /// The currently selected column. null is none.
  String? selectedColumn;

  /// The meta data of the table.
  DalMetaData metaData = DalMetaData("");

  /// The data of the table.
  DataChunk dataChunk = DataChunk(data: HashMap(), isAllFetched: false, columnDefinitions: [], from: 0, to: 0);

  /// The sizes of the table.
  late TableSize tableSize;

  /// The scroll controller for the table.
  late final ScrollController tableHorizontalController;

  /// The scroll controller for the headers if they are set to sticky.
  late final ScrollController headerHorizontalController;

  /// The item scroll controller.
  final ItemScrollController itemScrollController = ItemScrollController();

  /// The scroll group to synchronize sticky header scrolling.
  final LinkedScrollControllerGroup linkedScrollGroup = LinkedScrollControllerGroup();

  /// If deletion of a row is allowed.
  bool get _isDeleteEnabled => (metaData.deleteEnabled) && !(metaData.readOnly);

  /// If inserting a row is allowed.
  bool get _isInsertEnabled => (metaData.insertEnabled) && !(metaData.readOnly);

  /// If update a row is allowed.
  bool get _isUpdateAllowed => (metaData.updateEnabled) && !(metaData.readOnly);

  /// The value notifier for a potential editing dialog.
  ValueNotifier<Map<String, dynamic>?> dialogValueNotifier = ValueNotifier<Map<String, dynamic>?>(null);

  /// The currently opened editing dialog
  Future? currentEditDialog;

  /// The last sort definition.
  List<SortDefinition>? lastSortDefinitions;

  /// The size has to be calculated on the next data receiving
  bool _calcOnDataReceived = false;

  /// If the selection has to be cancelled.
  bool cancelSelect = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _FlTableWrapperState() : super();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.isFixedSize = true;

    tableSize = TableSize();

    tableHorizontalController = linkedScrollGroup.addAndGet();
    headerHorizontalController = linkedScrollGroup.addAndGet();

    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    if (currentState != (ALL_COMPLETE)) {
      widget = const Center(child: CircularProgressIndicator());
    }

    widget ??= FlTableWidget(
      headerHorizontalController: headerHorizontalController,
      itemScrollController: itemScrollController,
      tableHorizontalController: tableHorizontalController,
      model: model,
      chunkData: dataChunk,
      metaData: metaData,
      tableSize: tableSize,
      selectedRowIndex: selectedRow,
      selectedColumn: selectedColumn,
      onEndEditing: _setValueEnd,
      onValueChanged: _setValueChanged,
      onRefresh: _refresh,
      onEndScroll: _loadMore,
      onLongPress: _onLongPress,
      onTap: _onCellTap,
      onDoubleTap: _onCellDoubleTap,
      onSlideAction: _onSlideAction,
      slideActions: _slideActions(),
      showFloatingButton: _isInsertEnabled &&
          ((layoutData.layoutPosition?.height ?? 0.0) >= 150) &&
          ((layoutData.layoutPosition?.width ?? 0.0) >= 100) &&
          model.showFloatButton,
      floatingOnPress: _insertRecord,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void dispose() {
    _unsubscribe();

    tableHorizontalController.dispose();
    headerHorizontalController.dispose();
    super.dispose();
  }

  @override
  void receiveNewLayoutData(LayoutData pLayoutData, [bool pSetState = true]) {
    bool newConstraint = pLayoutData.layoutPosition?.width != layoutData.layoutPosition?.width;
    super.receiveNewLayoutData(pLayoutData, pSetState);

    if (newConstraint) {
      _recalculateTableSize(pSetState);
    }
  }

  @override
  modelUpdated() {
    super.modelUpdated();

    if (model.lastChangedProperties.contains(ApiObjectProperty.dataProvider)) {
      _subscribe();
    }

    if (model.lastChangedProperties.contains(ApiObjectProperty.columnNames) ||
        model.lastChangedProperties.contains(ApiObjectProperty.columnLabels) ||
        model.lastChangedProperties.contains(ApiObjectProperty.autoResize)) {
      _calcOnDataReceived = true;
      _recalculateTableSize(true);
    } else {
      setState(() {});
    }
  }

  @override
  Size calculateSize(BuildContext context) {
    return tableSize.calculatedSize;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Recalculates the size of the table.
  void _recalculateTableSize([bool pSetState = false]) {
    tableSize.calculateTableSize(
      pMetaData: metaData,
      pTableModel: model,
      pDataChunk: dataChunk,
      pAvailableWidth: layoutData.layoutPosition?.width,
    );

    currentState |= CALCULATION_COMPLETE;

    if (pSetState) {
      setState(() {});
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Data methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the data service.
  void _subscribe() {
    if (model.dataProvider.isNotEmpty) {
      IUiService().disposeDataSubscription(pSubscriber: this);
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider,
          from: 0,
          to: FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount,
          onSelectedRecord: _receiveSelectedRecord,
          onDataChunk: _receiveTableData,
          onMetaData: _receiveMetaData,
          onReload: _onDataProviderReload,
          dataColumns: null,
        ),
      );
    } else {
      currentState |= LOADED_META_DATA;
      currentState |= LOADED_DATA;
      currentState |= LOADED_SELECTED_RECORD;
    }
  }

  /// Unsubscribes from the data service.
  void _unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);

    currentState &= ~LOADED_META_DATA;
    currentState &= ~LOADED_DATA;
    currentState &= ~LOADED_SELECTED_RECORD;
  }

  int _onDataProviderReload(int pSelectedRow) {
    cancelSelect = true;
    if (pSelectedRow >= 0) {
      pageCount = ((pSelectedRow + 1) / FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
    } else {
      pageCount = 1;
    }

    return FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE * pageCount;
  }

  /// Loads data from the server.
  void _receiveTableData(DataChunk pDataChunk) {
    bool hasToCalc = (currentState & LOADED_DATA) != LOADED_DATA;
    currentState |= LOADED_DATA;

    if (!hasToCalc) {
      List<String> newColumns = pDataChunk.columnDefinitions.map((e) => e.name).toList();
      List<String> oldColumns = dataChunk.columnDefinitions.map((e) => e.name).toList();
      hasToCalc = newColumns.any((element) => (!oldColumns.contains(element))) ||
          oldColumns.any((element) => (!newColumns.contains(element)));
    }

    dataChunk = pDataChunk;

    if (selectedRow >= 0 && selectedRow < dataChunk.data.length) {
      Map<String, dynamic> valueMap = {};

      for (ColumnDefinition coldef in dataChunk.columnDefinitions) {
        valueMap[coldef.name] = dataChunk.data[selectedRow]![dataChunk.getColumnIndex(coldef.name)];
      }

      dialogValueNotifier.value = valueMap;
    }

    if (hasToCalc || _calcOnDataReceived) {
      _closeDialog();
      _calcOnDataReceived = false;
      _recalculateTableSize(true);
    } else {
      setState(() {});
    }
  }

  /// Receives which row is selected.
  void _receiveSelectedRecord(DataRecord? pRecord) {
    currentState |= LOADED_SELECTED_RECORD;

    var oldRecordIndex = selectedRow;
    var oldSelectedColumn = selectedColumn;

    if (pRecord != null) {
      selectedRow = pRecord.index;
      selectedColumn = pRecord.selectedColumn;
    } else {
      selectedColumn = null;
      selectedRow = -1;
    }

    if (oldRecordIndex != selectedRow || selectedColumn != oldSelectedColumn) {
      if (oldRecordIndex != selectedRow) {
        _closeDialog();
      }
      if (selectedRow >= (pageCount * FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE)) {
        pageCount = ((selectedRow + 1) / FlTableWrapper.DEFAULT_ITEM_COUNT_PER_PAGE).ceil();
        _subscribe();
      }
      setState(() {});
    }
  }

  /// Receives the meta data of the table.
  void _receiveMetaData(DalMetaData pMetaData) {
    bool hasToCalc = (currentState & LOADED_META_DATA) != LOADED_META_DATA;
    currentState |= LOADED_META_DATA;

    metaData = pMetaData;

    hasToCalc = metaData.changedProperties.contains(ApiObjectProperty.columns);

    if (!hasToCalc && (metaData.sortDefinitions != null || lastSortDefinitions != null)) {
      hasToCalc = metaData.sortDefinitions?.length != lastSortDefinitions?.length;

      if (!hasToCalc) {
        hasToCalc = metaData.sortDefinitions?.any((newSort) => !lastSortDefinitions!.any((oldSort) {
                  return oldSort.columnName == newSort.columnName && oldSort.mode == newSort.mode;
                })) ??
            false;
        hasToCalc |= lastSortDefinitions?.any((oldSort) => !metaData.sortDefinitions!.any((newSort) {
                  return oldSort.columnName == newSort.columnName && oldSort.mode == newSort.mode;
                })) ??
            false;
      }
    }

    lastSortDefinitions = metaData.sortDefinitions;

    if (hasToCalc) {
      _calcOnDataReceived = true;
      _recalculateTableSize(true);
    } else {
      setState(() {});
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Action methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _setValueEnd(dynamic pValue, int pRow, String pColumnName) {
    _selectRecord(
      pRow,
      pColumnName,
      pAfterSelect: () async {
        if (_isUpdateAllowed && model.editable) {
          int colIndex = metaData.columnDefinitions.indexWhere((element) => element.name == pColumnName);

          if (colIndex >= 0 && pRow >= 0 && pRow < dataChunk.data.length && colIndex < dataChunk.data[pRow]!.length) {
            if (pValue is HashMap<String, dynamic>) {
              return [_setValues(pRow, pValue.keys.toList(), pValue.values.toList(), pColumnName)];
            } else {
              return [
                _setValues(pRow, [pColumnName], [pValue], pColumnName)
              ];
            }
          }
        }

        return [];
      },
    );
  }

  void _setValueChanged(dynamic pValue, int pRow, String pColumnName) {
    // Do nothing
  }

  /// Refreshes this dataprovider
  Future<void> _refresh() {
    return IUiService().sendCommand(
      FetchCommand(
        fromRow: 0,
        reload: true,
        rowCount: IUiService().getSubscriptionRowcount(pDataProvider: model.dataProvider),
        dataProvider: model.dataProvider,
        reason: "Table refreshed",
      ),
    );
  }

  /// Increments the page count and loads more data.
  void _loadMore() {
    if (!dataChunk.isAllFetched) {
      pageCount++;
      _subscribe();
    }
  }

  void _onCellTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1 || pColumnName.isEmpty) {
      _sortColumn(pColumnName);
    } else {
      _selectRecord(pRowIndex, pColumnName, pAfterSelect: () async {
        if (IStorageService().isVisibleInUI(model.id)) {
          if (!pCellEditor.allowedInTable &&
              _isUpdateAllowed &&
              model.editable &&
              pCellEditor.model.preferredEditorMode == ICellEditorModel.SINGLE_CLICK) {
            _showDialog(
              rowIndex: pRowIndex,
              columnDefinitions: [pCellEditor.columnDefinition!],
              values: {pCellEditor.columnDefinition!.name: pCellEditor.getValue()},
              onEndEditing: _setValueEnd,
              newValueNotifier: dialogValueNotifier,
            );
          }
        }
        return [];
      });
    }
  }

  void _onCellDoubleTap(int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    if (pRowIndex == -1 || pColumnName.isEmpty) {
      _sortColumn(pColumnName, true);
    } else {
      _selectRecord(pRowIndex, pColumnName, pAfterSelect: () async {
        if (IStorageService().isVisibleInUI(model.id)) {
          if (!pCellEditor.allowedInTable &&
              _isUpdateAllowed &&
              model.editable &&
              pCellEditor.model.preferredEditorMode == ICellEditorModel.DOUBLE_CLICK) {
            _showDialog(
              rowIndex: pRowIndex,
              columnDefinitions: [pCellEditor.columnDefinition!],
              values: {pCellEditor.columnDefinition!.name: pCellEditor.getValue()},
              onEndEditing: _setValueEnd,
              newValueNotifier: dialogValueNotifier,
            );
          }
        }
        return [];
      });
    }
  }

  _onLongPress(int pRowIndex, String pColumnName, ICellEditor pCellEditor, LongPressStartDetails pPressDetails) {
    List<PopupMenuEntry<TableContextMenuItem>> popupMenuEntries = <PopupMenuEntry<TableContextMenuItem>>[];

    if (_isInsertEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squarePlus, "New", TableContextMenuItem.INSERT));
    }

    int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
    if (_isDeleteEnabled && indexToDelete >= 0) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.squareMinus, "Delete", TableContextMenuItem.DELETE));
    }

    if (pRowIndex == -1 && pColumnName.isNotEmpty && model.sortOnHeaderEnabled) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.sort, "Sort", TableContextMenuItem.SORT));
    }

    if (pRowIndex >= 0 && _isUpdateAllowed) {
      popupMenuEntries.add(_createContextMenuItem(FontAwesomeIcons.penToSquare, "Edit", TableContextMenuItem.EDIT));
    }

    if (popupMenuEntries.isNotEmpty) {
      showMenu(
        position: RelativeRect.fromRect(
          pPressDetails.globalPosition & const Size(40, 40),
          Offset.zero & MediaQuery.of(context).size,
        ),
        context: context,
        items: popupMenuEntries,
      ).then((val) {
        if (val != null) {
          _menuItemPressed(
            val,
            pRowIndex,
            pColumnName,
            pCellEditor,
          );
        }
      });
    }
  }

  void _menuItemPressed(TableContextMenuItem val, int pRowIndex, String pColumnName, ICellEditor pCellEditor) {
    IUiService()
        .saveAllEditors(
            pId: model.id,
            pFunction: () async {
              List<BaseCommand> commands = [];

              if (val == TableContextMenuItem.INSERT) {
                commands.add(_createInsertCommand());
              } else if (val == TableContextMenuItem.DELETE) {
                int indexToDelete = pRowIndex >= 0 ? pRowIndex : selectedRow;
                BaseCommand? command = _createDeleteCommand(indexToDelete);
                if (command != null) {
                  commands.add(command);
                }
              } else if (val == TableContextMenuItem.OFFLINE) {
                _debugGoOffline();
              } else if (val == TableContextMenuItem.FETCH) {
                unawaited(_refresh());
              } else if (val == TableContextMenuItem.SORT) {
                BaseCommand? command = _createSortColumnCommand(pColumnName);
                if (command != null) {
                  commands.add(command);
                }
              } else if (val == TableContextMenuItem.EDIT) {
                _editRow(pRowIndex);
              }
              if (commands.isNotEmpty) {
                commands.insert(0, SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));
              }
              return commands;
            },
            pReason: "Table menu item pressed")
        .catchError(IUiService().handleAsyncError);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Selects the record.
  void _selectRecord(int pRowIndex, String? pColumnName, {Future<List<BaseCommand>> Function()? pAfterSelect}) {
    cancelSelect = false;
    IUiService()
        .saveAllEditors(
          pReason: "Select row in table",
          pId: model.id,
          pFunction: () async {
            List<BaseCommand> commands = [];

            if (cancelSelect) {
              FlutterUI.logUI.i("Select canceled, server sent reload");
              return commands;
            }

            if (pRowIndex >= dataChunk.data.length) {
              FlutterUI.logUI.i("Row index out of range: $pRowIndex");
              return commands;
            }

            Filter? filter = _createFilter(pRowIndex: pRowIndex);
            if (filter == null) {
              FlutterUI.logUI.w("Filter of table(${model.id}) null");
              return commands;
            }
            commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));

            commands.add(
              SelectRecordCommand(
                dataProvider: model.dataProvider,
                selectedRecord: pRowIndex,
                reason: "Tapped",
                filter: filter,
                selectedColumn: pColumnName,
              ),
            );
            if (pAfterSelect != null) {
              commands.add(FunctionCommand(function: pAfterSelect, reason: "After selected row"));
            }

            return commands;
          },
        )
        .catchError(IUiService().handleAsyncError);
  }

  /// Sends a [SetValuesCommand] for this row.
  BaseCommand _setValues(int pRowIndex, List<String> pColumnNames, List<dynamic> pValues, String pEditorColumnName) {
    return SetValuesCommand(
      componentId: model.id,
      dataProvider: model.dataProvider,
      columnNames: pColumnNames,
      editorColumnName: pEditorColumnName,
      values: pValues,
      filter: _createFilter(pRowIndex: pRowIndex),
      reason: "Values changed in table",
    );
  }

  /// Inserts a new record.
  void _insertRecord() {
    IUiService()
        .saveAllEditors(
          pReason: "Insert row in table",
          pId: model.id,
          pFunction: () async {
            List<BaseCommand> commands = [];

            commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Insert on table"));

            commands.add(_createInsertCommand());

            return commands;
          },
        )
        .catchError(IUiService().handleAsyncError);
  }

  InsertRecordCommand _createInsertCommand() {
    return InsertRecordCommand(dataProvider: model.dataProvider, reason: "Inserted");
  }

  /// Gets the value of a specified column
  dynamic _getValue({required String pColumnName, int? pRowIndex}) {
    int rowIndex = pRowIndex ?? selectedRow;
    if (rowIndex == -1 || rowIndex >= dataChunk.data.length) {
      return;
    }

    int colIndex = dataChunk.columnDefinitions.indexWhere((element) => element.name == pColumnName);

    if (colIndex == -1) {
      return;
    }

    return dataChunk.data[rowIndex]![colIndex];
  }

  /// Creates an identifying filter for this row.
  Filter? _createFilter({required int pRowIndex}) {
    int rowIndex = pRowIndex;

    List<String> listColumnNames = [];
    List<dynamic> listValues = [];

    /* Old way of doing it.
     if (metaData!.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData!.primaryKeyColumns);
    } else if (metaData!.primaryKeyColumns.contains("ID")) {
      listColumnNames.add("ID");
    } else {
      listColumnNames.addAll(
        metaData!.columns
            .where((column) =>
                column.cellEditorClassName == FlCellEditorClassname.TEXT_CELL_EDITOR ||
                column.cellEditorClassName == FlCellEditorClassname.NUMBER_CELL_EDITOR)
            .map((column) => column.name),
      ); 
    */

    if (metaData.primaryKeyColumns.isNotEmpty) {
      listColumnNames.addAll(metaData.primaryKeyColumns);
    } else {
      listColumnNames.addAll(metaData.columnDefinitions.map((e) => e.name));
    }

    for (String column in listColumnNames) {
      listValues.add(_getValue(pColumnName: column, pRowIndex: rowIndex));
    }

    return Filter(values: listValues, columnNames: listColumnNames);
  }

  PopupMenuItem<TableContextMenuItem> _createContextMenuItem(IconData icon, String text, TableContextMenuItem value) {
    return PopupMenuItem<TableContextMenuItem>(
      enabled: true,
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 24,
            alignment: Alignment.center,
            child: FaIcon(
              icon,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              FlutterUI.translate(
                text,
              ),
              style: model.createTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  /// Debug feature -> Takes one dataprovider offline
  void _debugGoOffline() {
    BeamState state = context.currentBeamLocation.state as BeamState;
    String workscreenName = state.pathParameters['workScreenName']!;
    OfflineUtil.initOffline(workscreenName);
  }

  /// Creates a delete command for this row.
  DeleteRecordCommand? _createDeleteCommand(int pIndex) {
    Filter? filter = _createFilter(pRowIndex: pIndex);

    if (filter == null) {
      FlutterUI.logUI.w("Filter of table(${model.id}) null");
      return null;
    }
    return DeleteRecordCommand(
      dataProvider: model.dataProvider,
      selectedRow: pIndex,
      reason: "Swiped",
      filter: filter,
    );
  }

  BaseCommand? _createSortColumnCommand(String pColumnName, [bool pAdditive = false]) {
    if (!model.sortOnHeaderEnabled) {
      return null;
    }
    ColumnDefinition? coldef = metaData.columnDefinitions.firstWhereOrNull((element) => pColumnName == element.name);

    if (coldef == null || !coldef.sortable) {
      return null;
    }

    SortDefinition? currentSortDefinition =
        metaData.sortDefinitions?.firstWhereOrNull((sortDef) => sortDef.columnName == pColumnName);
    bool exists = currentSortDefinition != null;

    currentSortDefinition?.mode = currentSortDefinition.nextMode;
    currentSortDefinition ??= SortDefinition(columnName: pColumnName);

    List<SortDefinition> sortDefs;
    if (pAdditive && metaData.sortDefinitions != null) {
      sortDefs = [
        ...metaData.sortDefinitions ?? {},
        if (!exists) currentSortDefinition,
      ];
    } else {
      sortDefs = [currentSortDefinition];
    }

    return SortCommand(
        dataProvider: model.dataProvider, sortDefinitions: sortDefs, reason: "sorted", columnName: pColumnName);
  }

  void _sortColumn(String pColumnName, [bool pAdditive = false]) {
    BaseCommand? sortCommand = _createSortColumnCommand(pColumnName, pAdditive);
    if (sortCommand == null) {
      return;
    }

    IUiService()
        .saveAllEditors(
          pReason: "Select row in table",
          pId: model.id,
          pFunction: () async {
            List<BaseCommand> commands = [];

            commands.add(SetFocusCommand(componentId: model.id, focus: true, reason: "Value edit Focus"));

            commands.add(sortCommand);

            return commands;
          },
        )
        .catchError(IUiService().handleAsyncError);
  }

  void _editRow(int pRowIndex) {
    List<ColumnDefinition> columnsToShow = tableSize.columnWidths.keys
        .map((e) => dataChunk.columnDefinitions.firstWhere((element) => element.name == e))
        .toList();

    Map<String, dynamic> values = {};
    for (ColumnDefinition colDef in columnsToShow) {
      values[colDef.name] = dataChunk.getValue(colDef.name, pRowIndex);
    }

    _selectRecord(
      pRowIndex,
      null,
      pAfterSelect: () async {
        if (IStorageService().isVisibleInUI(model.id)) {
          if (_isUpdateAllowed && model.editable) {
            _showDialog(
              rowIndex: pRowIndex,
              columnDefinitions: columnsToShow,
              values: values,
              onEndEditing: _setValueEnd,
              newValueNotifier: dialogValueNotifier,
            );
          }
        }
        return [];
      },
    );
  }

  void _onSlideAction(int pRowIndex, TableRowSlideAction pAction) {
    if (pAction == TableRowSlideAction.DELETE) {
      BaseCommand? deleteCommand = _createDeleteCommand(pRowIndex);
      if (deleteCommand != null) {
        IUiService().sendCommand(deleteCommand);
      }
    } else if (pAction == TableRowSlideAction.EDIT) {
      _editRow(pRowIndex);
    }
  }

  Set<TableRowSlideAction> _slideActions() {
    Set<TableRowSlideAction> actionSet = {};

    if (model.editable && model.isEnabled) {
      if (_isUpdateAllowed) {
        actionSet.add(TableRowSlideAction.EDIT);
      }

      if (_isDeleteEnabled) {
        actionSet.add(TableRowSlideAction.DELETE);
      }
    }
    return actionSet;
  }

  void _showDialog({
    required int rowIndex,
    required List<ColumnDefinition> columnDefinitions,
    required Map<String, dynamic> values,
    required void Function(dynamic, int, String) onEndEditing,
    required ValueNotifier<Map<String, dynamic>?> newValueNotifier,
  }) {
    if (currentEditDialog == null) {
      if (columnDefinitions.length == 1 &&
          (columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
                  FlCellEditorClassname.LINKED_CELL_EDITOR ||
              columnDefinitions.first.cellEditorJson[ApiObjectProperty.className] ==
                  FlCellEditorClassname.DATE_CELL_EDITOR)) {
        ColumnDefinition colDef = columnDefinitions.first;
        ICellEditor cellEditor = ICellEditor.getCellEditor(
            pName: model.name,
            pCellEditorJson: columnDefinitions.first.cellEditorJson,
            columnDefinition: colDef,
            onChange: (_) {},
            onEndEditing: (value) => onEndEditing(value, rowIndex, colDef.name),
            onFocusChanged: (_) {},
            columnName: colDef.name,
            dataProvider: model.dataProvider,
            isInTable: true);

        if (cellEditor is FlDateCellEditor) {
          currentEditDialog = cellEditor.openDatePicker();
        } else if (cellEditor is FlLinkedCellEditor) {
          currentEditDialog = cellEditor.openLinkedCellPicker();
        }
        cellEditor.dispose();
      } else {
        currentEditDialog = IUiService().openDialog(
          pBuilder: (context) => FlTableEditDialog(
            rowIndex: rowIndex,
            model: model,
            columnDefinitions: columnDefinitions,
            values: values,
            onEndEditing: onEndEditing,
            newValueNotifier: newValueNotifier,
          ),
        );
      }

      if (currentEditDialog != null) {
        currentEditDialog!.whenComplete(() => currentEditDialog = null);
      }
    }
  }

  void _closeDialog() {
    if (currentEditDialog != null) {
      currentEditDialog = null;
      Navigator.pop(context);
    }
  }
}

enum TableContextMenuItem { INSERT, DELETE, OFFLINE, EDIT, SORT, FETCH }
