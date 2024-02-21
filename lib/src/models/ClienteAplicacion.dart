import 'dart:convert';

ClienteAplicacion clienteFromJson(String str) =>
    ClienteAplicacion.fromJson(json.decode(str));

String clienteToJson(ClienteAplicacion data) => json.encode(data.toJson());

class ClienteAplicacion {
  int? idcliente;
  String? cliente;
  String? urllogo;
  String? estatus;

  ClienteAplicacion({
    this.idcliente,
    this.cliente,
    this.urllogo,
    this.estatus,
  });

  factory ClienteAplicacion.fromJson(Map<String, dynamic> json) =>
      ClienteAplicacion(
        idcliente: json["idcliente"] ?? 0,
        cliente: json["cliente"] ?? '',
        urllogo: json["urllogo"] ?? '',
        estatus: json["estatus"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "idcliente": idcliente,
        "cliente": cliente,
        "urllogo": urllogo,
        "estatus": estatus,
      };
}
