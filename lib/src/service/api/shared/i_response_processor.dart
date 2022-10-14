import '../../../model/command/base_command.dart';
import '../../../model/request/i_api_request.dart';
import '../../../model/response/api_response.dart';

abstract class IResponseProcessor<T extends ApiResponse> {
  List<BaseCommand> processResponse(T pResponse, IApiRequest? pRequest);
}
