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

class Margins {
  /// The top margin
  double marginTop;

  /// The left margin
  double marginLeft;

  /// The bottom margin
  double marginBottom;

  /// The right margin
  double marginRight;

  Margins({
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
    required this.marginTop,
  });

  Margins.fromList({required List<String> marginList, required double scaling})
      : marginTop = double.parse(marginList[0]) * scaling,
        marginLeft = double.parse(marginList[1]) * scaling,
        marginBottom = double.parse(marginList[2]) * scaling,
        marginRight = double.parse(marginList[3]) * scaling;
}
