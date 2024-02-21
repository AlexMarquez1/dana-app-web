import 'dart:convert';

Perfil perfilFromJson(String str) => Perfil.fromJson(json.decode(str));

String perfilToJson(Perfil data) => json.encode(data.toJson());

class Perfil {
  Perfil({
    this.idperfil,
    this.perfil,
  });

  String? idperfil;
  String? perfil;

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
        idperfil: (json["idperfil"] ?? 0).toString(),
        perfil: json["perfil"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idperfil": idperfil,
        "perfil": perfil,
      };
}
