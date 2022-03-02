import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/component/check_box/fl_check_box_model.dart';
import '../button/fl_button_wrapper.dart';
import 'fl_check_box_widget.dart';

class FlCheckBoxWrapper extends FlButtonWrapper<FlCheckBoxModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlCheckBoxWrapper({Key? key, required FlCheckBoxModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlCheckBoxWrapperState createState() => FlCheckBoxWrapperState();
}

class FlCheckBoxWrapperState<T extends FlCheckBoxModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlCheckBoxWidget checkboxWidget = FlCheckBoxWidget(
      model: model,
      onPress: buttonPressed,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: checkboxWidget);
  }
}
