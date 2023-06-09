// ignore_for_file: file_names

import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Proyecto.dart';

Inventario inventarioFromJson(String str) =>
    Inventario.fromJson(json.decode(str));

String inventarioToJson(Inventario data) => json.encode(data.toJson());

class Inventario {
  Inventario({
    this.idinventario,
    this.fechacreacion,
    this.folio,
    this.estatus,
    this.proyecto,
  });

  int idinventario;
  String fechacreacion;
  String folio;
  String estatus;
  Proyecto proyecto;

  factory Inventario.fromJson(Map<String, dynamic> json) => Inventario(
        idinventario: json["idinventario"] ?? 0,
        fechacreacion: json["fechacreacion"] ?? '',
        folio: json["folio"] ?? '',
        estatus: json["estatus"] ?? '',
        proyecto: Proyecto.fromJson(json["proyecto"]),
      );

  Map<String, dynamic> toJson() => {
        "idinventario": idinventario ?? 0,
        "fechacreacion": fechacreacion ?? '',
        "folio": folio ?? '',
        "estatus": estatus ?? '',
        "proyecto": proyecto.toJson(),
      };
}
