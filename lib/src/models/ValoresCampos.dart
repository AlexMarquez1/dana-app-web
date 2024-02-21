import 'dart:convert';

ValoresCampos valoresCamposFromJson(String str) =>
    ValoresCampos.fromJson(json.decode(str));

String valoresCamposToJson(ValoresCampos data) => json.encode(data.toJson());

class ValoresCampos {
  ValoresCampos({
    this.idvalor,
    this.idcampoproyecto,
    this.idinventario,
    this.valor,
  });

  String? idvalor;
  int? idcampoproyecto;
  int? idinventario;
  String? valor;

  factory ValoresCampos.fromJson(Map<String, dynamic> json) => ValoresCampos(
        idvalor: json["idvalor"],
        idcampoproyecto: json["idcampoproyecto"],
        idinventario: json["idinventario"],
        valor: json["valor"],
      );

  Map<String, dynamic> toJson() => {
        "idvalor": idvalor,
        "idcampoproyecto": idcampoproyecto,
        "idinventario": idinventario,
        "valor": valor,
      };
}
