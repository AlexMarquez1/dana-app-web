import 'dart:math';

import 'package:flutter/material.dart';

import '../models/Usuario.dart';

class DatosUsuarios extends DataTableSource {
  List<Usuario> data;
  Function accion;

  DatosUsuarios({@required this.data, @required this.accion});

  void sort<T>(Comparable<T> Function(Usuario d) getField, bool ascending) {
    data.sort((Usuario a, Usuario b) {
      if (!ascending) {
        final Usuario c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(
        onSelectChanged: (onSelect) {
          accion(onSelect, data.elementAt(index));
        },
        cells: [
          DataCell(Text(data[index].idUsuario.toString())),
          DataCell(Text(data[index].nombre)),
          DataCell(Text(data[index].usuario)),
        ]);
  }
}
