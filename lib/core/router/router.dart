import 'package:ai_map_explainer/core/router/route_handle.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:fluro/fluro.dart';

class Routes {
  Routes();

  static final router = FluroRouter();

  static void configureRoutes() {
    _setRouter(RoutePath.home, handler: homeScreenHandler);

    _setRouter(RoutePath.detail, handler: detailScreenHandler);

    _setRouter(RoutePath.map, handler: mapScreenHandler);
  }

  static void _setRouter(
      String path, {
        required Handler handler,
        TransitionType? transitionType,
      }) {
    transitionType ??= TransitionType.cupertino;
    router.define(path, handler: handler, transitionType: transitionType);
  }
}
