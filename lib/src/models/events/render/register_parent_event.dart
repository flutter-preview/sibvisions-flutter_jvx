import 'package:flutter_jvx/src/layout/i_layout.dart';
import 'package:flutter_jvx/src/models/events/base_event.dart';

class RegisterParentEvent extends BaseEvent {
  final String id;
  final ILayout layout;
  final String? layoutInsets;
  final String? layoutData;
  final List<String> childrenIds;

  RegisterParentEvent(
      {required Object origin,
      required String reason,
      required this.id,
      required this.layout,
      required this.layoutInsets,
      required this.layoutData,
      required this.childrenIds})
      : super(origin: origin, reason: reason);
}
