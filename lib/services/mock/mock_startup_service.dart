import 'package:jvx_mobile_v3/model/startup/startup.dart';
import 'package:jvx_mobile_v3/model/startup/startup_resp.dart';
import 'package:jvx_mobile_v3/services/abstract/i_startup_service.dart';
import 'package:jvx_mobile_v3/services/network_service_response.dart';

class MockStartupService implements IStartupService {
  @override
  Future<NetworkServiceResponse<StartupResponse>> fetchStartupResponse(Startup startup) async {
    await Future.delayed(Duration(seconds: 2));
    return Future.value(NetworkServiceResponse(success: true, content: kStartupResponse, message: 'Error'));
  }
}

var kStartupResponse = new StartupResponse();