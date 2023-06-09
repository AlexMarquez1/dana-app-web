import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/Campos.dart';

CamposProyecto camposProyectoFromJson(String str) =>
    CamposProyecto.fromJson(json.decode(str));

class CamposProyecto {
  CamposProyecto({
    this.idcamposproyecto,
    this.alerta,
    this.campo,
    this.validadDuplicidad,
    this.editable,
    this.longitud,
    this.pattern,
    this.tipocampo,
    this.idAgrupacion,
  });

  int idcamposproyecto;
  String alerta;
  String campo;
  String validadDuplicidad;
  String editable;
  int longitud;
  String pattern;
  String tipocampo;
  int idAgrupacion;

  factory CamposProyecto.fromJson(Map<String, dynamic> json) => CamposProyecto(
        idcamposproyecto: json['idcamposproyecto'] ?? 0,
        alerta: json['alerta'] ?? '',
        campo: json['campo'] ?? '',
        validadDuplicidad: json['validarduplicidad'] ?? '',
        editable: json['editable'] ?? 'TRUE',
        longitud: json['longitud'] ?? 0,
        pattern: json['pattern'] ?? '',
        tipocampo: json['tipocampo'] ?? '',
        idAgrupacion: json['idagrupacion'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'idcamposproyecto': idcamposproyecto,
        'alerta': alerta,
        'campo': campo,
        'validarduplicidad': validadDuplicidad,
        'editable': editable,
        'longitud': longitud,
        'pattern': pattern,
        'tipocampo': tipocampo,
      };
}
