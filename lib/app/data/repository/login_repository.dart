import '../provider/login_api.dart';

class LoginRepository {
  final LoginApi apiLogin;
  LoginRepository({required this.apiLogin});

  login(usuario, senha, perfil) {
    return apiLogin.login(usuario, senha, perfil);
  }

  logout() {
    return apiLogin.logout();
  }
}
