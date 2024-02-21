import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';

Localidad localidadFromJson(String str) => Localidad.fromJson(json.decode(str));

String localidadToJson(Localidad data) => json.encode(data.toJson());

class Localidad {
  int? idlocalidad;
  String? nombre;
  String? ubicacion;
  String? encargado;
  String? telefonocontacto;
  String? correocontacto;
  ClienteAplicacion? clienteAplicacion;

  Localidad({
    this.idlocalidad,
    this.nombre,
    this.ubicacion,
    this.encargado,
    this.telefonocontacto,
    this.correocontacto,
    this.clienteAplicacion,
  });

  factory Localidad.fromJson(Map<String, dynamic> json) => Localidad(
        idlocalidad: json["idlocalidad"] ?? 0,
        nombre: json["nombre"] ?? '',
        ubicacion: json["ubicacion"] ?? '',
        encargado: json["encargado"] ?? '',
        telefonocontacto: json["telefonocontacto"] ?? '',
        correocontacto: json["correocontacto"] ?? '',
        clienteAplicacion: json["clienteAplicacion"] != null
            ? ClienteAplicacion.fromJson(json["clienteAplicacion"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "idlocalidad": idlocalidad,
        "nombre": nombre,
        "ubicacion": ubicacion,
        "encargado": encargado,
        "telefonocontacto": telefonocontacto,
        "correocontacto": correocontacto,
        "clienteAplicacion": clienteAplicacion!.toJson(),
      };
}
