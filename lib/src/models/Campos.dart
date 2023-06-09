import 'dart:convert';

import 'package:flutter/material.dart';

Campos camposFromJson(String str) => Campos.fromJson(json.decode(str));

String camposToJson(Campos data) => json.encode(data.toJson());

class Campos {
  Campos({
    this.idCampo,
    this.agrupacion,
    this.nombreCampo,
    this.validarDuplicidad,
    this.tipoCampo,
    this.restriccion,
    this.editable,
    this.alerta,
    this.longitud,
    this.valor,
    this.pordefecto,
    this.valorTipoCampo,
    this.valorController,
    this.controladorNombreCampo,
    this.controladorLongitud,
    this.controladorRestriccion,
  });

  int idCampo;
  String agrupacion;
  String nombreCampo;
  String validarDuplicidad;
  String tipoCampo;
  String restriccion;
  String editable;
  String alerta;
  int longitud;
  String valor;
  String pordefecto;
  String valorTipoCampo;
  TextEditingController controladorNombreCampo;
  TextEditingController controladorRestriccion;
  TextEditingController controladorLongitud;
  TextEditingController valorController;

  factory Campos.fromJson(Map<String, dynamic> json) {
    TextEditingController controller = TextEditingController();
    controller.text = json["valor"] ?? '';
    if (controller.text.isEmpty) {
      controller.text = json['pordefecto'] ?? '';
    }
    return Campos(
      idCampo: json["idCampo"] ?? 0,
      agrupacion: json["agrupacion"] ?? '',
      nombreCampo: json["nombreCampo"] ?? '',
      validarDuplicidad: json['validarduplicidad'],
      tipoCampo: json["tipoCampo"] ?? '',
      restriccion: json["restriccion"] ?? '',
      editable: json['editable'] ?? 'TRUE',
      alerta: json["alerta"] ?? '',
      longitud: json["longitud"] ?? 0,
      valor: controller.text,
      valorController: controller,
      pordefecto: json['pordefecto'],
    );
  }

  Map<String, dynamic> toJson() => {
        "idCampo": idCampo,
        "agrupacion": agrupacion,
        "nombreCampo": nombreCampo,
        "tipoCampo": tipoCampo,
        "restriccion": restriccion,
        "alerta": alerta,
        "longitud": longitud,
        "valor": valor,
      };
}
