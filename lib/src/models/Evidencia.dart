import 'dart:convert';

Evidencia firmaFromJson(String str) => Evidencia.fromJson(json.decode(str));

String firmaToJson(Evidencia data) => json.encode(data.toJson());

class Evidencia {
  Evidencia({
    this.idEvidencia,
    this.nombreEvidencia,
    this.evidencia,
    this.idCampo,
    this.idInventario,
  });

  int idEvidencia;
  String nombreEvidencia;
  List<int> evidencia;
  int idCampo;
  int idInventario;

  factory Evidencia.fromJson(Map<String, dynamic> json) => Evidencia(
        idEvidencia: json["idEvidencia"],
        nombreEvidencia: json["nombreEvidencia"],
        evidencia: List<int>.from(json["evidencia"].map((x) => x)),
        idCampo: json["camposProyecto"]["idcamposproyecto"],
        idInventario: json["inventario"]["idinventario"],
      );

  Map<String, dynamic> toJson() => {
        "idEvidencia": idEvidencia,
        "nombreEvidencia": nombreEvidencia,
        "evidencia": List<dynamic>.from(evidencia.map((x) => x)),
        "camposProyecto": {'idcamposproyecto': idCampo},
        "inventario": {'idinventario': idInventario},
      };
}
