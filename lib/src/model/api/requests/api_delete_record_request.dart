import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

import 'api_filter_model.dart';

class ApiDeleteRecordRequest extends IApiRequest {
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiDeleteRecordRequest({
    required this.clientId,
    required this.dataProvider,
    required this.selectedRow,
    this.filter,
    this.fetch = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.clientId: clientId,
        ApiObjectProperty.dataProvider: dataProvider,
        ApiObjectProperty.filter: filter?.toJson(),
        ApiObjectProperty.selectedRow: selectedRow,
        ApiObjectProperty.fetch: fetch,
      };
}