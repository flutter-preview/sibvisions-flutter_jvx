import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/component/dummy/fl_dummy_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlDummyWidget extends FlStatelessWidget<FlDummyModel> {
  const FlDummyWidget({Key? key, this.width, this.height, required FlDummyModel model}) : super(key: key, model: model);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      child: Text(
        "Dummy for ${model.id}",
        textAlign: TextAlign.end,
      ),
      alignment: Alignment.bottomLeft,
    );
  }
}