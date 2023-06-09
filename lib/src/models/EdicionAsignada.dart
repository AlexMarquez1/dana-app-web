import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/CamposProyecto.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

EdicionAsignada edicionAsignadaFromJson(String str) =>
    EdicionAsignada.fromJson(json.decode(str));

String edicionAsignadaToJson(EdicionAsignada data) =>
    json.encode(data.toJson());

class EdicionAsignada {
  EdicionAsignada({
    this.idedicion,
    this.camposProyecto,
    this.usuario,
    this.inventario,
  });

  int idedicion;
  CamposProyecto camposProyecto;
  Usuario usuario;
  Inventario inventario;

  factory EdicionAsignada.fromJson(Map<String, dynamic> json) =>
      EdicionAsignada(
        idedicion: json["idedicion"],
        camposProyecto: CamposProyecto.fromJson(json['camposProyecto']),
        usuario: Usuario.fromJson(json["usuario"]),
        inventario: Inventario.fromJson(json['inventario']),
      );

  Map<String, dynamic> toJson() => {
        "idedicion": idedicion,
        "camposProyecto": camposProyecto.toJson(),
        "usuario": usuario.toJson(),
        "inventario": inventario.toJson(),
      };
}
