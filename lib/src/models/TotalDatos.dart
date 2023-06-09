import 'dart:convert';

TotalDatos totalDatosFromJson(String str) =>
    TotalDatos.fromJson(json.decode(str));

String totalDatosToJson(TotalDatos data) => json.encode(data.toJson());

class TotalDatos {
  TotalDatos({
    this.tipoProyecto,
    this.totalRegistros,
    this.totalCerrados,
    this.totalPendientes,
    this.totalEnProceso,
    this.totalAsignados,
    this.totalNuevos,
  });

  String tipoProyecto;
  int totalRegistros;
  int totalCerrados;
  int totalPendientes;
  int totalEnProceso;
  int totalAsignados;
  int totalNuevos;

  factory TotalDatos.fromJson(Map<String, dynamic> json) => TotalDatos(
        tipoProyecto: json["tipoProyecto"],
        totalRegistros: json["totalRegistros"],
        totalCerrados: json["totalCerrados"],
        totalPendientes: json["totalPendientes"],
        totalEnProceso: json["totalEnProceso"],
        totalAsignados: json["totalAsignados"],
        totalNuevos: json["totalNuevos"],
      );

  Map<String, dynamic> toJson() => {
        "tipoProyecto": tipoProyecto,
        "totalCerrados": totalCerrados,
        "totalPendientes": totalPendientes,
        "totalEnProceso": totalEnProceso,
        "totalAsignados": totalAsignados,
        "totalNuevos": totalNuevos,
      };
}
