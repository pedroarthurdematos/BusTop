import 'package:bustop/app/data/provider/mapa_api.dart';
import 'package:bustop/app/data/repository/mapa_repository.dart';
import 'package:bustop/app/modulos/mapa/mapa_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class MapaBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapaController>(
      () => MapaController(
        repository: MapaRepository(
          apiMapa: MapaApi(
            httpClient: Dio(),
          ),
        ),
      ),
    );
  }
}
