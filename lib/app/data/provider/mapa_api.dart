import 'package:bustop/app/data/model/rota_model.dart';
import 'package:bustop/app/data/model/usuario_model.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const apiRotasUrl = 'http://bustop.ddns.net/api/rotas/';
const apiRotasEntrePontosUrl =
    'https://api.openrouteservice.org/v2/directions/driving-car/geojson';
const apiRotasEntrePontosToken =
    '5b3ce3597851110001cf6248d5bbdb77533b46e5831d98fe8ae08204';
const webSocketUrl = 'ws://bustop.ddns.net/ws/chat/';

class MapaApi {
  final Dio httpClient;
  late WebSocketChannel channel;
  var webSocketConectado = false;
  MapaApi({required this.httpClient});

  WebSocketChannel ligaRastreio(String canal) {
    if (!webSocketConectado) {
      var uri = '$webSocketUrl$canal/';
      channel = WebSocketChannel.connect(Uri.parse(uri));
      webSocketConectado = true;
    }
    return channel;
  }

  desligaRastreio() {
    webSocketConectado = false;
    channel.sink.close();
  }

  Future<Map<String, dynamic>> buscaRotaEntrePontos(lngLat) async {
    try {
      var response = await httpClient.post(
        apiRotasEntrePontosUrl,
        data: {"coordinates": lngLat},
        options: Options(
          headers: {
            'Accept':
                'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
            'Authorization': apiRotasEntrePontosToken,
            'Content-Type': 'application/json; charset=utf-8'
          },
        ),
      );
      if (response.statusCode == 200) {
        Iterable jsonResponse =
            response.data['features'][0]['geometry']['coordinates'];
        List<LatLng> listaPontos = jsonResponse
            .map((lngLat) => LatLng(lngLat[1].toDouble(), lngLat[0].toDouble()))
            .toList();
        return {'code': response.statusCode, 'data': listaPontos};
      } else {
        return {'code': response.statusCode, 'data': response.data};
      }
    } on DioException catch (e) {
      return {'code': e.response?.statusCode, 'data': e.response?.data};
    }
  }

  Future<Map<String, dynamic>> buscaRotas() async {
    try {
      var response = await httpClient.get(apiRotasUrl);
      if (response.statusCode == 200) {
        Iterable jsonResponse = response.data;
        List<RotaModel> listaModelo =
            jsonResponse.map((model) => RotaModel.fromJson(model)).toList();
        return {'code': response.statusCode, 'data': listaModelo};
      } else {
        return {'code': response.statusCode, 'data': response.data};
      }
    } on DioException catch (e) {
      return {'code': e.response?.statusCode, 'data': e.response?.data};
    }
  }

  UsuarioModel buscaUsuario() {
    UsuarioModel modelo = UsuarioModel.fromJson(consultaDados('USUARIO'));
    return modelo;
  }

  consultaDados(chave) {
    final box = GetStorage();
    return box.read(chave);
  }
}
