import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/ValoresCampo.dart';
import 'package:excel/excel.dart';

class LeerExcel {
  static List<String> leerArchivoCSV(Uint8List archivoCSV) {
    List<String> contenidoArchivo = [];
    String comprobacion = 'correcto';
    //Validacion de las columnas
    String csvEncabezados = 'campo,tipocampo,agrupacion,restriccion,longitud';

    try {
      String s = new String.fromCharCodes(archivoCSV);
      // Get the UTF8 decode as a Uint8List
      var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
      // split the Uint8List by newline characters to get the csv file rows
      contenidoArchivo = utf8.decode(outputAsUint8List).split('\n');

      // Comprueba si las columnas tienen la estructura correcta
      if (contenidoArchivo[0].toString().toLowerCase().trim().hashCode !=
          csvEncabezados.hashCode) {
        // CSV file is not in correct format
        print('El archivo CSV no tiene un formato valido');
        comprobacion = 'Error: El archivo CSV no tiene un formato valido.';
      }

// check if CSV file has any content - content length > 0?
      if (contenidoArchivo.length == 0 || contenidoArchivo[1].length == 0) {
        // CSV file does not have content
        print('El archivo CSV no contiene informacion');
        comprobacion = 'Error: El archivo CSV no contiene informacion';
      }

// Current First row of the CSV file has column headers - remove it
      //contenidoArchivo.removeAt(0);
      print('Selected CSV File contents after removing the Column Headers: ');
    } catch (e) {
      print(e.toString());

      comprobacion = 'Error: ' + e.toString();
    }

    contenidoArchivo.add(comprobacion);

    return contenidoArchivo;
  }

  static List<String> leerCamposExcel(Uint8List archivo) {
    Excel excel = Excel.decodeBytes(archivo);
    List<String> respuesta = [];

    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table].maxCols);
      print(excel.tables[table].maxRows);
      for (List<Data> row in excel.tables[table].rows) {
        String contenidoFila = '';
        for (Data fila in row) {
          contenidoFila += fila == null ? ',' : fila.value.toString() + ',';
        }
        contenidoFila = contenidoFila.substring(0, contenidoFila.length - 1);
        respuesta.add(contenidoFila);
      }
    }
    respuesta.add('correcto');
    return respuesta;
  }

  static Map<String, dynamic> leerDatosExcel(
      Uint8List archivo, List<String> campos, List<int> idCampos) {
    Excel excel = Excel.decodeBytes(archivo);
    List<String> folios = [];
    List<ValoresCampo> valores = [];
    List<List<ValoresCampo>> listaValores = [];
    Map<String, dynamic> respuesta = <String, dynamic>{};
    respuesta['respuesta'] = 'error';

    String hoja = excel.tables.keys.first;
    bool camposCorrectos = false;

    print(hoja);
    print(excel.tables[hoja].maxCols);
    print(excel.tables[hoja].maxRows);

    if (excel.tables[hoja].maxCols == campos.length) {
      print('misma cantidad de campos');

      for (int i = 0; i < excel.tables[hoja].rows.first.length; i++) {
        if (campos.elementAt(i) ==
            excel.tables[hoja].rows.first.elementAt(i).value) {
          camposCorrectos = true;
        } else {
          camposCorrectos = false;
          respuesta['respuesta'] =
              'Los datos no se encuentran ordenados como se solicita, descarga la plantilla para un correcto funcionamiento';
          break;
        }
      }
    }
    print('camposCorrectos: $camposCorrectos');
    if (camposCorrectos) {
      respuesta['respuesta'] = 'correcto';
      for (int i = 1; i < excel.tables[hoja].rows.length; i++) {
        valores = [];
        folios.add(excel.tables[hoja].rows.elementAt(i).elementAt(0).value !=
                null
            ? excel.tables[hoja].rows.elementAt(i).elementAt(0).value.toString()
            : 'Nuevo Registro');

        print(excel.tables[hoja].rows.elementAt(i).elementAt(0).value != null
            ? excel.tables[hoja].rows.elementAt(i).elementAt(0).value.toString()
            : 'Nuevo Registro');
        for (int j = 0; j < excel.tables[hoja].rows.elementAt(i).length; j++) {
          if (excel.tables[hoja].rows.elementAt(i).elementAt(j).value != null) {
            if (excel.tables[hoja].rows
                    .elementAt(i)
                    .elementAt(j)
                    .value
                    .toString()
                    .split('-')
                    .length >=
                3) {
              String fechaObtenida =
                  '${excel.tables[hoja].rows.elementAt(i).elementAt(j).value.toString().split('-')[2].substring(0, 2)}/${excel.tables[hoja].rows.elementAt(i).elementAt(j).value.toString().split('-')[1]}/${excel.tables[hoja].rows.elementAt(i).elementAt(j).value.toString().split('-')[0]}';
              valores.add(
                ValoresCampo(
                  idCampo: idCampos.elementAt(j),
                  valor:
                      excel.tables[hoja].rows.elementAt(i).elementAt(j) != null
                          ? fechaObtenida
                          : '-',
                ),
              );
            } else {
              valores.add(
                ValoresCampo(
                  idCampo: idCampos.elementAt(j),
                  valor:
                      excel.tables[hoja].rows.elementAt(i).elementAt(j) != null
                          ? excel.tables[hoja].rows
                              .elementAt(i)
                              .elementAt(j)
                              .value
                              .toString()
                          : '-',
                ),
              );
            }
          } else {
            valores.add(
              ValoresCampo(
                idCampo: idCampos.elementAt(j),
                valor: excel.tables[hoja].rows.elementAt(i).elementAt(j) != null
                    ? excel.tables[hoja].rows
                        .elementAt(i)
                        .elementAt(j)
                        .value
                        .toString()
                    : '-',
              ),
            );
          }
        }
        listaValores.add(valores);
      }
    }

    respuesta['listaValores'] = listaValores;
    respuesta['folios'] = folios;

    return respuesta;
  }

  static List<String> leerPlantillaDatosProyecto(
      Uint8List archivoCSV, List<String> csvEncabezados) {
    List<String> contenidoArchivo = [];
    String encabezados;
    String comprobacion = 'correcto';

    encabezados = csvEncabezados.elementAt(0);
    for (int i = 1; i < csvEncabezados.length; i++) {
      encabezados += ',${csvEncabezados.elementAt(i).toUpperCase()}';
    }
    print(encabezados);

    try {
      String s = new String.fromCharCodes(archivoCSV);
      // Get the UTF8 decode as a Uint8List
      var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
      // split the Uint8List by newline characters to get the csv file rows
      contenidoArchivo = utf8.decode(outputAsUint8List).split('\n');

      // Comprueba si las columnas tienen la estructura correcta
      if (contenidoArchivo[0].toString().toUpperCase().trim().hashCode !=
          encabezados.hashCode) {
        // CSV file is not in correct format
        print('El archivo CSV no tiene un formato valido');
        comprobacion = 'Error: El archivo CSV no tiene un formato valido.';
      }

// check if CSV file has any content - content length > 0?
      if (contenidoArchivo.length == 0 || contenidoArchivo[1].length == 0) {
        // CSV file does not have content
        print('El archivo CSV no contiene informacion');
        comprobacion = 'Error: El archivo CSV no contiene informacion';
      }

// Current First row of the CSV file has column headers - remove it
      //contenidoArchivo.removeAt(0);
      print('Selected CSV File contents after removing the Column Headers: ');
    } catch (e) {
      print(e.toString());

      comprobacion = 'Error: ' + e.toString();
    }

    contenidoArchivo.add(comprobacion);

    return contenidoArchivo;
  }
}
