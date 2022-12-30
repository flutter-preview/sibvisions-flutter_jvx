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

import '../../../../../model/command/api/fetch_command.dart';
import '../../../../../model/command/base_command.dart';
import '../../../../../model/command/data/change_selected_row_command.dart';
import '../../../../../model/command/data/data_command.dart';
import '../../../../../model/command/data/delete_provider_data_command.dart';
import '../../../../../model/command/data/delete_row_command.dart';
import '../../../../../model/command/data/get_data_chunk_command.dart';
import '../../../../../model/command/data/get_meta_data_command.dart';
import '../../../../../model/command/data/get_selected_data_command.dart';
import '../../../../../model/command/data/save_fetch_data_command.dart';
import '../../../../../model/command/data/save_meta_data_command.dart';
import '../../../../../model/command/ui/open_error_dialog_command.dart';
import '../../../../../model/data/subscriptions/data_chunk.dart';
import '../../../../../model/data/subscriptions/data_record.dart';
import '../../../../../model/response/dal_meta_data_response.dart';
import '../../../../data/i_data_service.dart';
import '../../../../ui/i_ui_service.dart';
import '../../i_command_processor.dart';

/// Sends [DataCommand] to their respective processor
class DataProcessor extends ICommandProcessor<DataCommand> {
  @override
  Future<List<BaseCommand>> processCommand(DataCommand command) async {
    if (command is SaveMetaDataCommand) {
      return saveMetaData(command);
    } else if (command is SaveFetchDataCommand) {
      return saveFetchData(command);
    } else if (command is GetSelectedDataCommand) {
      return getSelectedData(command);
    } else if (command is GetDataChunkCommand) {
      return getDataChunk(command);
    } else if (command is DeleteProviderDataCommand) {
      return deleteDataProviderData(command);
    } else if (command is ChangeSelectedRowCommand) {
      return changeSelectedRow(command);
    } else if (command is GetMetaDataCommand) {
      return getMetaData(command);
    } else if (command is DeleteRowCommand) {
      return deleteRow(command);
    }

    return [];
  }

  Future<List<BaseCommand>> deleteRow(DeleteRowCommand command) async {
    // set selected row of databook
    bool success = await IDataService().deleteRow(
      pDataProvider: command.dataProvider,
      pDeletedRow: command.deletedRow,
      pNewSelectedRow: command.newSelectedRow,
    );

    // Notify components that their selected row changed, if setting the row failed show error dialog.
    if (success) {
      IUiService().notifyDataChange(
        pDataProvider: command.dataProvider,
      );
    } else {
      return [
        OpenErrorDialogCommand(
          message: "Setting new selected row failed",
          reason: "Setting new selected row failed",
        )
      ];
    }
    return [];
  }

  Future<List<BaseCommand>> getMetaData(GetMetaDataCommand command) async {
    bool needFetch = IDataService().getDataBook(command.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: command.dataProvider,
          fromRow: 0,
          rowCount: -1,
          reason: "Fetch for ${command.runtimeType}",
        )
      ];
    }

    DalMetaDataResponse meta = IDataService().getMetaData(pDataProvider: command.dataProvider);

    IUiService().setMetaData(
      pSubId: command.subId,
      pDataProvider: command.dataProvider,
      pMetaData: meta,
    );

    return [];
  }

  Future<List<BaseCommand>> changeSelectedRow(ChangeSelectedRowCommand command) async {
    // set selected row of databook
    bool success = IDataService().setSelectedRow(
      pDataProvider: command.dataProvider,
      pNewSelectedRow: command.newSelectedRow,
    );

    // Notify components that their selected row changed, if setting the row failed show error dialog.
    if (success) {
      IUiService().notifyDataChange(
        pDataProvider: command.dataProvider,
      );
    } else {
      return [
        OpenErrorDialogCommand(
          message: "Setting new selected row failed",
          reason: "Setting new selected row failed",
        )
      ];
    }
    return [];
  }

  Future<List<BaseCommand>> deleteDataProviderData(DeleteProviderDataCommand command) async {
    await IDataService().deleteDataFromDataBook(
      pDataProvider: command.dataProvider,
      pFrom: command.fromIndex,
      pTo: command.toIndex,
      pDeleteAll: command.deleteAll,
    );
    return [];
  }

  Future<List<BaseCommand>> saveMetaData(SaveMetaDataCommand pCommand) async {
    await IDataService().updateMetaData(pChangedResponse: pCommand.response);

    IUiService().notifyMetaDataChange(
      pDataProvider: pCommand.response.dataProvider,
    );

    return [];
  }

  Future<List<BaseCommand>> saveFetchData(SaveFetchDataCommand pCommand) async {
    await IDataService().updateData(pFetch: pCommand.response);

    IUiService().notifyDataChange(
      pDataProvider: pCommand.response.dataProvider,
    );

    return [];
  }

  Future<List<BaseCommand>> getSelectedData(GetSelectedDataCommand pCommand) async {
    bool needFetch = IDataService().getDataBook(pCommand.dataProvider) == null;

    if (needFetch) {
      return [
        FetchCommand(
          dataProvider: pCommand.dataProvider,
          fromRow: 0,
          rowCount: -1,
          reason: "Fetch for ${pCommand.runtimeType}",
        )
      ];
    }

    // Get Data record - is null if databook has no selected row
    DataRecord? record = await IDataService().getSelectedRowData(
      pColumnNames: pCommand.columnNames,
      pDataProvider: pCommand.dataProvider,
    );

    IUiService().setSelectedData(
      pSubId: pCommand.subId,
      pDataProvider: pCommand.dataProvider,
      pDataRow: record,
    );

    return [];
  }

  Future<List<BaseCommand>> getDataChunk(GetDataChunkCommand command) async {
    bool needFetch = await IDataService().checkIfFetchPossible(
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );

    if (needFetch) {
      return [
        FetchCommand(
          fromRow: command.from,
          rowCount: command.to != null ? command.to! - command.from : -1,
          dataProvider: command.dataProvider,
          reason: "Fetch for ${command.runtimeType}",
        )
      ];
    }

    DataChunk dataChunk = await IDataService().getDataChunk(
      pColumnNames: command.dataColumns,
      pFrom: command.from,
      pTo: command.to,
      pDataProvider: command.dataProvider,
    );
    dataChunk.update = command.isUpdate;

    IUiService().setChunkData(
      pDataChunk: dataChunk,
      pDataProvider: command.dataProvider,
      pSubId: command.subId,
    );
    return [];
  }
}
