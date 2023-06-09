// ignore_for_file: file_names

import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Registro.dart';

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

  String estatus;
  String agrupacion;
  String motivo;
  String descripcion;
  Registro inventario;

  factory Estatus.fromJson(Map<String, dynamic> json) => Estatus(
        estatus: json["estatus"],
        agrupacion: json["agrupacion"],
        motivo: json["motivo"],
        descripcion: json["descripcion"],
        inventario: Registro.fromJson(json["inventario"]),
      );

  Map<String, dynamic> toJson() => {
        "estatus": estatus,
        "agrupacion": agrupacion,
        "motivo": motivo,
        "inventario": {
          'idinventario': inventario.idRegistro,
          // 'fechacreacion': inventario.fechaCreacion,
          'folio': inventario.folio,
          'estatus': inventario.estatus,
          'proyecto': inventario.proyecto.toJson(),
        },
        "descripcion": descripcion,
      };
}
