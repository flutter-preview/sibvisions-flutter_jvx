import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../model/component/label/fl_label_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_label_widget.dart';

class FlLabelWrapper extends BaseCompWrapperWidget<FlLabelModel> {
  FlLabelWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlLabelWrapperState createState() => _FlLabelWrapperState();
}

class _FlLabelWrapperState extends BaseCompWrapperState<FlLabelModel> {
  @override
  Widget build(BuildContext context) {
    final FlLabelWidget widget = FlLabelWidget(model: model);

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }
}