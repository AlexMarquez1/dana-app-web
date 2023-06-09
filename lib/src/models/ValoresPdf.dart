import 'dart:convert';

ValoresPdf valoresPdfFromJson(String str) =>
    ValoresPdf.fromJson(json.decode(str));

String valoresPdfToJson(ValoresPdf data) => json.encode(data.toJson());

class ValoresPdf {
  ValoresPdf({
    this.nombreCampo,
    this.valor,
  });

  String nombreCampo;
  String valor;

  factory ValoresPdf.fromJson(Map<String, dynamic> json) => ValoresPdf(
        nombreCampo: json["nombreCampo"],
        valor: json["Valor"],
      );

  Map<String, dynamic> toJson() => {
        "nombreCampo": nombreCampo,
        "Valor": valor,
      };
}
