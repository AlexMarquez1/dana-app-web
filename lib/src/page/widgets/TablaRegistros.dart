import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/verEvidencia.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';

class TablaRegistros extends DataTableSource {
  List<Inventario> listaInventario;
  Function clickPdf;
  Function clickVolverACargar;
  Function clickEditarAsignacion;
  Function accionSeleccionarRegistro;
  Function clickRegistro;
  Map<int, bool> registroSeleccion;

  TablaRegistros({
    required this.listaInventario,
    required this.clickEditarAsignacion,
    required this.clickPdf,
    required this.clickVolverACargar,
    required this.accionSeleccionarRegistro,
    required this.registroSeleccion,
    required this.clickRegistro,
  });

  @override
  DataRow getRow(int index) {
    return DataRow(
      onLongPress: () {
        clickRegistro(listaInventario.elementAt(index));
      },
      cells: [
        DataCell(Text(listaInventario.elementAt(index).folio!)),
        DataCell(Text(listaInventario.elementAt(index).estatus!)),
        DataCell(Text(listaInventario.elementAt(index).fechacreacion!)),
        DataCell(IconButton(
          onPressed: () {
            clickRegistro(listaInventario.elementAt(index));
          },
          icon: Icon(Icons.open_in_new_rounded),
        )),
        DataCell(IconButton(
          onPressed: () {
            clickPdf(listaInventario.elementAt(index));
          },
          icon: Icon(Icons.picture_as_pdf),
        )),
        DataCell(IconButton(
          onPressed: () {
            clickVolverACargar(listaInventario.elementAt(index));
          },
          icon: Icon(Icons.replay_outlined),
        )),
        DataCell(VerEvidencia(
          inventario: listaInventario.elementAt(index),
        )),
        // DataCell(IgnorePointer(
        //   ignoring: VariablesGlobales.usuario.perfil.idperfil == "4",
        //   child: IconButton(
        //     onPressed: () {
        //       clickEditarAsignacion(listaInventario.elementAt(index));
        //     },
        //     icon: Icon(Icons.edit_note_sharp),
        //   ),
        // )),
      ],
      selected:
          registroSeleccion[listaInventario.elementAt(index).idinventario]!,
      onSelectChanged: (seleccion) {
        // if (listaInventario.elementAt(index).estatus == 'CERRADO') {
        if (seleccion!) {
          registroSeleccion[listaInventario.elementAt(index).idinventario!] =
              seleccion;
        } else {
          registroSeleccion[listaInventario.elementAt(index).idinventario!] =
              seleccion;
        }
        accionSeleccionarRegistro(seleccion, listaInventario.elementAt(index));
        notifyListeners();
        // }
      },
    );
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => listaInventario.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
