import 'dart:convert';

FirmaDocumento firmaDocumentoFromJson(String str) =>
    FirmaDocumento.fromJson(json.decode(str));

String firmaDocumentoToJson(FirmaDocumento data) => json.encode(data.toJson());

class FirmaDocumento {
  FirmaDocumento({
    this.idfirma,
    this.nombrefirma,
    this.url,
    this.longitud,
    this.camposProyecto,
    this.inventario,
  });

  int idfirma;
  String nombrefirma;
  String url;
  int longitud;
  int camposProyecto;
  int inventario;

  factory FirmaDocumento.fromJson(Map<String, dynamic> json) => FirmaDocumento(
        idfirma: json["idfirma"] ?? 0,
        nombrefirma: json["nombrefirma"] ?? '',
        url: json["url"] ?? '',
        longitud: json["longitud"] ?? 0,
        camposProyecto: json["camposProyecto"]['idcamposproyecto'] ?? '',
        inventario: json["inventario"]['idinventario'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "idfirma": idfirma,
        "nombrefirma": nombrefirma,
        "url": url,
        "longitud": longitud,
        "camposProyecto": camposProyecto,
        "inventario": inventario,
      };
}
