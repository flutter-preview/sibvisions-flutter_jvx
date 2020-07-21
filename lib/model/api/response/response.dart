import '../../../model/api/response/show_document.dart';
import '../../../utils/shared_preferences_helper.dart';
import '../../../model/api/response/response_data.dart';
import '../../so_action.dart';
import '../../../model/api/exceptions/api_exception.dart';
import '../../../model/api/request/request.dart';
import '../../../model/api/response/application_style_resp.dart';
import '../../../model/api/response/auth_data.dart';
import '../../../model/api/response/close_screen_action.dart';
import 'data/data_book.dart';
import '../../../model/api/response/download_action.dart';
import '../../../model/api/response/login_item.dart';
import '../../../model/api/response/menu.dart';
import '../../../model/api/response/screen_generic.dart';
import '../../../model/api/response/upload_action.dart';
import '../../../model/api/response/user_data.dart';

import 'application_meta_data.dart';
import 'data/dataprovider_changed.dart';
import 'language.dart';
import 'meta_data/data_book_meta_data.dart';
import 'response_object.dart';

class Response {
  dynamic download;
  String downloadFileName;
  RequestType requestType;
  bool error;
  bool errorHandled = false;
  String errorName;
  bool loading = false;
  String message;
  String title;
  SoAction action;
  String details;
  ApplicationMetaData applicationMetaData;
  Language language;
  LoginItem loginItem;
  Menu menu;
  AuthenticationData authenticationData;
  ResponseData responseData = ResponseData();
  ApplicationStyleResponse applicationStyle;
  DownloadAction downloadAction;
  UploadAction uploadAction;
  CloseScreenAction closeScreenAction;
  UserData userData;
  Request request;
  ShowDocument showDocument;

  Response();

  Response.fromJsonForAppStyle(Map<String, dynamic> json) {
    checkForError(json);
    error = false;
    errorHandled = false;
    if (json != null)
      applicationStyle = ApplicationStyleResponse.fromJson(json);
    else
      applicationStyle = null;
  }

  static checkForError(Map<String, dynamic> json) {
    if (json != null &&
        (json['title'] == 'Error' || json['title'] == 'Session Expired')) {
      throw new ApiException(
          details: json['details'],
          title: json['title'],
          name: json['name'],
          message: json['message']);
    }
  }

  Response.fromJson(List json) {
    if (json.isNotEmpty) {
      json.forEach((e) => checkForError(e));
    }

    error = false;
    errorHandled = false;

    json.forEach((r) {
      switch (getResponseObjectTypeEnum(r['name'])) {
        case ResponseObjectType.APPLICATIONMETADATA:
          applicationMetaData = ApplicationMetaData.fromJson(r);
          break;
        case ResponseObjectType.LANGUAGE:
          language = Language.fromJson(r);
          break;
        case ResponseObjectType.LOGIN:
          loginItem = LoginItem.fromJson(r);
          break;
        case ResponseObjectType.MENU:
          menu = Menu.fromJson(r);
          break;
        case ResponseObjectType.AUTHENTICATIONDATA:
          authenticationData = AuthenticationData.fromJson(r);
          break;
        case ResponseObjectType.SCREEN_GENERIC:
          if (r['changedComponents'] != null)
            responseData.screenGeneric =
                ScreenGeneric.fromChangedComponentsJson(r);
          else
            responseData.screenGeneric =
                ScreenGeneric.fromUpdateComponentsJson(r);
          break;
        case ResponseObjectType.DAL_FETCH:
          responseData.dataBooks.add(DataBook.fromJson(r));
          break;
        case ResponseObjectType.DAL_METADATA:
          responseData.dataBookMetaData.add(DataBookMetaData.fromJson(r));
          break;
        case ResponseObjectType.DAL_DATAPROVIDERCHANGED:
          responseData.dataproviderChanged.add(DataproviderChanged.fromJson(r));
          break;
        case ResponseObjectType.DOWNLOAD:
          downloadAction = DownloadAction.fromJson(r);
          SharedPreferencesHelper()
              .setDownloadFileName(downloadAction?.fileName);
          break;
        case ResponseObjectType.UPLOAD:
          uploadAction = UploadAction.fromJson(r);
          break;
        case ResponseObjectType.CLOSESCREEN:
          closeScreenAction = CloseScreenAction.fromJson(r);
          break;
        case ResponseObjectType.USERDATA:
          userData = UserData.fromJson(r);
          break;
        case ResponseObjectType.SHOWDOCUMENT:
          showDocument = ShowDocument.fromJson(r);
          break;
      }
    });
  }
}
