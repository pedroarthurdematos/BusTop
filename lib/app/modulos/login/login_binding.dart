import 'package:bustop/app/data/provider/login_api.dart';
import 'package:bustop/app/data/repository/login_repository.dart';
import 'package:bustop/app/modulos/login/login_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        repository: LoginRepository(
          apiLogin: LoginApi(
            httpClient: Dio(),
          ),
        ),
      ),
    );
  }
}
