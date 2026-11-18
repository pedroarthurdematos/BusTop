import 'package:bustop/app/data/model/usuario_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

const authUrl = 'https://suap.ifmt.edu.br/api/v2/autenticacao/token/';
const authDadosUrl =
    'https://suap.ifmt.edu.br/api/v2/minhas-informacoes/meus-dados/';

class LoginApi {
  final Dio httpClient;
  LoginApi({required this.httpClient});

  Future<Map<String, dynamic>> autenticacaoOAuth2Suap(usuario, senha) async {
    try {
      var response = await httpClient
          .post(authUrl, data: {'username': usuario, 'password': senha});
      return {'code': response.statusCode, 'data': response.data};
    } on DioException catch (e) {
      return {'code': e.response?.statusCode, 'data': e.response?.data};
    }
  }

  Future<Map<String, dynamic>> requisicaoOAuth2Suap(
      requisicao, token, perfil) async {
    try {
      var response = await httpClient.get(
        requisicao,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        UsuarioModel modelo = UsuarioModel.fromJson(response.data);
        modelo.isMotorista = perfil;
        modelo.isTransmitindo = false;
        return {'code': response.statusCode, 'data': modelo};
      } else {
        return {'code': response.statusCode, 'data': response.data};
      }
    } on DioException catch (e) {
      return {'code': e.response?.statusCode, 'data': e.response?.data};
    }
  }

  Future<bool> salvaDados(chave, valor) async {
    final box = GetStorage();
    await box.write(chave, valor);
    return true;
  }

  consultaDados(chave) {
    final box = GetStorage();
    return box.read(chave);
  }

  Future<void> removeDados(chave) async {
    final box = GetStorage();
    await box.remove(chave);
  }

  Future<Map<String, dynamic>> login(usuario, senha, perfil) async {
    try {
      var mapa = await autenticacaoOAuth2Suap(usuario, senha);
      if (mapa['code'] == 200) {
        var estado = await salvaDados('TOKEN', mapa['data']);
        if (estado) {
          var tokensOAuth = consultaDados('TOKEN');
          mapa = await requisicaoOAuth2Suap(
              authDadosUrl, tokensOAuth["access"], perfil);
        }
      }
      if (mapa['data'].runtimeType == UsuarioModel) {
        await salvaDados('USUARIO', mapa['data'].toJson());
      } else {
        // <<<<<<<<<< Corrigir problema de login da API SUAP >>>>>>>>>>>>>>>>
        UsuarioModel modelo = UsuarioModel();
        modelo.isMotorista = perfil;
        modelo.isTransmitindo = false;
        await salvaDados('USUARIO', modelo.toJson());
      } // <<<<<<<<<<<<<<<<FIM Correção>>>>>>>>>>>>>>>>
      return mapa;
    } catch (e) {
      return {'code': 000, 'data': e.toString()};
    }
  }

  logout() {}
}
