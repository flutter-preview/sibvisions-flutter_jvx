import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../../util/image/image_loader.dart';
import '../../../util/jvx_colors.dart';
import '../../model/component/icon/fl_icon_model.dart';
import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlIconWidget<T extends FlIconModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final VoidCallback? onPress;

  final Widget? directImage;

  final bool imageInBinary;

  final Function(Size, bool)? imageStreamListener;

  final bool inTable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({
    super.key,
    required super.model,
    this.imageInBinary = false,
    this.imageStreamListener,
    this.directImage,
    this.onPress,
    this.inTable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? child = directImage ?? getImage();

    if (model.toolTipText != null) {
      child = Tooltip(message: model.toolTipText!, child: child);
    }

    if (onPress != null || directImage != null) {
      return GestureDetector(
        onTap: model.isEnabled ? onPress : null,
        // child: DecoratedBox(
        //   decoration: BoxDecoration(color: model.background),
        child: child,
        // ),
      );
    } else {
      return GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (context) {
            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: PhotoView(
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                initialScale: PhotoViewComputedScale.contained * 0.75,
                minScale: PhotoViewComputedScale.contained * 0.1,
                imageProvider: getImageProvider(),
              ),
            );
          },
        ),
        child: child,
      );
    }
  }

  BoxFit getBoxFit() {
    if (inTable) {
      return BoxFit.scaleDown;
    }

    if (model.preserveAspectRatio) {
      if ((model.horizontalAlignment == HorizontalAlignment.STRETCH) &&
          (model.verticalAlignment == VerticalAlignment.STRETCH)) {
        return BoxFit.contain;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
        return BoxFit.fitWidth;
      } else if (model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.fitHeight;
      }
    } else {
      if ((model.horizontalAlignment == HorizontalAlignment.STRETCH) &&
          (model.verticalAlignment == VerticalAlignment.STRETCH)) {
        return BoxFit.fill;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
        return BoxFit.fitWidth;
      } else if (model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.fitHeight;
      }
    }
    return BoxFit.none;
  }

  Widget? getImage() {
    return ImageLoader.loadImage(
      model.image,
      pWantedColor: model.isEnabled ? null : JVxColors.COMPONENT_DISABLED,
      pImageStreamListener: imageStreamListener,
      pImageInBinary: imageInBinary,
      pFit: getBoxFit(),
      pAlignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
    );
  }

  ImageProvider getImageProvider() {
    return ImageLoader.loadImageProvider(
      model.image,
      pImageStreamListener: imageStreamListener,
      pImageInBinary: imageInBinary,
    );
  }
}
