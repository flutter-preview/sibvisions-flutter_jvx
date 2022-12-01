import '../../../components/panel/group/fl_group_panel_wrapper.dart';
import '../../../service/api/shared/api_object_property.dart';
import '../../layout/alignments.dart';
import '../label/fl_label_model.dart';
import 'fl_panel_model.dart';

class FlGroupPanelModel extends FlPanelModel implements FlLabelModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// The text shown in the [FlGroupPanelWrapper]
  @override
  String text = "";

  bool get isFlatStyle => styles.contains(FlGroupPanelWrapper.FLAT_STYLE);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Initializes the [FlGroupPanelModel]
  FlGroupPanelModel() : super() {
    horizontalAlignment = HorizontalAlignment.LEFT;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlGroupPanelModel get defaultModel => FlGroupPanelModel();

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    text = getPropertyValue(
      pJson: pJson,
      pKey: ApiObjectProperty.text,
      pDefault: defaultModel.text,
      pCurrent: text,
    );
  }
}
