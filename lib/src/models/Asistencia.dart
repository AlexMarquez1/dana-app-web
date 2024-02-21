import 'dart:convert';

import 'Usuario.dart';

Asistencia asistenciaFromJson(String str) =>
    Asistencia.fromJson(json.decode(str));

String asistenciaToJson(Asistencia data) => json.encode(data.toJson());

class Asistencia {
  Asistencia({
    this.usuario,
    this.horaDeEntrada,
    this.horaDeSalida,
    this.dia,
    this.urlFoto,
    this.coordenadasFoto,
  });

  Usuario? usuario;
  String? horaDeEntrada;
  String? horaDeSalida;
  String? dia;
  String? urlFoto;
  String? coordenadasFoto;

  factory Asistencia.fromJson(Map<String, dynamic> json) => Asistencia(
        usuario: Usuario.fromJson(json["usuario"]),
        horaDeEntrada: json["horaDeEntrada"],
        horaDeSalida: json["horaDeSalida"],
        dia: json["dia"],
        urlFoto: json["urlFoto"],
        coordenadasFoto: json["coordenadasFoto"],
      );

  Map<String, dynamic> toJson() => {
        "Usuario": usuario!.toJson(),
        "horaDeEntrada": horaDeEntrada,
        "horaDeSalida": horaDeSalida,
        "dia": dia,
        "urlFoto": urlFoto,
        "coordenadasFoto": coordenadasFoto,
      };
}
