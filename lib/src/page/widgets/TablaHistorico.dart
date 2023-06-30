import 'package:app_isae_desarrollo/src/models/HistorialCambios.dart';
import 'package:flutter/material.dart';

class TablaHistorico extends DataTableSource {
  List<HistorialCambios> listaCambios;
  Function clickImagen;

  TablaHistorico(this.listaCambios, this.clickImagen);

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(listaCambios.elementAt(index).campo.campo)),
      DataCell(Text(listaCambios.elementAt(index).usuario.nombre)),
      DataCell(_valorComoImagen(listaCambios.elementAt(index).valoranterior,
          listaCambios.elementAt(index).campo.tipocampo)),
      DataCell(_valorComoImagen(listaCambios.elementAt(index).valornuevo,
          listaCambios.elementAt(index).campo.tipocampo)),
      DataCell(Text(listaCambios.elementAt(index).fechacambio)),
      DataCell(Text(listaCambios.elementAt(index).horacambio)),
      DataCell(IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.restart_alt,
          color: Colors.green,
        ),
      )),
    ]);
  }

  Widget _valorComoImagen(String valor, String tipoCampo) {
    print(tipoCampo);
    if (valor.contains('https')) {
      return IconButton(
          onPressed: () {
            clickImagen(valor);
          },
          icon: Icon(Icons.image));
    } else {
      return Text(valor);
    }
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => listaCambios.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
