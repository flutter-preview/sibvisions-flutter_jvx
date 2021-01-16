import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/so_action.dart';

import 'models/action_component_model.dart';
import 'component_widget.dart';

typedef ActionCallback = void Function(BuildContext context, SoAction action, String classNameEventSourceRef);

abstract class CoActionComponentWidget extends ComponentWidget {
  final ActionComponentModel componentModel;
  CoActionComponentWidget({this.componentModel})
      : super(componentModel: componentModel);
}

abstract class CoActionComponentWidgetState<T extends CoActionComponentWidget>
    extends ComponentWidgetState<T> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
