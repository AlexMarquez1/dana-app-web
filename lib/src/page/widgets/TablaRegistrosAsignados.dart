import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:flutter/material.dart';

class TablaRegistroAsignado extends DataTableSource {
  List<Inventario> datos;
  Function clickRegistro;
  Function clickEliminar;
  bool registroAsignado;
  Map<String, bool> seleccionRegistro;

  TablaRegistroAsignado(this.datos, this.clickRegistro, this.registroAsignado,
      {this.clickEliminar, this.seleccionRegistro});

  @override
  DataRow getRow(int index) {
    List<DataCell> celdas = [];
    celdas.add(DataCell(Text(datos.elementAt(index).folio)));
    celdas.add(DataCell(Text(datos.elementAt(index).fechacreacion)));
    celdas.add(DataCell(Text(datos.elementAt(index).estatus != null
        ? datos.elementAt(index).estatus
        : 'nada')));
    if (registroAsignado) {
      celdas.add(DataCell(IconButton(
        onPressed: () {
          clickEliminar(datos.elementAt(index));
        },
        icon: Icon(
          Icons.delete,
          color: Colors.red,
        ),
      )));
      return DataRow(cells: celdas);
    } else {
      return DataRow(
          cells: celdas,
          selected: seleccionRegistro[datos.elementAt(index).folio],
          onSelectChanged: (seleccion) {
            if (seleccion) {
              seleccionRegistro[datos.elementAt(index).folio] = seleccion;
            } else {
              seleccionRegistro[datos.elementAt(index).folio] = seleccion;
            }
            notifyListeners();
          });
    }
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => datos.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
