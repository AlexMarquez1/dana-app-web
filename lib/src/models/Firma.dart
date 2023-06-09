import 'dart:convert';

Firma firmaFromJson(String str) => Firma.fromJson(json.decode(str));

String firmaToJson(Firma data) => json.encode(data.toJson());

class Firma {
  Firma({
    this.idFirma,
    this.nombreFirma,
    this.firma,
    this.idCampo,
    this.idInventario,
  });

  int idFirma;
  String nombreFirma;
  List<int> firma;
  int idCampo;
  int idInventario;

  factory Firma.fromJson(Map<String, dynamic> json) => Firma(
        idFirma: json["idFirma"],
        nombreFirma: json["nombreFirma"],
        firma: List<int>.from(json["firma"].map((x) => x)),
        idCampo: json["camposProyecto"]["idcamposproyecto"],
        idInventario: json["inventario"]["idinventario"],
      );

  Map<String, dynamic> toJson() => {
        "idFirma": idFirma,
        "nombreFirma": nombreFirma,
        "firma": List<dynamic>.from(firma.map((x) => x)),
        "camposProyecto": {'idcamposproyecto': idCampo},
        "inventario": {'idinventario': idInventario},
      };
}
