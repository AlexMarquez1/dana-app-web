import 'dart:convert';

ValoresCampo valoresCampoFromJson(String str) =>
    ValoresCampo.fromJson(json.decode(str));

String valoresCampoToJson(ValoresCampo data) => json.encode(data.toJson());

class ValoresCampo {
  ValoresCampo({
    this.valor,
    this.idCampo,
    this.idInventario,
  });

  String valor;
  int idCampo;
  int idInventario;

  factory ValoresCampo.fromJson(Map<String, dynamic> json) => ValoresCampo(
        valor: json["valor"],
        idCampo: json["idCampo"],
        idInventario: json["idInventario"],
      );

  Map<String, dynamic> toJson() => {
        "valor": valor,
        "idCampo": idCampo,
        "idInventario": idInventario,
      };
}
