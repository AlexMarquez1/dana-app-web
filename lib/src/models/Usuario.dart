import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  Usuario(
      {this.idUsuario,
      this.nombre,
      this.usuario,
      this.correo,
      this.telefono,
      this.ubicacion,
      this.jefeInmediato,
      this.perfil,
      this.password,
      this.passTemp,
      this.token,
      this.status,
      this.clienteAplicacion,
      this.vistacliente});

  int? idUsuario;
  String? nombre;
  String? usuario;
  String? correo;
  String? telefono;
  String? ubicacion;
  String? jefeInmediato;
  Perfil? perfil;
  String? password;
  int? passTemp;
  String? token;
  String? status;
  ClienteAplicacion? clienteAplicacion;
  Cliente? vistacliente;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
      idUsuario: json["idusuario"] ?? 0,
      nombre: json["nombre"] ?? '',
      usuario: json["usuario"] ?? '',
      correo: json["correo"] ?? '',
      telefono: json["telefono"] ?? '',
      ubicacion: json["ubicacion"] ?? '',
      jefeInmediato: json["jefeinmediato"] ?? '',
      perfil: json["perfile"] == null ? null : Perfil.fromJson(json["perfile"]),
      password: json["pass"].toString(),
      passTemp: json["passtemp"] ?? '',
      status: json["status"] ?? '',
      token: json["token"] ?? '',
      clienteAplicacion: json["clienteAplicacion"] == null
          ? null
          : ClienteAplicacion.fromJson(json["clienteAplicacion"]),
      vistacliente: json["vistaCliente"] == null
          ? null
          : Cliente.fromJson(json["vistaCliente"]));

  Map<String, dynamic> toJson() => {
        "idusuario": idUsuario,
        "nombre": nombre,
        "usuario": usuario,
        "correo": correo,
        "telefono": telefono,
        "ubicacion": ubicacion,
        "jefeinmediato": jefeInmediato,
        "perfile": perfil!.toJson(),
        "pass": password,
        "passtemp": passTemp,
        "status": status,
        "token": token,
        "clienteAplicacion": clienteAplicacion!.toJson(),
        "vistaCliente": vistacliente!.toJson(),
      };
}
