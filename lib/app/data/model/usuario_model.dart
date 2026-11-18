import 'dart:convert';

class UsuarioModel {
  int? id;
  String? matricula;
  String? nomeUsual;
  String? email;
  String? fotoUrl;
  bool? isMotorista;
  int? rotaId;
  double? latitude;
  double? longitude;
  bool? isTransmitindo;
  List<MensagemModel>? mensagens;

  UsuarioModel(
      {this.id,
      this.matricula,
      this.nomeUsual,
      this.email,
      this.fotoUrl,
      this.isMotorista,
      this.rotaId,
      this.latitude,
      this.longitude,
      this.isTransmitindo,
      this.mensagens});

  UsuarioModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    matricula = json['matricula'];
    nomeUsual = json['nome_usual'];
    email = json['email'];
    fotoUrl = json['url_foto_75x100'];
    isMotorista = json['isMotorista'];
    rotaId = json['rotaId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isTransmitindo = json['isTransmitindo'];
    mensagens = <MensagemModel>[];
    if (json['mensagens'] != null) {
      json['mensagens'].forEach((v) {
        mensagens?.add(MensagemModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['matricula'] = matricula;
    data['nomeUsual'] = nomeUsual;
    data['email'] = email;
    data['fotoUrl'] = fotoUrl;
    data['isMotorista'] = isMotorista;
    data['rotaId'] = rotaId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['isTransmitindo'] = isTransmitindo;
    if (mensagens != null) {
      data['mensagens'] = mensagens?.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> toJsonMessage() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['"id"'] = jsonEncode(id);
    data['"matricula"'] = jsonEncode(matricula);
    data['"nomeUsual"'] = jsonEncode(nomeUsual);
    data['"email"'] = jsonEncode(email);
    data['"fotoUrl"'] = jsonEncode(fotoUrl);
    data['"isMotorista"'] = jsonEncode(isMotorista);
    data['"rotaId"'] = jsonEncode(rotaId);
    data['"latitude"'] = jsonEncode(latitude);
    data['"longitude"'] = jsonEncode(longitude);
    data['"isTransmitindo"'] = jsonEncode(isTransmitindo);
    if (mensagens != null) {
      data['"mensagens"'] = mensagens?.map((v) => v.toJsonMessage()).toList();
    }
    return data;
  }
}

class MensagemModel {
  late String mensagem;
  late DateTime timestamp;
  late bool status;

  MensagemModel(
      {required this.mensagem, required this.timestamp, required this.status});

  MensagemModel.fromJson(Map<String, dynamic> json) {
    mensagem = json['mensagem'];
    timestamp = DateTime.parse(json['timestamp']);
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mensagem'] = mensagem;
    data['timestamp'] = timestamp;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> toJsonMessage() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['"mensagem"'] = jsonEncode(mensagem);
    data['"timestamp"'] = jsonEncode(timestamp.toIso8601String());
    data['"status"'] = jsonEncode(status);
    return data;
  }
}
