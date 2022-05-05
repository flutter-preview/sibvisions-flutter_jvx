
import 'package:flutter_client/src/model/config/api/api_config.dart';
import 'package:flutter_client/src/model/config/user/user_info.dart';

/// Defines the base construct of a [IConfigService]
/// Config service is used to store & access all configurable data,
/// also stores session based data such as clientId and userData.
// Author: Michael Schober
abstract class IConfigService {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Returns current clientId, if none is present returns null
  String? getClientId();

  /// Set clientId
  void setClientId(String? pClientId);

  /// Returns directory of the app, if app is started as web returns null
  String getDirectory();

  /// Set directory
  void setDirectory(String pDirectory);

  /// Returns the appName
  String getAppName();

  /// Set appName
  void setAppName(String pAppName);

  /// Returns current apiConfig
  ApiConfig getApiConfig();

  /// Set version
  void setVersion(String pVersion);

  String getVersion();

  /// Return menuMode
  MENU_MODE getMenuMode();

  /// Set MenuMode
  void setMenuMode(MENU_MODE pMenuMode);

  /// Returns info about the current user
  UserInfo? getUserInfo();

  /// Set user inf
  void setUserInfo(UserInfo pUserInfo);



}

enum MENU_MODE {
  GRID,
  GRID_GROUPED,
  LIST,
  LIST_GROUPED,
  DRAWER,
  SWIPER,
  TABS
}