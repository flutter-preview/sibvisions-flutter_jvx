import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../model/command/api/set_value_command.dart';
import '../../../model/command/base_command.dart';
import '../../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../../service/command/i_command_service.dart';
import '../../../service/ui/i_ui_service.dart';
import '../../../util/parse_util.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_text_field_widget.dart';

class FlTextFieldWrapper extends BaseCompWrapperWidget<FlTextFieldModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlTextFieldWrapper({super.key, required super.id});

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlTextFieldWrapperState createState() => FlTextFieldWrapperState();
}

class FlTextFieldWrapperState<T extends FlTextFieldModel> extends BaseCompWrapperState<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String lastSentValue = "";

  final TextEditingController textController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    FlTextFieldWidget widget = createWidget();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  receiveNewModel(T pModel) {
    super.receiveNewModel(pModel);

    updateText();
  }

  @override
  void initState() {
    super.initState();

    updateText();

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          endEditing(textController.text);
        });
      }
    });
  }

  @override
  Size calculateSize(BuildContext context) {
    Size size = super.calculateSize(context);

    double averageColumnWidth = ParseUtil.getTextWidth(text: "w", style: model.createTextStyle());

    double width = averageColumnWidth * model.columns;

    width += createWidget().extraWidthPaddings();

    return Size(width, size.height);
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlTextFieldWidget<FlTextFieldModel> createWidget() {
    FlTextFieldWidget textFieldWidget = FlTextFieldWidget(
      key: Key("${model.id}_Widget"),
      model: model,
      endEditing: endEditing,
      valueChanged: valueChanged,
      focusNode: focusNode,
      textController: textController,
    );
    return textFieldWidget;
  }

  void valueChanged(String pValue) {
    setState(() {});
  }

  void endEditing(String pValue) {
    if (!model.isReadOnly && lastSentValue != pValue) {
      ICommandService()
          .sendCommand(
            SetValueCommand(
              componentName: model.name,
              value: pValue,
              reason: "Editing has ended on ${model.id}",
            ),
          )
          .then((value) => lastSentValue = pValue)
          .catchError(IUiService().handleAsyncError);

      setState(() {});
    }
  }

  void updateText() {
    textController.value = textController.value.copyWith(
      text: model.text,
      selection: TextSelection.collapsed(offset: model.text.characters.length),
      composing: null,
    );
  }

  @override
  BaseCommand? createSaveCommand() {
    if (lastSentValue == textController.value.text) {
      return null;
    }

    return SetValueCommand(
      componentName: model.name,
      value: textController.value.text,
      reason: "Editing has ended on ${model.id}",
      afterProcessing: () => lastSentValue = textController.value.text,
    );
  }
}
