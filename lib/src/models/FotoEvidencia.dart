// ignore_for_file: file_names
import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

FotoEvidencia fotoEvidenciaFromJson(String str) =>
    FotoEvidencia.fromJson(json.decode(str));

String fotoEvidenciaToJson(FotoEvidencia data) => json.encode(data.toJson());

class FotoEvidencia {
  FotoEvidencia({
    this.campoNombre,
    this.idfoto,
    this.nombrefoto,
    this.url,
    this.usuario,
    this.inventario,
    this.idCampoProyecto,
    this.coordenadas,
  });

  int? idfoto;
  String? nombrefoto;
  String? url;
  Usuario? usuario;
  Inventario? inventario;
  int? idCampoProyecto;
  String? coordenadas;
  String? campoNombre;

  factory FotoEvidencia.fromJson(Map<String, dynamic> json) => FotoEvidencia(
        idfoto: json["idfoto"] ?? 0,
        nombrefoto: json["nombrefoto"] ?? '',
        url: json["url"] ?? '',
        usuario: Usuario.fromJson(json["usuario"]),
        inventario: Inventario.fromJson(json["inventario"]),
        idCampoProyecto: json["campoProyecto"]['idcamposproyecto'] ?? 0,
        coordenadas: json["coordenadas"] ?? '',
        campoNombre: json["campoProyecto"]['campo'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idfoto": idfoto,
        "nombrefoto": nombrefoto,
        "url": url,
        "usuario": usuario?.toJson(),
        "inventario": inventario?.toJson(),
        "campoProyecto": {'idcamposproyecto': idCampoProyecto},
        "coordenadas": coordenadas,
      };
}
