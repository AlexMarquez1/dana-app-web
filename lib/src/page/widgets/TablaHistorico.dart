import 'dart:convert';

import 'package:app_isae_desarrollo/src/models/HistorialCambios.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class TablaHistorico extends DataTableSource {
  BuildContext context;
  List<HistorialCambios> listaCambios;
  Function clickImagen;
  RegistroProvider registroProvider;

  TablaHistorico(
      this.context, this.listaCambios, this.clickImagen, this.registroProvider);

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
      DataCell(listaCambios.elementAt(index).campo.tipocampo ==
              'CHECKBOX-EVIDENCIA'
          ? Container()
          : IconButton(
              onPressed: () async {
                PantallaDeCarga.loadingI(context, true);
                String tipoCampo =
                    listaCambios.elementAt(index).campo.tipocampo;
                String campoNombre = listaCambios.elementAt(index).campo.campo;
                String valor = listaCambios.elementAt(index).valoranterior;
                List<int> ids = registroProvider
                    .obtenerAgrupacionInd(listaCambios.elementAt(index).campo);
                int indAgrupacion = ids[0];
                int indCampo = ids[1];
                if (tipoCampo != 'FIRMA' &&
                    tipoCampo != 'FOTO' &&
                    tipoCampo != 'CHECKBOX-EVIDENCIA') {
                  switch (tipoCampo) {
                    case 'HORA':
                      int hora = int.parse(valor.split(':')[0]);
                      int minuto = int.parse(valor.split(':')[1]);
                      final TimeOfDay picked =
                          TimeOfDay(hour: hora, minute: minuto);
                      registroProvider.actualizarCampoHorao(
                          campoNombre, picked);

                      break;
                    case 'CALENDARIO':
                      int dia = int.parse(valor.split('/')[0]);
                      int mes = int.parse(valor.split('/')[1]);
                      int anio = int.parse(valor.split('/')[2]);

                      DateTime picked = DateTime.utc(anio, mes, dia);
                      registroProvider.actualizarCampoCalendario(
                          registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo,
                          picked);
                      break;
                    default:
                      registroProvider.actualizarValor(
                          indAgrupacion, indCampo, valor);
                  }
                } else {
                  if (tipoCampo == 'FOTO' && !valor.contains('https')) {
                    registroProvider.actualizarValor(
                        indAgrupacion, indCampo, valor);
                  } else if (valor.contains('https')) {
                    switch (tipoCampo) {
                      case 'FIRMA':
                        registroProvider.firmas[registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo] = await _descargarFirma(valor);
                        registroProvider.comprobarFirmasActualizarDato(
                            listaCambios.elementAt(index).campo.campo, true);
                        break;
                      case 'FOTO':
                        registroProvider.evidencia[registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo] = await _descargarEvidencia(valor);
                        registroProvider.comprobarFotos[registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo] = true;

                        break;
                      case 'CHECKBOX-EVIDENCIA':
                        Dialogos.mensaje(
                            context, 'No se puede restablecer la imagen');
                        break;
                      default:
                    }
                  } else {
                    print('El valor no conincide con nada $valor');
                  }
                }
                PantallaDeCarga.loadingI(context, false);
              },
              icon: Icon(
                Icons.restart_alt,
                color: Colors.green,
              ),
            )),
    ]);
  }

  Future<Uint8List> _descargarEvidencia(String url) async {
    Uint8List bytes = Uint8List(0);
    try {
      http.Client client = http.Client();
      var req = await client.get(Uri.parse(url));

      bytes = req.bodyBytes;
    } catch (e) {
      print('Error al cargar evidencia');
    }
    return bytes;
  }

  Future<ByteData> _descargarFirma(String url) async {
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(url));
    Uint8List bytes = req.bodyBytes;
    ByteData firma = ByteData.view(bytes.buffer);
    return firma;
  }

  _downloadFile(String fileName, Uint8List bytes) {
    final content = base64Encode(bytes);
    String nombreFinal;
    if (fileName.contains('.pdf') || fileName.contains('.png')) {
      nombreFinal = fileName;
    } else {
      nombreFinal = '$fileName.png';
    }
    final anchor = html.AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "$nombreFinal")
      ..click();
  }

  Widget _valorComoImagen(String valor, String tipoCampo) {
    print(tipoCampo);
    if (valor.contains('https')) {
      return IconButton(
          onPressed: () {
            clickImagen(valor, () async {
              _downloadFile('Evidencia', await _descargarEvidencia(valor));
            });
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
