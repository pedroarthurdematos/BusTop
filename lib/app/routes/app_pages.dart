import 'package:bustop/app/modulos/login/login_binding.dart';
import 'package:bustop/app/modulos/login/login_view.dart';
import 'package:bustop/app/modulos/mapa/mapa_binding.dart';
import 'package:bustop/app/modulos/mapa/mapa_view.dart';
import 'package:get/get.dart';

part './app_routes.dart';

abstract class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.MAPA,
      page: () => MapaView(),
      binding: MapaBinding(),
    ),
  ];
}
