class RotaModel {
  int? id;
  String? nome;
  List<Pontos>? pontos;

  RotaModel({this.id, this.nome, this.pontos});

  RotaModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    if (json['pontos'] != null) {
      pontos = <Pontos>[];
      json['pontos'].forEach((v) {
        pontos?.add(Pontos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    if (pontos != null) {
      data['pontos'] = pontos?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pontos {
  int? id;
  String? referencia;
  double? latitude;
  double? longitude;

  Pontos({this.id, this.referencia, this.latitude, this.longitude});

  Pontos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referencia = json['referencia'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['referencia'] = referencia;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
