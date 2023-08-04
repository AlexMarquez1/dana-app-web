import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

Agrupaciones agrupacionesFromJson(String str) =>
    Agrupaciones.fromJson(json.decode(str));

String agrupacionesToJson(Agrupaciones data) => json.encode(data.toJson());

class Agrupaciones {
  Agrupaciones({
    this.agrupacion,
    this.campos,
    this.idInventario,
  });

  String agrupacion;
  int idInventario;
  List<Campos> campos;

  factory Agrupaciones.fromJson(Map<String, dynamic> json) {
    Agrupaciones agrupacion;
    List<Campos> listaCampos = [];
    for (int i = 0; i < json['campos'].length; i++) {
      listaCampos.add(Campos.fromJson(
        json['campos'].elementAt(i),
      ));
    }
    agrupacion = Agrupaciones(
      agrupacion: json["agrupacion"] ?? '',
      campos: listaCampos,
      idInventario: json['idInventario'] ?? '',
    );
    return agrupacion;
  }

  Map<String, dynamic> toJson() => {
        "agrupacion": agrupacion,
        "campos": List<Campos>.from(campos.map((x) => x)),
      };
}
