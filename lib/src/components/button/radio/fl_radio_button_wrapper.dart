import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../model/component/button/fl_radio_button_model.dart';
import '../fl_button_wrapper.dart';
import 'fl_radio_button_widget.dart';

class FlRadioButtonWrapper extends FlButtonWrapper<FlRadioButtonModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlRadioButtonWrapper({Key? key, required FlRadioButtonModel model}) : super(key: key, model: model);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlRadioButtonWrapperState createState() => FlRadioButtonWrapperState();
}

class FlRadioButtonWrapperState<T extends FlRadioButtonModel> extends FlButtonWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlRadioButtonWidget checkboxWidget = FlRadioButtonWidget(
      model: model,
      onPress: buttonPressed,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: checkboxWidget);
  }
}
