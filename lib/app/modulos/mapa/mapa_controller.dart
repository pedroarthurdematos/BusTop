import 'dart:async';
import 'dart:convert';

import 'package:bustop/app/data/model/rota_model.dart';
import 'package:bustop/app/data/model/usuario_model.dart';
import 'package:bustop/app/data/repository/mapa_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapaController extends GetxController {
  final MapaRepository repository;
  MapaController({required this.repository});

  final _usuario = UsuarioModel().obs;
  get usuario => _usuario.value;
  set usuario(value) => _usuario.value = value;

  final _usuarioMotorista = UsuarioModel().obs;
  get usuarioMotorista => _usuarioMotorista.value;
  set usuarioMotorista(value) => _usuarioMotorista.value = value;

  final _rotas = <RotaModel>[].obs;
  get rotas => _rotas.value;
  set rotas(value) => _rotas.value = value;

  final _idRotaSelecionada = 0.obs;
  get idRotaSelecionada => _idRotaSelecionada.value;
  set idRotaSelecionada(value) => _idRotaSelecionada.value = value;

  final marcadores = <Marker>[].obs;
  final rotaEntrePontos = <LatLng>[].obs;
  final mapController = MapController().obs;
  late StreamSubscription<Position> streamSubscription;
  late StreamSubscription streamMensagens;

  @override
  void onInit() async {
    super.onInit();

    // busca usuario logado
    usuario = repository.buscaUsuario();
    usuario.latitude = 0.0;
    usuario.longitude = 0.0;
    _usuario.refresh();

    // if (!usuario.isMotorista) {
    usuarioMotorista.latitude = 0.0;
    usuarioMotorista.longitude = 0.0;
    usuarioMotorista.isTransmitindo = false;
    _usuarioMotorista.refresh();
    // }

    // AQUI, buscar rotas e pontos da API... quando recuperado, mostrar modal com opções de rotas.
    buscaRotas();
    idRotaSelecionada = -1;

    // Desenhar na tela a rota escolhida e seus pontos.
    // Se motorista, acrescentar botão de início e fim do rastreio.
    // Se MOTORISTA, desenhar sua localização na tela e enviá-la na sala via websocket.
    // Se ALUNO, receber a localização do motorista via websocket e desenhá-la na tela.

    lePosicao();
  }

  enviaMensagem(String texto) {
    MensagemModel mensagem = MensagemModel(
      mensagem: texto,
      timestamp: DateTime.now(),
      status: true,
    );
    usuario.mensagens.add(mensagem);
    _usuario.refresh();
  }

  alteraStatusMensagem(MensagemModel mensagem) {
    mensagem.status ? mensagem.status = false : mensagem.status = true;
    _usuario.refresh();
  }

  ligaRastreio() {
    usuario.rotaId = idRotaSelecionada + 1;
    final rastreio = repository.ligaRastreio("rota${usuario.rotaId}");
    streamSubscription =
        Geolocator.getPositionStream().listen((Position posicao) {
      usuario.latitude = posicao.latitude;
      usuario.longitude = posicao.longitude;
      if (usuario.isMotorista) {
        usuario.isTransmitindo = true;
        rastreio.sink.add(usuario.toJsonMessage().toString());
        mapController.value
            .move(LatLng(usuario.latitude, usuario.longitude), 18);
      }
      _usuario.refresh();
    });
    if (!usuario.isMotorista) {
      usuarioMotorista.isTransmitindo = true;
      _usuarioMotorista.refresh();
      rastreio.stream.listen((mensagem) {
        var dadosMensagem = jsonDecode(jsonDecode(mensagem)['message']);
        usuarioMotorista = UsuarioModel.fromJson(dadosMensagem);
        usuarioMotorista.isTransmitindo = true;
        _usuarioMotorista.refresh();
      });
    }
  }

  desligaRastreio() {
    final rastreio = repository.ligaRastreio("rota${usuario.rotaId}");
    streamSubscription.pause();
    usuario.rotaId = null;
    usuario.latitude = 0.0;
    usuario.longitude = 0.0;
    usuario.isTransmitindo = false;
    _usuario.refresh();
    if (usuario.isMotorista) {
      rastreio.sink.add(usuario.toJsonMessage().toString());
    } else {
      // streamMensagens.pause();
      usuarioMotorista.latitude = 0.0;
      usuarioMotorista.longitude = 0.0;
      usuarioMotorista.isTransmitindo = false;
    }
    repository.desligaRastreio();
    mapController.value.move(const LatLng(-16.0665, -57.6845), 13);
  }

  buscaRotaEntrePontos(List lngLat) {
    repository.buscaRotaEntrePontos(lngLat).then((data) {
      if (data['code'] == 200) {
        rotaEntrePontos.value = data['data'];
      } else {
        Get.snackbar(
          'Erro ${data['code'].toString()}',
          data['data'].toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  addMarcadores(LatLng posicao, String titulo) {
    marcadores.add(
      Marker(
        point: posicao,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 25,
              )
            ],
          ),
        ),
      ),
    );
  }

  // criar marcadores com dados dos pontos
  buscaPontosRota(RotaModel rota) {
    List lngLat = [];
    marcadores.clear();
    rota.pontos?.forEach(
      (ponto) {
        // Cria lista de marcadores.
        addMarcadores(
            LatLng(ponto.latitude!, ponto.longitude!), ponto.referencia!);
        // Cria lista de pontos para buscar rota, padrão openrouteservice.
        lngLat.add([ponto.longitude!, ponto.latitude!]);
      },
    );
    rotaEntrePontos.clear();
    buscaRotaEntrePontos(lngLat);
  }

  buscaRotas() {
    repository.buscaRotas().then((data) {
      if (data['code'] == 200) {
        rotas = data['data'];
      } else {
        Get.snackbar(
          'Erro ${data['code'].toString()}',
          data['data'].toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  Future lePosicao() async {
    bool servicoIniniado;
    LocationPermission permissao;
    servicoIniniado = await Geolocator.isLocationServiceEnabled();
    if (!servicoIniniado) {
      Get.snackbar(
        'GPS STATUS',
        'DESABILITADO! Habilite o GPS',
        snackPosition: SnackPosition.TOP,
      );
      // return Future.error("Serviço de localização está desabilitado!");
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error("Permissão de localização Negada!");
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      return Future.error("Permissão de localização permanentemente Negada!");
    }
  }
}
