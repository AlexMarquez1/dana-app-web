import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Perfil.dart';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  Usuario(
      this._idUsuario,
      this._nombre,
      this._usuario,
      this._correo,
      this._telefono,
      this._ubicacion,
      this._jefeInmediato,
      this._perfil,
      this._password,
      this._passTemp,
      {this.token});

  int _idUsuario;
  String _nombre;
  String _usuario;
  String _correo;
  String _telefono;
  String _ubicacion;
  String _jefeInmediato;
  Perfil _perfil;
  String _password;
  int _passTemp;
  String token;

  int get idUsuario {
    return _idUsuario;
  }

  set idUsuario(int idUsuario) {
    _idUsuario = idUsuario;
  }

  String get nombre {
    return _nombre;
  }

  set nombre(String nombre) {
    _nombre = nombre;
  }

  String get usuario {
    return _usuario;
  }

  set usuario(String usuario) {
    _usuario = usuario;
  }

  String get correo {
    return _correo;
  }

  set(String correo) {
    _correo = correo;
  }

  String get telefono {
    return _telefono;
  }

  set telefono(String telefono) {
    _telefono = telefono;
  }

  String get ubicacion {
    return _ubicacion;
  }

  set ubicacion(String ubicacion) {
    _ubicacion = ubicacion;
  }

  String get jefeInmediato {
    return _jefeInmediato;
  }

  set jefeInmediato(String jefeInmediato) {
    _jefeInmediato = jefeInmediato;
  }

  Perfil get perfil {
    return _perfil;
  }

  set perfil(Perfil perfil) {
    _perfil = perfil;
  }

  String get password {
    return _password;
  }

  set password(String password) {
    _password = password;
  }

  int get passTemp {
    return _passTemp;
  }

  set passTemp(int passTemp) {
    _passTemp = passTemp;
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        json["idusuario"] ?? 0,
        json["nombre"] ?? '',
        json["usuario"] ?? '',
        json["correo"] ?? '',
        json["telefono"] ?? '',
        json["ubicacion"] ?? '',
        json["jefeinmediato"] ?? '',
        json["perfile"] == null ? null : Perfil.fromJson(json["perfile"]),
        json["pass"].toString(),
        json["passtemp"] ?? '',
        token: json["token"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idusuario": _idUsuario,
        "nombre": _nombre,
        "usuario": _usuario,
        "correo": _correo,
        "telefono": _telefono,
        "ubicacion": _ubicacion,
        "jefeinmediato": _jefeInmediato,
        "perfile": perfil.toJson(),
        "pass": _password,
        "passtemp": _passTemp,
        "token": token,
      };
}
