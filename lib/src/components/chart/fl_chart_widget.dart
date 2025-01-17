/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/widgets.dart';

import '../../model/component/fl_component_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlChartWidget<T extends FlChartModel> extends FlStatelessWidget<T> {
  final List<Series<dynamic, num>> series;

  final Function(int? index)? onIndexSelected;

  const FlChartWidget({
    super.key,
    required super.model,
    required this.series,
    this.onIndexSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Container();
    }

    return LineChart(
      series,
      selectionModels: [
        SelectionModelConfig(
          type: SelectionModelType.info,
          changedListener: (SelectionModel model) {
            onIndexSelected?.call(model.hasDatumSelection ? model.selectedDatum.first.index : null);
          },
        ),
      ],
      animate: false,
      layoutConfig: LayoutConfig(
        topMarginSpec: MarginSpec.fromPercent(minPercent: 2, maxPercent: 100),
        bottomMarginSpec: MarginSpec.fromPercent(minPercent: 5, maxPercent: 100),
        leftMarginSpec: MarginSpec.fromPercent(minPercent: 5, maxPercent: 100),
        rightMarginSpec: MarginSpec.fromPercent(minPercent: 2, maxPercent: 100),
      ),
    );
  }
}
