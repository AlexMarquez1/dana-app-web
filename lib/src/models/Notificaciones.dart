import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

Notificaciones notificacionesFromJson(String str) =>
    Notificaciones.fromJson(json.decode(str));

String notificacionesToJson(Notificaciones data) => json.encode(data.toJson());

class Notificaciones {
  Notificaciones({
    this.id,
    this.titulo,
    this.contenido,
    this.data,
    this.image,
    this.token,
    this.imagenes,
  });

  int? id;
  String? titulo;
  String? contenido;
  Map<String, String>? data;
  String? image;
  List<Usuario>? token;
  List<FotoEvidencia>? imagenes;

  factory Notificaciones.fromJson(Map<String, dynamic> js) => Notificaciones(
        id: js["id"],
        titulo: js["titulo"],
        contenido: js["contenido"],
        data: json.decode(js["data"]),
        image: js["image"],
        token: List<Usuario>.from(js["token"].map((x) => x)),
        imagenes: List<FotoEvidencia>.from(js[""].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titulo": titulo,
        "contenido": contenido,
        "data": json.encode(data),
        "image": image,
        "token": List<Usuario>.from(token!.map((x) => x)),
        "imagenes": List<FotoEvidencia>.from(imagenes!.map((x) => x)),
      };
}
