import 'dart:isolate';

import '../../../../../../model/command/base_command.dart';
import '../api_isolate_message.dart';

class ApiIsoltePressButtonMessage extends ApiIsolateMessage<List<BaseCommand>> {
  final String clientId;
  final String componentId;

  ApiIsoltePressButtonMessage({required this.clientId, required this.componentId});

  @override
  sendResponse({required List<BaseCommand> response, required SendPort sendPort}) {
    sendPort.send(response);
  }
}