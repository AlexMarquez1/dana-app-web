import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';

Cliente clienteFromJson(String str) => Cliente.fromJson(json.decode(str));

String clienteToJson(Cliente data) => json.encode(data.toJson());

class Cliente {
  Cliente({
    this.idcliente,
    this.cliente,
    this.telefono,
    this.direccion,
    this.urllogo,
    this.estatus,
    this.clienteAplicacion,
  });

  int idcliente;
  String cliente;
  String telefono;
  String direccion;
  String urllogo;
  String estatus;
  ClienteAplicacion clienteAplicacion;

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        idcliente: json["idcliente"] ?? 0,
        cliente: json["cliente"] ?? '',
        telefono: json["telefono"] ?? '',
        direccion: json["direccion"] ?? '',
        urllogo: json["urllogo"] ?? '',
        estatus: json["estatus"] ?? '',
        clienteAplicacion: json["clienteAplicacion"] == null
            ? null
            : ClienteAplicacion.fromJson(json["clienteAplicacion"]),
      );

  Map<String, dynamic> toJson() => {
        "idcliente": idcliente,
        "cliente": cliente,
        "telefono": telefono,
        "direccion": direccion,
        "urllogo": urllogo,
        "estatus": estatus,
        "clienteAplicacion":
            clienteAplicacion == null ? null : clienteAplicacion,
      };
}
