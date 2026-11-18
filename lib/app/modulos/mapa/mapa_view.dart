import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'mapa_controller.dart';

class MapaView extends GetView<MapaController> {
  final TextEditingController _mensagem = TextEditingController();
  MapaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => controller.idRotaSelecionada < 0
              ? const Text("Mapa")
              : Text("Mapa - Rota ${controller.idRotaSelecionada + 1}"),
        ),
        actions: [
          Obx(
            () => Visibility(
              visible: controller.idRotaSelecionada >= 0,
              child: IconButton(
                icon: Icon(
                  Icons.mail,
                  color: (controller.usuario.mensagens != null &&
                              controller.usuario.mensagens.isNotEmpty) ||
                          (controller.usuarioMotorista.mensagens != null &&
                              controller.usuarioMotorista.mensagens.isNotEmpty)
                      ? Colors.red
                      : Colors.green,
                ),
                iconSize: 30,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Visibility(
                                visible: controller.usuario.isMotorista,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Escreva o Alerta:"),
                                  controller: _mensagem,
                                ),
                              ),
                              Visibility(
                                visible: controller.usuario.isMotorista,
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.enviaMensagem(_mensagem.text);
                                    _mensagem.clear();
                                    Get.back();
                                  },
                                  child: const Text("Alertar!"),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Expanded(
                                      flex: 0,
                                      child: Text(
                                        'Alertas Enviados:',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Visibility(
                                      visible: controller.usuario.isMotorista,
                                      child: Expanded(
                                        flex: 5,
                                        child: controller
                                                    .usuario.mensagens.length <
                                                1
                                            ? const Text(
                                                "Nenhum alerta enviado!")
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                itemCount: controller
                                                    .usuario.mensagens.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Center(
                                                      child: Text(
                                                        "${controller.usuario.mensagens[index].mensagem}\n${controller.usuario.mensagens[index].timestamp}",
                                                        style: const TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    tileColor: controller
                                                            .usuario
                                                            .mensagens[index]
                                                            .status
                                                        ? Colors.redAccent
                                                        : Colors.greenAccent,
                                                    trailing: IconButton(
                                                      icon: controller
                                                              .usuario
                                                              .mensagens[index]
                                                              .status
                                                          ? const Icon(
                                                              Icons.thumb_down,
                                                              color:
                                                                  Colors.white)
                                                          : const Icon(
                                                              Icons.thumb_up,
                                                              color:
                                                                  Colors.white),
                                                      onPressed: () {
                                                        if (controller.usuario
                                                            .isMotorista) {
                                                          controller.alteraStatusMensagem(
                                                              controller.usuario
                                                                      .mensagens[
                                                                  index]);
                                                          Get.back();
                                                        }
                                                      },
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const Divider(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                      ),
                                    ),
                                    !controller.usuario.isMotorista
                                        ? Expanded(
                                            flex: 5,
                                            child: controller.usuarioMotorista
                                                            .mensagens !=
                                                        null &&
                                                    controller.usuarioMotorista
                                                        .mensagens.isNotEmpty
                                                ? ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount: controller
                                                        .usuarioMotorista
                                                        .mensagens
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ListTile(
                                                        title: Center(
                                                          child: Text(
                                                            "${controller.usuarioMotorista.mensagens[index].mensagem}\n${controller.usuarioMotorista.mensagens[index].timestamp}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          ),
                                                        ),
                                                        tileColor: controller
                                                                .usuarioMotorista
                                                                .mensagens[
                                                                    index]
                                                                .status
                                                            ? Colors.redAccent
                                                            : Colors
                                                                .greenAccent,
                                                        trailing: IconButton(
                                                          icon: controller
                                                                  .usuarioMotorista
                                                                  .mensagens[
                                                                      index]
                                                                  .status
                                                              ? const Icon(
                                                                  Icons
                                                                      .thumb_down,
                                                                  color: Colors
                                                                      .white)
                                                              : const Icon(
                                                                  Icons
                                                                      .thumb_up,
                                                                  color: Colors
                                                                      .white),
                                                          onPressed: () {},
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const Divider(
                                                      color: Colors.blue,
                                                    ),
                                                  )
                                                : const Text(
                                                    "Nenhum alerta enviado!"),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController.value,
            options: const MapOptions(
              initialCenter: LatLng(-16.0665, -57.6845),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              Obx(
                () => PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.rotaEntrePontos.value,
                      color: Colors.blue,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              ),
              Obx(
                () => MarkerLayer(markers: controller.marcadores.value),
              ),
              Obx(
                () => MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(controller.usuario.latitude,
                          controller.usuario.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {},
                        child: Icon(
                          controller.usuario.isMotorista
                              ? Icons.bus_alert_sharp
                              : Icons.person,
                          color: Colors.black87,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => !controller.usuario.isMotorista
                    ? MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(controller.usuarioMotorista.latitude,
                                controller.usuarioMotorista.longitude),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.bus_alert_sharp,
                                color: Colors.black87,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Visibility(
          visible: controller.idRotaSelecionada >= 0,
          child: BottomAppBar(
            // só mostra se rota estiver escolhida
            child: Column(
              children: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.usuario.isTransmitindo ||
                              controller.usuarioMotorista.isTransmitindo
                          ? Colors.red
                          : Colors.lightBlue,
                    ),
                    onPressed: () {
                      // se for ligado o rastreio, esconde o botão de rota

                      controller.usuario.isTransmitindo ||
                              controller.usuarioMotorista.isTransmitindo
                          ? controller.desligaRastreio()
                          : controller.ligaRastreio();
                    },
                    child: controller.usuario.isTransmitindo ||
                            controller.usuarioMotorista.isTransmitindo
                        ? Text(
                            'FINALIZAR RASTREIO ROTA ${controller.idRotaSelecionada + 1}')
                        : Text(
                            'INICIAR RASTREIO ROTA ${controller.idRotaSelecionada + 1}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => Visibility(
          visible: controller.usuario.isTransmitindo ||
                  controller.usuarioMotorista.isTransmitindo
              ? false
              : true,
          child: FloatingActionButton(
            tooltip: 'ROTAS',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return Container(
                    child: Column(
                      children: [
                        const Expanded(
                          flex: 0,
                          child: Text(
                            'ROTAS',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: controller.rotas.length < 1
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: controller.rotas.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Center(
                                        child: Text(
                                          "${controller.rotas[index].nome} - ${controller.rotas[index].id.toString()}",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      tileColor:
                                          controller.idRotaSelecionada == index
                                              ? Colors.redAccent
                                              : Colors.orangeAccent,
                                      leading: const Icon(
                                        Icons.bus_alert,
                                        size: 35,
                                      ),
                                      trailing: const Icon(
                                        Icons.bus_alert,
                                        size: 35,
                                      ),
                                      onTap: () {
                                        controller.idRotaSelecionada = index;
                                        controller.buscaPontosRota(
                                            controller.rotas[index]);
                                        Get.back();
                                      },
                                    );
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Colors.blue,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(
              Icons.route,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
