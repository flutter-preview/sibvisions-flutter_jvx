import '../../src/model/config/api/endpoint_config.dart';
import '../../src/model/config/api/url_config.dart';

class ConfigGenerator {
  static EndpointConfig generateFixedEndpoints() {
    return EndpointConfig(
      startup: "/api/v3/startup",
      login: "/api/v2/login",
      openScreen: "/api/v2/openScreen",
      deviceStatus: "/api/deviceStatus",
      pressButton: "/api/v2/pressButton",
      setValue: "/api/comp/setValue",
      setValues: "/api/dal/setValues",
      download: "/download",
      closeTab: "/api/comp/closeTab",
      openTab: "/api/comp/selectTab",
      changePassword: "/api/changePassword",
      resetPassword: "/api/resetPassword",
      navigation: "/api/navigation",
      fetch: "/api/dal/fetch",
      logout: "/api/logout",
      filter: "/api/dal/filter",
      insertRecord: "/api/dal/insertRecord",
      selectRecord: "/api/dal/selectRecord",
      closeScreen: "/api/closeScreen",
      deleteRecord: "/api/dal/deleteRecord",
      closeFrame: "/api/closeFrame",
    );
  }

  static UrlConfig generateMobileServerUrl(String host, int port) {
    return UrlConfig(host: host, path: "/JVx.mobile/services/mobile", https: false, port: port);
  }

  static UrlConfig generateVisionX(String host) {
    return UrlConfig(host: host, path: "/services/mobile", https: false);
  }
}
