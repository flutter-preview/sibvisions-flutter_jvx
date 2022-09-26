import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../../flutter_jvx.dart';
import '../../../../../../services.dart';
import '../../../../../model/data/column_definition.dart';
import '../../../../../model/data/filter_condition.dart';
import '../../../../../model/response/dal_meta_data_response.dart';
import '../../../../../util/i_types.dart';

/// Table and column names are escaped via double quotes.<br>
/// https://www.sqlite.org/lang_keywords.html
///
/// Has to be closed with [close()]
class OfflineDatabase {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Constants
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  static const OFFLINE_APPS_TABLE = "jvx_offline_apps";
  static const OFFLINE_METADATA_TABLE = "jvx_offline_metadata";

  static const COLUMN_PREFIX = "\$OLD\$_";
  static const STATE_COLUMN = '\$STATE\$';
  static const ROW_STATE_INSERTED = "I";
  static const ROW_STATE_UPDATED = "U";
  static const ROW_STATE_DELETED = "D";

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Instance of sql database
  late Database db;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  OfflineDatabase._();

  static Future<OfflineDatabase> open() async {
    var offlineDatabase = OfflineDatabase._();
    await offlineDatabase.init();
    return offlineDatabase;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Init and define Database
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  init() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    db = await openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), 'jvx_offline_data.sqlite'),
      onUpgrade: (db, oldVersion, newVersion) => _initStructTables(db),
      // Set the version. This executes the onCreate/onUpgrade function and provides a
      // path to perform database upgrades and downgrades.
      //TODO check version (sync with app_version?)
      version: 1,
    );
  }

  createTables(List<DalMetaDataResponse> dalMetaData, {bool onlyIfNotExists = false}) {
    return Future.wait([
      _createStructTables(IConfigService().getAppName()!, dalMetaData),
      ...dalMetaData.map((table) async {
        if (onlyIfNotExists && (await tableExists(table.dataProvider))) {
          return Future.value(null);
        }

        String createTableSQL = _createTable(table);
        FlutterJVx.log.d("Create Table SQL:\n$createTableSQL");
        // Run the CREATE TABLE statement on the database.
        return db.execute(createTableSQL);
      })
    ]);
  }

  _initStructTables(Database db) async {
    String createAppsTableSQL = """
CREATE TABLE IF NOT EXISTS $OFFLINE_APPS_TABLE (
   ID INTEGER PRIMARY KEY,
   APP TEXT NOT NULL UNIQUE
);""";
    await db.execute(createAppsTableSQL);

    String createMetaDataTablesSQL = """
CREATE TABLE IF NOT EXISTS $OFFLINE_METADATA_TABLE (
   ID INTEGER PRIMARY KEY,
   APP_ID INTEGER NOT NULL,
   DATA_PROVIDER TEXT NOT NULL,
   TABLE_NAME TEXT NOT NULL,
   META_DATA TEXT NOT NULL,
   FOREIGN KEY(APP_ID) REFERENCES $OFFLINE_APPS_TABLE(ID) ON UPDATE CASCADE ON DELETE CASCADE
);""";
    await db.execute(createMetaDataTablesSQL);
  }

  Future<dynamic> _createStructTables(String appName, List<DalMetaDataResponse> dalMetaData) async {
    var appId = await db.insert(OFFLINE_APPS_TABLE, {"APP": appName});

    return Future.wait(dalMetaData.map((metaData) => db.insert(OFFLINE_METADATA_TABLE, {
          "APP_ID": appId,
          "DATA_PROVIDER": metaData.dataProvider,
          "TABLE_NAME": formatOfflineTableName(metaData.dataProvider),
          "META_DATA": jsonEncode(metaData.originalJson),
        })));
  }

  ///Convenience method for [dropTable]
  Future<dynamic> dropTables(List<DalMetaDataResponse> dalMetaData) {
    return Future.wait([
      ...dalMetaData.map((table) => dropTable(table.dataProvider)),
      _dropStructTables(IConfigService().getAppName()!),
    ]);
  }

  Future<int> _dropStructTables(String appName) {
    return db.delete(OFFLINE_APPS_TABLE, where: "APP LIKE ?", whereArgs: [appName]);
  }

  Future<List<DalMetaDataResponse>> getMetaData({String? pDataProvider}) {
    List<String> whereArgs = [IConfigService().getAppName()!];
    if (pDataProvider != null) {
      whereArgs.add(pDataProvider);
    }
    return db
        .query(
          OFFLINE_METADATA_TABLE,
          columns: ["META_DATA"],
          where:
              "APP_ID = (SELECT ID FROM $OFFLINE_APPS_TABLE WHERE APP LIKE ?)${pDataProvider != null ? " AND DATA_PROVIDER LIKE ?" : ""}",
          whereArgs: whereArgs,
        )
        .then((result) => result
            .map((e) => DalMetaDataResponse.fromJson(pJson: jsonDecode(e["META_DATA"] as String), originalRequest: ""))
            .toList(growable: false));
  }

  Future<void> close() {
    return db.close();
  }

  bool isClosed() {
    return !db.isOpen;
  }

  ///Constructs the identifier for the offline table.
  String formatOfflineTableName(String tableName) {
    return tableName.replaceAll(RegExp(r"[^\w_]"), "_");
  }

  ///Constructs the identifier for the offline column.
  String formatOfflineColumnName(String columnName) {
    return COLUMN_PREFIX + columnName;
  }

  String _createTable(DalMetaDataResponse pTable) {
    var sql = StringBuffer('CREATE TABLE "${formatOfflineTableName(pTable.dataProvider)}" (');

    for (var column in pTable.columns) {
      sql.write(_createColumn(column.name, column));
      sql.write(_createColumn(formatOfflineColumnName(column.name), column, nullable: true));
    }
    sql.write('"$STATE_COLUMN" TEXT\n');

    sql.write(");");
    return sql.toString();
  }

  String _createColumn(String pColumnName, ColumnDefinition pColumn, {bool? nullable}) {
    var columnDef = StringBuffer('"$pColumnName" ');
    columnDef.write(Types.convertToSQLite(pColumn.dataTypeIdentifier, scale: pColumn.scale));

    //TODO Check default value

    if (pColumn.length != null) {
      columnDef.write(' CHECK(length("$pColumnName") <= ${pColumn.length})');
    }

    if (pColumn.precision != null) {
      columnDef.write(' CHECK("$pColumnName" = ROUND("$pColumnName", ${pColumn.precision}))');
    }

    if (!(pColumn.signed ?? true)) {
      columnDef.write(' CHECK("$pColumnName") >= 0)');
    }

    columnDef.write(",\n");
    return columnDef.toString();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Table management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns true if table with [pTableName] exists
  Future<bool> tableExists(String pTableName) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM sqlite_master WHERE TYPE = \'table\' AND NAME = ?;';
    return db.rawQuery(sql, [formatOfflineTableName(pTableName)])
        // Check if returned count in select is 1
        .then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Drops table with name [pTableName]
  Future<void> dropTable(String pTableName) {
    return db.execute('DROP TABLE IF EXISTS "${formatOfflineTableName(pTableName)}";');
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Row Management
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<Map<String, List<Map<String, Object?>>>> getChangedRows(String pDataProvider) async {
    if (await tableExists(pDataProvider)) {
      return db
          .query(formatOfflineTableName(pDataProvider), where: '"$STATE_COLUMN" IS NOT NULL')
          .then((value) => groupBy(value, (p0) => p0[STATE_COLUMN] as String));
    } else {
      return {};
    }
  }

  Future<int> resetStates(String pDataProvider, List<Map<String, Object?>> pResetRows) {
    if (pResetRows.isEmpty) {
      return Future.value(0);
    }

    String where = "1 = 0";
    for (var row in pResetRows) {
      if (row.isNotEmpty) {
        where += " OR (";
        List<String> columns = [];
        for (var column in row.entries) {
          String s = '"${column.key}"';
          if (column.value != null) {
            s += " = ?";
          } else {
            s += " IS NULL";
          }
          columns.add(s);
        }
        where += "${columns.join(" AND ")})";
      }
    }

    return db.update(
      formatOfflineTableName(pDataProvider),
      {'"$STATE_COLUMN"': null},
      where: where,
      whereArgs: pResetRows.expand((e) => e.values).whereType<Object>().toList(growable: false),
    );
  }

  /// Checks if any row exists in [pTableName]
  /// if [pWhere] is not null, check with [pWhere] applied.
  /// Returns true if at least one row is returned.
  Future<bool> rowExists({required String pTableName, Map<String, dynamic>? pFilter}) {
    String sql = 'SELECT COUNT(*) AS COUNT FROM "${formatOfflineTableName(pTableName)}"';
    if (pFilter != null) {
      sql += " WHERE${pFilter.keys.map((key) => '"$key" = ?').join(" AND ")}";
      sql += ' AND "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    }

    return db.rawQuery(sql, [...?pFilter?.values])
        // Check returned count
        .then((results) => results[0]['COUNT'] as int > 0);
  }

  /// Executes a SQL SELECT COUNT query and returns the number of rows found.
  Future<int> getCount({required String pTableName, List<FilterCondition>? pFilters}) {
    var where = _getWhere(pFilters);
    return db
        .query(formatOfflineTableName(pTableName),
            columns: ["COUNT(*) AS COUNT"], where: where?[0], whereArgs: where?[1])
        .then((results) => results[0]['COUNT'] as int);
  }

  /// Executes a SQL SELECT query and returns a list of the rows that were found.
  Future<List<Map<String, dynamic>>> select(
      {required String pTableName,
      List<String>? pColumns,
      List<FilterCondition>? pFilters,
      String? pGroupBy,
      String? pHaving,
      String? pOrderBy,
      int? pLimit,
      int? pOffset}) {
    var where = _getWhere(pFilters);
    return db.query(formatOfflineTableName(pTableName),
        columns: pColumns,
        where: where?[0],
        whereArgs: where?[1],
        groupBy: pGroupBy,
        having: pHaving,
        orderBy: pOrderBy,
        limit: pLimit,
        offset: pOffset);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CUD Operations
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a INSERT query, sets the state to Inserting and returns the last inserted row ID.
  Future<int> insert({required String pTableName, required Map<String, dynamic> pInsert, Transaction? txn}) {
    pInsert['"$STATE_COLUMN"'] = ROW_STATE_INSERTED;
    return rawInsert(pTableName: pTableName, pInsert: pInsert, txn: txn);
  }

  /// Executes a SQL INSERT query and returns the last inserted row ID.
  Future<int> rawInsert({required String pTableName, required Map<String, dynamic> pInsert, Transaction? txn}) {
    return (txn ?? db).insert(formatOfflineTableName(pTableName), pInsert);
  }

  /// Executes a SQL UPDATE query and returns the number of changes made.
  Future<int> update(
      {required String pTableName, required Map<String, dynamic> pUpdate, List<FilterCondition>? pFilters}) {
    var where = _getWhere(pFilters);
    var offlineTableName = formatOfflineTableName(pTableName);

    return db.transaction((txn) async {
      String? state = await _getState(offlineTableName, where: where, txn: txn);
      if (state == null) {
        //Hasn't been touched yet, copy values to $OLD$ columns

        List<String> tableColumns = await _getTableColumns(offlineTableName, txn: txn);

        Map<String, dynamic> updateColumns = {'"$STATE_COLUMN"': null};
        //Constructs "$OLD$_age = age"
        tableColumns.forEach((column) => updateColumns['"${formatOfflineColumnName(column)}"'] = '"$column"');

        await _updateOfflineColumns(
          txn,
          offlineTableName,
          updateColumns,
          where,
          [ROW_STATE_UPDATED, ...?where?[1]],
        );
      }

      //age = 5
      //UPDATE AGE = 10
      //$OLD$_age = 5, age = 10
      return txn.update(offlineTableName, pUpdate, where: where?[0], whereArgs: where?[1]);
    });
  }

  Future<void> _updateOfflineColumns(Transaction txn, String tableName, Map<String, dynamic> updateColumns,
      List<dynamic>? where, List<dynamic> whereArgs) async {
    String updateClause = updateColumns.entries.map((entry) => '${entry.key} = ${entry.value ?? "?"}').join(", ");
    await txn.rawUpdate('UPDATE "$tableName" SET $updateClause WHERE ${where?[0]}', whereArgs);
  }

  /// Executes a SQL DELETE query and returns the number of changes made.
  Future<int> delete({required String pTableName, List<FilterCondition>? pFilters}) {
    var where = _getWhere(pFilters);
    var offlineTableName = formatOfflineTableName(pTableName);

    return db.transaction((txn) async {
      String? state = await _getState(offlineTableName, where: where, txn: txn);
      if (state != null) {
        if (state == ROW_STATE_INSERTED) {
          // Delete row and return
          return txn.delete(offlineTableName, where: where?[0], whereArgs: where?[1]);
        } else if (state == ROW_STATE_UPDATED) {
          // Reset column to preserve primary key columns and then set Deleted

          List<String> tableColumns = await _getTableColumns(pTableName, txn: txn);

          Map<String, dynamic> updateColumns = {};
          // Constructs "age = $OLD$_age"
          tableColumns.forEach((column) => updateColumns['"$column"'] = '"${formatOfflineColumnName(column)}"');

          await _updateOfflineColumns(
            txn,
            offlineTableName,
            updateColumns,
            where,
            where?[1],
          );
        }
      }
      // Set state to Deleted (D)
      return txn.update(offlineTableName, {'"$STATE_COLUMN"': ROW_STATE_DELETED},
          where: where?[0], whereArgs: where?[1]);
    });
  }

  ///Build where string and exclude all "deleted" columns
  List<dynamic>? _getWhere(List<FilterCondition>? pFilters) {
    String where = '"$STATE_COLUMN" IS NULL OR "$STATE_COLUMN" != \'$ROW_STATE_DELETED\'';
    if (!(pFilters?.isEmpty ?? true)) {
      String filterWhere = pFilters!.map((e) => _buildWhereClause(e)).where((s) => s != null).join(") AND (");
      where = '(($filterWhere)) AND ($where)';
      var whereArgs = pFilters.expand((e) => e.getValues()).map((e) {
        if (e is String) {
          return e.replaceAll("*", "%").replaceAll("?", "_");
        }
        return e;
      }).toList();
      return [where, whereArgs];
    }
    return [where, null];
  }

  String? _buildWhereClause(FilterCondition? condition) {
    String? where;

    if (condition != null) {
      String? topWhere;
      if (condition.columnName != null) {
        topWhere = _getWhereCondition(condition);
      }

      List<FilterCondition> subConditions = [
        if (condition.condition != null) condition.condition!,
        ...condition.conditions,
      ];

      if (topWhere != null || subConditions.isNotEmpty) {
        where = [
          if (topWhere != null) topWhere,
          ...subConditions
              .map((subCondition) => _buildWhereClause(subCondition))
              .where((s) => s != null)
              .map((e) => "($e)")
        ].join(" ${condition.operatorType.name} ");
      }
    }
    return where;
  }

  String _getWhereCondition(FilterCondition condition) {
    if (condition.value != null) {
      String operator;
      switch (condition.compareType) {
        case CompareType.LIKE:
        case CompareType.LIKE_IGNORE_CASE:
          operator = "LIKE";
          break;
        case CompareType.LESS:
          operator = "<";
          break;
        case CompareType.LESS_EQUALS:
          operator = "<=";
          break;
        case CompareType.GREATER:
          operator = ">";
          break;
        case CompareType.GREATER_EQUALS:
          operator = ">=";
          break;
        case CompareType.EQUALS:
        default:
          operator = "=";
      }

      String clause;
      if (condition.compareType.toString().toLowerCase().contains("ignore_case")) {
        clause = "LOWER(${condition.columnName}) $operator LOWER(?)";
      } else {
        clause = "${condition.columnName} $operator ?";
      }
      if (condition.not == true) {
        return "NOT ($clause)";
      } else {
        return clause;
      }
    } else {
      if (condition.not == true) {
        return "${condition.columnName} NOT IS NULL";
      } else {
        return "${condition.columnName} IS NULL";
      }
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // SQL statement processing
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Executes a List of sql statements in a batch operation (single atomic operation)
  batch({required List<String> pSqlStatements}) {
    return db.transaction((txn) {
      var batch = txn.batch();
      pSqlStatements.forEach((sql) {
        batch.execute(sql);
      });
      return batch.commit();
    });
  }

  /// Executes a list of sql statements, calls [pProgressCallback] after each statement
  bulk({required Iterable<String> pSqlStatements, VoidCallback? pProgressCallback}) {
    return db.transaction((txn) {
      return Future.forEach(pSqlStatements, (String sql) async {
        await txn.execute(sql);
        if (pProgressCallback != null) {
          pProgressCallback();
        }
      });
    });
  }

  Future<String?> _getState(String pTableName, {List<dynamic>? where, Transaction? txn}) {
    return (txn ?? db)
        .query(pTableName, columns: [STATE_COLUMN], where: where?[0], whereArgs: where?[1])
        .then((value) => value.firstOrNull?[STATE_COLUMN] as String?);
  }

  Future<List<String>> _getTableColumns(String pTableName, {Transaction? txn}) {
    return (txn ?? db)
        .rawQuery("SELECT NAME FROM PRAGMA_TABLE_INFO('$pTableName') WHERE NAME NOT LIKE ? AND NAME NOT LIKE ?;", [
      "$COLUMN_PREFIX%",
      STATE_COLUMN,
    ]).then((value) => value.map((e) => e['name'] as String).toList(growable: false));
  }
}
