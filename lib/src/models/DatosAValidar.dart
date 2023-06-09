import 'dart:convert';

import 'Inventario.dart';

DatosAValidar datosAValidarFromJson(String str) =>
    DatosAValidar.fromJson(json.decode(str));

String datosAValidarToJson(DatosAValidar data) => json.encode(data.toJson());

class DatosAValidar {
  DatosAValidar({
    this.iddatoavalidar,
    this.dato,
    this.estatus,
    this.tipodedato,
    this.inventario,
  });

  int iddatoavalidar;
  String dato;
  String estatus;
  String tipodedato;
  Inventario inventario;

  factory DatosAValidar.fromJson(Map<String, dynamic> json) => DatosAValidar(
        iddatoavalidar: json["iddatoavalidar"] ?? 0,
        dato: json["dato"] ?? '',
        estatus: json["estatus"] ?? '',
        tipodedato: json["tipodedato"] ?? '',
        inventario: json["idinventario"] == 0
            ? Inventario(idinventario: 0)
            : Inventario(idinventario: json["idinventario"]),
      );

  Map<String, dynamic> toJson() => {
        "iddatoavalidar": iddatoavalidar,
        "dato": dato,
        "estatus": estatus,
        "tipodedato": tipodedato,
        "inventario": inventario.toJson(),
      };
}
