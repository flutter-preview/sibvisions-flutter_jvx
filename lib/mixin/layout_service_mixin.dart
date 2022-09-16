import '../src/service/layout/i_layout_service.dart';
import '../src/service/service.dart';

export '../src/service/layout/i_layout_service.dart';
export '../src/service/layout/impl/layout_service.dart';

///
///  Provides an [ILayoutService] instance from get.it service
///
mixin LayoutServiceGetterMixin {
  ILayoutService getLayoutService() {
    return services<ILayoutService>();
  }
}
