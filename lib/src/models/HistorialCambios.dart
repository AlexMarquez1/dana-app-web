import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/models/CamposProyecto.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

HistorialCambios historialCambiosFromJson(String str) =>
    HistorialCambios.fromJson(json.decode(str));

String historialCambiosToJson(HistorialCambios data) =>
    json.encode(data.toJson());

class HistorialCambios {
  int? idhistorial;
  Inventario? inventario;
  Usuario? usuario;
  CamposProyecto? campo;
  String? valoranterior;
  String? valornuevo;
  String? fechacambio;
  String? horacambio;

  HistorialCambios({
    this.idhistorial,
    this.inventario,
    this.usuario,
    this.campo,
    this.valoranterior,
    this.valornuevo,
    this.fechacambio,
    this.horacambio,
  });

  factory HistorialCambios.fromJson(Map<String, dynamic> json) =>
      HistorialCambios(
        idhistorial: json["idhistorial"] ?? 0,
        inventario: Inventario.fromJson(json["inventario"]),
        usuario: Usuario.fromJson(json["usuario"]),
        campo: CamposProyecto.fromJson(json["campo"]),
        valoranterior: json["valoranterior"] ?? '',
        valornuevo: json["valornuevo"] ?? '',
        fechacambio: json["fechacambio"] ?? '',
        horacambio: json["horacambio"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idhistorial": idhistorial,
        "inventario": inventario!.toJson(),
        "usuario": usuario!.toJson(),
        "campo": campo!.toJson(),
        "valoranterior": valoranterior,
        "valornuevo": valornuevo,
        "fechacambio": fechacambio,
        "horacambio": horacambio,
      };
}
