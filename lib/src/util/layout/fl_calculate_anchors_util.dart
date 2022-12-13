/* Copyright 2022 SIB Visions GmbH
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

import 'dart:collection';

import '../../model/layout/form_layout/form_layout_anchor.dart';

class FLCalculateAnchorsUtil {
  /// Gets all non-calculated auto size anchors between start and end anchor
  static List<FormLayoutAnchor> getAutoSizeAnchorsBetween(
      {required FormLayoutAnchor pStartAnchor,
      required FormLayoutAnchor pEndAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors = [];
    FormLayoutAnchor? startAnchor = pStartAnchor;
    while (startAnchor != null && startAnchor != pEndAnchor) {
      if (startAnchor.autoSize && !startAnchor.autoSizeCalculated) {
        autoSizeAnchors.add(startAnchor);
      }
      startAnchor = startAnchor.relatedAnchor;
    }

    // If the anchors are not dependent on each other return an empty array!
    if (startAnchor == null) {
      return [];
    }
    return autoSizeAnchors;
  }

  /// Init component auto size position of anchor.
  static void initAutoSizeRelative(
      {required FormLayoutAnchor pStartAnchor,
      required FormLayoutAnchor pEndAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pStartAnchor, pEndAnchor: pEndAnchor, pAnchors: pAnchors);
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      anchor.relative = false;
    }
  }

  /// Calculates the preferred size of component auto size anchors.
  static void calculateAutoSize(
      {required FormLayoutAnchor pLeftTopAnchor,
      required FormLayoutAnchor pRightBottomAnchor,
      required double pPreferredSize,
      required double pAutoSizeCount,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pLeftTopAnchor, pEndAnchor: pRightBottomAnchor, pAnchors: pAnchors);

    if (autoSizeAnchors.length == pAutoSizeCount) {
      double fixedSize = pRightBottomAnchor.getAbsolutePosition() - pLeftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize += anchor.position;
      }
      double diffSize = (pPreferredSize - fixedSize + pAutoSizeCount - 1) / pAutoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > -anchor.position) {
          anchor.position = -diffSize;
        }
        anchor.firstCalculation = false;
      }
    }

    autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: pRightBottomAnchor, pEndAnchor: pLeftTopAnchor, pAnchors: pAnchors);
    if (autoSizeAnchors.length == pAutoSizeCount) {
      double fixedSize = pRightBottomAnchor.getAbsolutePosition() - pLeftTopAnchor.getAbsolutePosition();
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        fixedSize -= anchor.position;
      }
      double diffSize = (pPreferredSize - fixedSize + pAutoSizeCount - 1) / pAutoSizeCount;
      for (FormLayoutAnchor anchor in autoSizeAnchors) {
        if (diffSize > anchor.position) {
          anchor.position = diffSize;
        }
        anchor.firstCalculation = false;
      }
    }
  }

  /// Marks all touched AutoSize anchors as calculated
  static double finishAutoSizeCalculation(
      {required FormLayoutAnchor leftTopAnchor,
      required FormLayoutAnchor rightBottomAnchor,
      required HashMap<String, FormLayoutAnchor> pAnchors}) {
    List<FormLayoutAnchor> autoSizeAnchors =
        getAutoSizeAnchorsBetween(pStartAnchor: leftTopAnchor, pEndAnchor: rightBottomAnchor, pAnchors: pAnchors);
    double counter = 0;
    for (FormLayoutAnchor anchor in autoSizeAnchors) {
      if (!anchor.firstCalculation) {
        anchor.autoSizeCalculated = true;
        counter++;
      }
    }
    return autoSizeAnchors.length - counter;
  }

  /// Clears auto size position of anchors
  static void clearAutoSize({required HashMap<String, FormLayoutAnchor> pAnchors}) {
    pAnchors.forEach((anchorName, anchor) {
      anchor.relative = anchor.autoSize;
      anchor.autoSizeCalculated = false;
      anchor.firstCalculation = true;
      /*
      FormLayout Änderungen von Martin bzgl Gaps der Anchor.
      anchor.used = false;
      */
      if (anchor.autoSize) {
        anchor.position = 0;
      }
    });
  }

  static void initAnchors(HashMap<String, FormLayoutAnchor> pAnchors) {
    // Init autoSize Anchor position
    pAnchors.forEach((anchorName, anchor) {
      // Check if two autoSize anchors are side by side
      if (anchor.relatedAnchor != null && anchor.relatedAnchor!.autoSize) {
        FormLayoutAnchor relatedAutoSizeAnchor = anchor.relatedAnchor!;
        if (relatedAutoSizeAnchor.relatedAnchor != null && !relatedAutoSizeAnchor.relatedAnchor!.autoSize) {
          relatedAutoSizeAnchor.position = -anchor.position;
        }
      }
    });
  }
}
