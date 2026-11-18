import 'package:get/get.dart';

import '../../data/repository/login_repository.dart';

class LoginController extends GetxController {
  final LoginRepository repository;
  LoginController({required this.repository});

  final _isMotorista = false.obs;
  get isMotorista => _isMotorista.value;
  set isMotorista(value) => _isMotorista.value = value;

  final isLoading = false.obs;

  /// Autentica, armazena token oauth e recupera informações do uruário.
  login(usuario, senha) async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    repository.login(usuario, senha, isMotorista).then((data) {
      if (data['code'] == 200) {
        Get.toNamed('/mapa');
      } else {
        Get.snackbar(
          'Erro ${data['code'].toString()}',
          data['data'].toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed('/mapa');
      }
    });
    isLoading.value = false;
  }

  /// Logout do usuário e apaga token oauth.
  logout() {}
}
