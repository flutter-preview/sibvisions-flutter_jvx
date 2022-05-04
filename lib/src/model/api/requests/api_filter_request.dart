import 'package:flutter_client/src/model/api/api_object_property.dart';
import 'package:flutter_client/src/model/api/requests/api_filter_model.dart';
import 'package:flutter_client/src/model/api/requests/i_api_request.dart';

class ApiFilterRequest implements IApiRequest {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Session id
  final String clientId;

  final String value;

  final String editorComponentId;

  final ApiFilterModel? filterCondition;

  final List<String>? columnNames;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ApiFilterRequest({
    required this.clientId,
    required this.columnNames,
    required this.value,
    required this.editorComponentId,
    required this.filterCondition,
    required this.dataProvider,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Interface implementation
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Map<String, dynamic> toJson() => {
        ApiObjectProperty.columnNames: columnNames,
        ApiObjectProperty.value: value,
        ApiObjectProperty.filterCondition: filterCondition,
        ApiObjectProperty.editorComponentId: editorComponentId,
        ApiObjectProperty.dataProvider: dataProvider,
      };
}
