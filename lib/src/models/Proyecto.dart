import 'dart:convert';

Proyecto proyectoFromJson(String str) => Proyecto.fromJson(json.decode(str));

String proyectoToJson(Proyecto data) => json.encode(data.toJson());

class Proyecto {
  Proyecto({
    this.idproyecto,
    this.proyecto,
    this.descripcion,
    this.fechacreacion,
  });

  int? idproyecto;
  String? proyecto;
  String? descripcion;
  String? fechacreacion;

  factory Proyecto.fromJson(Map<String, dynamic> json) => Proyecto(
        idproyecto: json["idproyecto"] ?? 0,
        proyecto: json["proyecto"] ?? '',
        descripcion:
            json["descripcion"] ?? json['tipoproyecto']['descripcion'] ?? '',
        fechacreacion: json["fechacreacion"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idproyecto": idproyecto ?? '',
        "proyecto": proyecto ?? '',
        "descripcion": descripcion ?? '',
        "fechacreacion": fechacreacion ?? '',
      };
}



//SELECT * FROM `valores` WHERE idinventario IN (SELECT idinventario FROM `asignacionregistro` WHERE idusuario = 191)

//LERDO ESQ. RICARDO FLORES S/N, COLONIA UNIDAD HABITACIONAL NONOALCO TLATELOLCO, ALCALDIA CUAUHTEMOC, C.P. 06900, CDMX