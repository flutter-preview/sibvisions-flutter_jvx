import '../../data/filter_condition.dart';
import '../../request/filter.dart';
import 'api_command.dart';

class FilterCommand extends ApiCommand {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final String editorId;

  final String? value;

  final List<String>? columnNames;

  final Filter? filter;

  final FilterCondition? filterCondition;

  final String dataProvider;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FilterCommand({
    required this.editorId,
    required this.dataProvider,
    this.value,
    this.columnNames,
    this.filter,
    this.filterCondition,
    required String reason,
  }) : super(reason: reason);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  String get logString =>
      "FilterCommand: editorId: $editorId, value: $value, dataProvider: $dataProvider, columnNames: $columnNames, filter: $filter, filterCondition: $filterCondition, reason: $reason";
}
