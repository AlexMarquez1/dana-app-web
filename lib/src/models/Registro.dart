import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Proyecto.dart';

Registro registroFromJson(String str) => Registro.fromJson(json.decode(str));

String registroToJson(Registro data) => json.encode(data.toJson());

class Registro {
  Registro({
    this.idRegistro,
    this.folio,
    this.fechaCreacion,
    this.proyecto,
    this.estatus,
  });

  int idRegistro;
  String folio;
  String fechaCreacion;
  Proyecto proyecto;
  String estatus;

  factory Registro.fromJson(Map<String, dynamic> json) => Registro(
        idRegistro: json["idRegistro"] ?? 0,
        folio: json["folio"] ?? '',
        estatus: json['estatus'] ?? '',
        fechaCreacion: json["fechaCreacion"] ?? '',
        proyecto: Proyecto.fromJson(json["proyecto"] ?? Proyecto()),
      );

  Map<String, dynamic> toJson() => {
        "idRegistro": idRegistro,
        "folio": folio,
        "fechaCreacion": fechaCreacion,
        "proyecto": proyecto.toJson(),
      };
}
