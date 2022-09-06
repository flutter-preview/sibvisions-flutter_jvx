import 'package:flutter/widgets.dart';

import '../../layout/i_layout.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/base_cont_wrapper_state.dart';
import 'fl_panel_widget.dart';

class FlPanelWrapper extends BaseCompWrapperWidget<FlPanelModel> {
  FlPanelWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlPanelWrapperState();
}

class _FlPanelWrapperState extends BaseContWrapperState<FlPanelModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    layoutData.layout = ILayout.getLayout(model.layout, model.layoutData);
    layoutData.children = getUiService().getChildrenModels(model.id).map((e) => e.id).toList();

    buildChildren(pSetStateOnChange: false);
    registerParent();
  }

  @override
  receiveNewModel({required FlPanelModel newModel}) {
    layoutData.layout = ILayout.getLayout(newModel.layout, newModel.layoutData);
    layoutData.children = getUiService().getChildrenModels(model.id).map((e) => e.id).toList();

    super.receiveNewModel(newModel: newModel);

    buildChildren();
    registerParent();
  }

  @override
  Widget build(BuildContext context) {
    FlPanelWidget panelWidget = FlPanelWidget(
      model: model,
      children: children.values.toList(),
    );

    return (getPositioned(child: panelWidget));
  }
}
