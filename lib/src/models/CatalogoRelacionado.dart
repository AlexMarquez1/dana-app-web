import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Proyecto.dart';

CatalogoRelacionado catalogoRelacionadoFromJson(String str) =>
    CatalogoRelacionado.fromJson(json.decode(str));

String catalogoRelacionadoToJson(CatalogoRelacionado data) =>
    json.encode(data.toJson());

class CatalogoRelacionado {
  CatalogoRelacionado({
    this.tipoCatalogoPadre,
    this.catalogoPadre,
    this.tipoCatalogoHijo,
    this.catalogoHijo,
  });

  String tipoCatalogoPadre;
  String catalogoPadre;
  String tipoCatalogoHijo;
  List<String> catalogoHijo;

  factory CatalogoRelacionado.fromJson(Map<String, dynamic> json) =>
      CatalogoRelacionado(
        tipoCatalogoPadre: json["tipoCatalogoPadre"] ?? '',
        catalogoPadre: json["catalogoPadre"] ?? '',
        tipoCatalogoHijo: json["tipoCatalogoHijo"] ?? '',
        catalogoHijo: json["catalogoHijo"] == null
            ? []
            : List<String>.from(json["catalogoHijo"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tipoCatalogoPadre": tipoCatalogoPadre,
        "catalogoPadre": catalogoPadre,
        "tipoCatalogoHijo": tipoCatalogoHijo,
        "catalogoHijo": List<String>.from(catalogoHijo.map((x) => x)),
      };
}
