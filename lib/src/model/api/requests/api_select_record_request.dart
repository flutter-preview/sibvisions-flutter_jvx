import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

class ApiSelectRecordRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  /// Data provider to change selected row of
  final String dataProvider;

  /// Filter
  final ApiFilterModel? filter;

  final int selectedRow;

  final bool fetch;

  final bool reload;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiSelectRecordRequest({
    required this.clientId,
    required this.dataProvider,
    required this.selectedRow,
    this.fetch = false,
    this.reload = false,
    this.filter,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.selectedRow: selectedRow,
        ApiObjectProperty.fetch: fetch,
        ApiObjectProperty.reload: reload,
        ApiObjectProperty.filter: filter?.toJson(),
      };
}