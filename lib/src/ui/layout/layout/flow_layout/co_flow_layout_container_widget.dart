import 'package:flutter/material.dart';

import '../../widgets/co_flow_layout_widget.dart';
import '../co_layout_widget.dart';
import 'flow_layout_model.dart';

class CoFlowLayoutContainerWidget extends CoLayoutWidget {
  final FlowLayoutModel layoutModel;

  CoFlowLayoutContainerWidget({required this.layoutModel})
      : super(layoutModel: layoutModel);

  @override
  CoLayoutWidgetState<StatefulWidget> createState() =>
      CoFlowLayoutContainerWidgetState();
}

class CoFlowLayoutContainerWidgetState
    extends CoLayoutWidgetState<CoFlowLayoutContainerWidget> {
  List<CoFlowLayoutConstraintData> data = <CoFlowLayoutConstraintData>[];

  List<CoFlowLayoutConstraintData> _getConstraintData() {
    List<CoFlowLayoutConstraintData> data = <CoFlowLayoutConstraintData>[];

    widget.layoutModel.layoutConstraints.forEach((k, v) {
      if (k.componentModel.isVisible) {
        Key? key = widget.layoutModel
            .getKeyByComponentId(k.componentModel.componentId);

        if (key == null) {
          key = widget.layoutModel.createKey(k.componentModel.componentId);
        }

        data.add(CoFlowLayoutConstraintData(key: key, id: k, child: k));
      }
    });

    return data;
  }

  @override
  onChange() {
    if (mounted) {
      setState(() {
        data = _getConstraintData();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    data = _getConstraintData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CoFlowLayoutWidget(
        layoutState: widget.layoutModel.layoutState,
        key: layoutKey,
        container: widget.layoutModel.container,
        children: data,
        insMargin: widget.layoutModel.margins,
        horizontalGap: widget.layoutModel.horizontalGap,
        verticalGap: widget.layoutModel.verticalGap,
        horizontalAlignment: widget.layoutModel.horizontalAlignment,
        verticalAlignment: widget.layoutModel.verticalAlignment,
        orientation: widget.layoutModel.orientation,
        horizontalComponentAlignment:
            widget.layoutModel.horizontalComponentAlignment,
        verticalComponentAlignment:
            widget.layoutModel.verticalComponentAlignment,
        autoWrap: widget.layoutModel.autoWrap,
      ),
    );
  }
}
