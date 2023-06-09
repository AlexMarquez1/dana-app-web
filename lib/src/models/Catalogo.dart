import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Proyecto.dart';

Catalogo catalogoFromJson(String str) => Catalogo.fromJson(json.decode(str));

String catalogoToJson(Catalogo data) => json.encode(data.toJson());

class Catalogo {
  Catalogo({
    this.tipoCatalogo,
    this.proyecto,
    this.catalogo,
  });

  String tipoCatalogo;
  Proyecto proyecto;
  List<String> catalogo;

  factory Catalogo.fromJson(Map<String, dynamic> json) => Catalogo(
        tipoCatalogo: json["tipoCatalogo"] ?? '',
        proyecto: json["proyecto"] == null
            ? Proyecto()
            : Proyecto.fromJson(json["proyecto"]),
        catalogo: json["catalogo"] == null
            ? []
            : List<String>.from(json["catalogo"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tipoCatalogo": tipoCatalogo,
        "proyecto": proyecto.toJson(),
        "catalogo": List<String>.from(catalogo.map((x) => x)),
      };
}
