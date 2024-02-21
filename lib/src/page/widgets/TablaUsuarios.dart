import 'package:app_isae_desarrollo/src/utils/DatosUsuarios.dart';
import 'package:flutter/material.dart';

import '../../models/Usuario.dart';

class TablaUsuarios extends StatelessWidget {
  List<Usuario> listaUsuarios;
  Function accion;
  TablaUsuarios({Key? key, required this.listaUsuarios, required this.accion}) {
    _data = DatosUsuarios(data: listaUsuarios, accion: accion);
  }

  late DatosUsuarios _data;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _sort<T>(Comparable<T> Function(Usuario d) getField, int columnIndex,
      bool ascending, StateSetter actualizar) {
    _data.sort<T>(getField, ascending);
    actualizar(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(cardColor: Colors.grey[300], dividerColor: Colors.grey),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter actualizar) {
        return SizedBox(
          height: 660.0,
          child: ListView(
            children: [
              PaginatedDataTable(
                source: _data,
                header: const Text('Usuarios'),
                columns: [
                  DataColumn(
                      label: Text('ID'),
                      onSort: (int columnIndex, bool ascending) => _sort<num>(
                          (Usuario d) => d.idUsuario!,
                          columnIndex,
                          ascending,
                          actualizar)),
                  DataColumn(
                      label: Text('Nombre'),
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<String>((Usuario d) => d.nombre!, columnIndex,
                              ascending, actualizar)),
                  DataColumn(
                      label: Text('Usuario'),
                      onSort: (int columnIndex, bool ascending) =>
                          _sort<String>((Usuario d) => d.usuario!, columnIndex,
                              ascending, actualizar)),
                ],
                columnSpacing: 100,
                horizontalMargin: 10,
                rowsPerPage: 10,
                showCheckboxColumn: false,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
              ),
            ],
          ),
        );
      }),
    );
  }
}
