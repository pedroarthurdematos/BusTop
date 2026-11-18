import 'package:bustop/app/data/provider/mapa_api.dart';

class MapaRepository {
  final MapaApi apiMapa;
  MapaRepository({required this.apiMapa});

  buscaUsuario() {
    return apiMapa.buscaUsuario();
  }

  buscaRotas() {
    return apiMapa.buscaRotas();
  }

  buscaRotaEntrePontos(lngLat) {
    return apiMapa.buscaRotaEntrePontos(lngLat);
  }

  ligaRastreio(String canal) {
    return apiMapa.ligaRastreio(canal);
  }

  desligaRastreio() {
    return apiMapa.desligaRastreio();
  }
}
