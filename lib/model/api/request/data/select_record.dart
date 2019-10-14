
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

/// Model for the [SelectRecord] request.
class SelectRecord extends Request {
  String clientId;
  String dataProvider;
  bool fetch;
  Filter filter;

  SelectRecord(this.dataProvider, [this.fetch, this.filter])  : 
      super(clientId: globals.clientId, requestType: RequestType.DAL_SELECT_RECORD);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'clientId': clientId,
    'dataProvider': dataProvider,
    'fetch': fetch,
    'filter': filter?.toJson()
  };
}