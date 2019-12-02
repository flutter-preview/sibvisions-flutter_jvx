import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/data/fetch_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/filter_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/set_values.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/model/properties/properties.dart';


class ComponentData {
  String dataProvider;
  bool isFetching = false;

  JVxData _data;
  JVxMetaData metaData;

  List<VoidCallback> _onDataChanged = [];
  List<VoidCallback> _onMetaDataChanged = [];

  ValueChanged<Request> addToRequestQueue;

  ComponentData(this.dataProvider);


  bool get deleteEnabled {
    if (metaData!=null && metaData.deleteEnabled!=null) return metaData.deleteEnabled;
    return false;
  }

  bool get updateEnabled {
    if (metaData!=null && metaData.updateEnabled!=null) return metaData.updateEnabled;
    return false;
  }

  bool get insertEnabled {
    if (metaData!=null && metaData.insertEnabled!=null) return metaData.insertEnabled;
    return false;
  }

  List<String> get primaryKeyColumns {
    if (metaData!=null && metaData.primaryKeyColumns!=null) return metaData.primaryKeyColumns;
    return null;
  }

  List<dynamic> primaryKeyColumnsForRow(int index) {
    if (metaData!=null && metaData.primaryKeyColumns!=null) return metaData.primaryKeyColumns;
    return null;
  }

  void updateData(JVxData pData, [bool overrideData = false]) {
    if (_data==null || _data.isAllFetched || overrideData) {
      _data = pData;
    } else {
      _data.records.addAll(pData.records);
      _data.selectedRow = pData.selectedRow;
      _data.isAllFetched = pData.isAllFetched;
    }

    if (_data.selectedRow==null)
      _data.selectedRow = 0;

    isFetching = false;
    _onDataChanged.forEach((d) => d());
  }

  void updateSelectedRow(int selectedRow) {
    if (_data.selectedRow!=selectedRow) {
      _data.selectedRow = selectedRow;
      _onDataChanged.forEach((d) => d());
    }
  }

  void updateMetaData(JVxMetaData pMetaData) {
    this.metaData = pMetaData;
    _onMetaDataChanged.forEach((d) => d());
  }

  dynamic getColumnData(BuildContext context, String columnName, int reload) {
    if (isFetching==false && (_data==null || reload==-1 ||
      (_data.selectedRow >= _data.records.length && !_data.isAllFetched))) {
      if (_data==null || _data.selectedRow==null || _data.selectedRow<0) {
        this._fetchData(context, reload, 0);
      } else {
        this._fetchData(context, reload, _data.selectedRow);
      }
    } 
    
    if (_data!=null && _data.selectedRow < _data.records.length) {
      return _getColumnValue(columnName);
    }

    return "";
  }

  JVxData getData(BuildContext context, int reload, int rowCountNeeded) {

    if (reload==-1 || (isFetching==false && (_data==null || !_data.isAllFetched))) {
      if (reload!=-1 && rowCountNeeded>=0 && _data!=null && _data.records != null && _data.records.length>=rowCountNeeded) {
        return _data;
      }
      
      this._fetchData(context, reload, rowCountNeeded);
    }
      
    return _data;
  }

  void selectRecord(BuildContext context, int index, [bool fetch = false]) {
    if (index < _data.records.length) {
      SelectRecord select = SelectRecord(
        dataProvider, 
        Filter(columnNames: this.primaryKeyColumns, values: _data.getRow(index, this.primaryKeyColumns)),
        index,
        RequestType.DAL_SELECT_RECORD);

      if (fetch!=null)
        select.fetch = fetch;

      addToRequestQueue(select);
      //_data.selectedRow = index;
      //_onDataChanged.forEach((d) => d());
      //BlocProvider.of<ApiBloc>(context).dispatch(select);
    } else {
      IndexError(index, _data.records, "Select Record", "Select record failed. Index out of bounds!");
    }
  }

  void deleteRecord(BuildContext context, int index) {
    if (index < _data.records.length) {
      SelectRecord select = SelectRecord(
        dataProvider, 
        Filter(columnNames: this.primaryKeyColumns, values: _data.getRow(index, this.primaryKeyColumns)),
        index,
        RequestType.DAL_DELETE);

      addToRequestQueue(select);
      //_data.selectedRow = index;
      //_onDataChanged.forEach((d) => d());
      //BlocProvider.of<ApiBloc>(context).dispatch(select);
    } else {
      IndexError(index, _data.records, "Delete Record", "Delete record failed. Index out of bounds!");
    }
  }

  void filterData(BuildContext context, String value, String editorComponentId) {
    FilterData filter = FilterData(dataProvider, value, editorComponentId, null, 0, 100);
    addToRequestQueue(filter);
  }

  void setValues(BuildContext context, List<dynamic> values, [List<dynamic> columnNames, Filter filter]) {
    SetValues setValues = SetValues(this.dataProvider, _data?.columnNames, values);

    if (columnNames!=null)
      setValues.columnNames = columnNames;

    if (filter!=null)
      setValues.filter = filter;

    addToRequestQueue(setValues);
    //BlocProvider.of<ApiBloc>(context).dispatch(setValues);
  }

  void _fetchData(BuildContext context, int reload, int rowCountNeeded) {
      this.isFetching = true;
      FetchData fetch = FetchData(dataProvider);

      if (reload==-1 && rowCountNeeded!=-1) {
        fetch.fromRow = 0;
        fetch.rowCount = rowCountNeeded - _data.records.length;
      } else if (_data!=null && !_data.isAllFetched && rowCountNeeded!=-1) {
        fetch.fromRow = _data.records.length;
        fetch.rowCount = rowCountNeeded - _data.records.length;
      }

      addToRequestQueue(fetch);
      //BlocProvider.of<ApiBloc>(context).dispatch(fetch);
  }

  dynamic _getColumnValue(String columnName) {
    int columnIndex = _getColumnIndex(columnName);
    if (columnIndex!=null && _data.selectedRow>=0 && _data.selectedRow < _data.records.length) {
      dynamic value = _data.records[_data.selectedRow][columnIndex];
      if (value is String)
        return Properties.utf8convert(value);
      else 
        return value;
    }

    return "";
  }

  int _getColumnIndex(String columnName) {
    return _data?.columnNames?.indexWhere((c) => c == columnName);
  }

  void registerDataChanged(VoidCallback callback) {
    _onDataChanged.add(callback);
  }

  void unregisterDataChanged(VoidCallback callback) {
    _onDataChanged.remove(callback);
  }

  void registerMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.add(callback);
  }

  void unregisterMetaDataChanged(VoidCallback callback) {
    _onMetaDataChanged.remove(callback);
  }
}