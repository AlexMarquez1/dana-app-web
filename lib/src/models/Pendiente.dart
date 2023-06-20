// ignore_for_file: file_names
import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Inventario.dart';

Pendiente pendienteFromJson(String str) => Pendiente.fromJson(json.decode(str));

String pendienteToJson(Pendiente data) => json.encode(data.toJson());

class Pendiente {
  Pendiente({
    this.idpendiente,
    this.inventario,
    this.motivo,
    this.descripcion,
    this.agrupacion,
  });

  int idpendiente;
  Inventario inventario;
  String motivo;
  String descripcion;
  String agrupacion;

  factory Pendiente.fromJson(Map<String, dynamic> json) => Pendiente(
        idpendiente: json["idpendiente"],
        inventario: Inventario.fromJson(json["inventario"]),
        motivo: json["motivo"],
        descripcion: json["descripcion"],
        agrupacion: json["agrupacion"],
      );

  Map<String, dynamic> toJson() => {
        "idpendiente": idpendiente,
        "inventario": inventario.toJson(),
        "motivo": motivo,
        "descripcion": descripcion,
        "agrupacion": agrupacion,
      };
}
