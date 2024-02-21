// ignore_for_file: file_names

import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Inventario.dart';

Estatus estatusFromJson(String str) => Estatus.fromJson(json.decode(str));

String estatusToJson(Estatus data) => json.encode(data.toJson());

class Estatus {
  Estatus({
    this.estatus,
    this.agrupacion,
    this.motivo,
    this.descripcion,
    this.inventario,
  });

  String? estatus;
  String? agrupacion;
  String? motivo;
  String? descripcion;
  Inventario? inventario;

  factory Estatus.fromJson(Map<String, dynamic> json) => Estatus(
        estatus: json["estatus"],
        agrupacion: json["agrupacion"],
        motivo: json["motivo"],
        descripcion: json["descripcion"],
        inventario: Inventario.fromJson(json["inventario"]),
      );

  Map<String, dynamic> toJson() => {
        "estatus": estatus,
        "agrupacion": agrupacion,
        "motivo": motivo,
        "inventario": inventario!.toJson(),
        "descripcion": descripcion,
      };
}
