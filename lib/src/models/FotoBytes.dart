// ignore_for_file: file_names
import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

class FotoBytes {
  FotoBytes({
    this.idfoto,
    this.nombrefoto,
    this.bytes,
    // this.usuario,
    this.inventario,
    this.idCampoProyecto,
    this.coordenadas,
  });

  int? idfoto;
  String? nombrefoto;
  List<int>? bytes;
  // Usuario usuario;
  Inventario? inventario;
  int? idCampoProyecto;
  String? coordenadas;

  factory FotoBytes.fromJson(Map<String, dynamic> json) => FotoBytes(
        idfoto: json["idEvidencia"],
        nombrefoto: json["nombreEvidencia"],
        bytes: List<int>.from(json["evidencia"].map((x) => x)),
        // usuario: Usuario.fromJson(json["usuario"]),
        inventario: Inventario.fromJson(json["inventario"]),
        idCampoProyecto: json["camposProyecto"]['idcamposproyecto'],
        coordenadas: json["coordenadas"] == null ? '' : json["coordenadas"],
      );

  Map<String, dynamic> toJson() => {
        "idEvidencia": idfoto,
        "nombreEvidencia": nombrefoto,
        "evidencia": bytes,
        // "usuario": usuario.toJson(),
        "inventario": inventario!.toJson(),
        "camposProyecto": {'idcamposproyecto': idCampoProyecto},
        "coordenadas": coordenadas,
      };
}
