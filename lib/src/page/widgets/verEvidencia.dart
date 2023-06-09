import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/Registro.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DetallesImagen.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:archive/archive.dart' as webarc;
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/FirmaDocumento.dart';
import '../../models/FotoEvidencia.dart';
import '../../models/Inventario.dart';
import '../../services/APIWebService/ApiDefinitions.dart';
import '../../services/APIWebService/Consultas.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class VerEvidencia extends StatelessWidget {
  Registro inventario;
  VerEvidencia({Key key, @required this.inventario}) : super(key: key);

  List<FirmaDocumento> listaFirmas;
  List<FotoEvidencia> listaFotos;
  List<FotoEvidencia> listaEvidencias;
  String urlDocumento;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          PantallaDeCarga.loadingI(context, true);
          List<FirmaDocumento> listaFirmas = await obtenerFirmaProyecto(
              ApiDefinition.ipServer,
              inventario.proyecto.idproyecto,
              inventario.idRegistro);

          List<FotoEvidencia> listaFotos = await obtenerFotosProyecto(
              ApiDefinition.ipServer,
              inventario.proyecto.idproyecto,
              inventario.idRegistro);

          List<FotoEvidencia> listaEvidencias =
              await obtenerCheckBoxEvidenciaProyecto(
                  ApiDefinition.ipServer,
                  inventario.proyecto,
                  Inventario(
                    idinventario: inventario.idRegistro,
                    estatus: inventario.estatus,
                    fechacreacion: inventario.fechaCreacion,
                    folio: inventario.folio,
                    proyecto: inventario.proyecto,
                  ));

          String urlDocumento = await obtenerUrlDocumento(
              ApiDefinition.ipServer, inventario.idRegistro);

          PantallaDeCarga.loadingI(context, false);

          await _evidencia(
              context, listaFotos, listaEvidencias, listaFirmas, urlDocumento);
        },
        icon: Icon(Icons.file_present));
  }

  _evidencia(
      BuildContext context,
      List<FotoEvidencia> listaFotos,
      List<FotoEvidencia> listaEvidencias,
      List<FirmaDocumento> listaFirmas,
      String urlDocumento) async {
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Container(
              height: 50.0,
              child: Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(child: Text('Evidencia')),
                      Container(child: Text('Registro: ${inventario.folio}')),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        PantallaDeCarga.loadingI(context, true);
                        List<Uint8List> archivos = [];
                        for (FotoEvidencia evidencia in listaEvidencias) {
                          archivos.add(await _obtenerArchivo(evidencia.url));
                        }
                        await _downloadFilesAsZIP(
                            context, archivos, listaEvidencias);
                        PantallaDeCarga.loadingI(context, false);
                      },
                      child: Text('Descargar Todo')),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close))
                ],
              ),
            ),
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 800,
                color: Colors.grey[400],
                child: Wrap(spacing: 10.0, runSpacing: 10.0, children: [
                  for (FotoEvidencia foto in listaFotos)
                    _mostrarEvidencia(foto),
                  for (FotoEvidencia evidencia in listaEvidencias)
                    evidencia.url.isNotEmpty
                        ? _mostrarEvidencia(evidencia)
                        : Container(),
                  for (FirmaDocumento firma in listaFirmas)
                    _mostrarEvidencia(FotoEvidencia(
                      campoNombre: firma.nombrefirma,
                      nombrefoto: firma.nombrefirma,
                      url: firma.url,
                    )),
                  urlDocumento.isNotEmpty
                      ? InkWell(
                          child: Container(
                            width: 180,
                            height: 210,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 61, 113, 158),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Icon(Icons.picture_as_pdf,
                                color: Colors.white, size: 80.0),
                          ),
                          onTap: () {
                            html.window.open(urlDocumento, 'new tab');
                          },
                        )
                      : Container(),
                ]),
              ),
            ],
          );
        });
  }

  Widget _mostrarEvidencia(FotoEvidencia evidencia) {
    return Stack(
      children: [
        DetallesImagen(
            evidencia: evidencia,
            seleccionCheck: false,
            tipoComponente: '',
            anchoImagen: 180,
            altoImagen: 210),
        CircleAvatar(
          backgroundColor: Color.fromARGB(255, 61, 113, 158),
          child: IconButton(
              onPressed: () async {
                Uint8List bytes = await _obtenerArchivo(evidencia.url);
                _downloadFile('${evidencia.nombrefoto}', bytes);
              },
              icon: Icon(Icons.download_for_offline, color: Colors.white)),
        ),
      ],
    );
  }

  void _downloadFileUrl(String url) {
    html.AnchorElement anchorElement = new html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  Future<Uint8List> _obtenerArchivo(String url) async {
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(url));
    Uint8List bytes = req.bodyBytes;
    File archivo = File.fromRawPath(bytes);
    return bytes;
  }

  Future<void> _downloadFilesAsZIP(
      context, List<Uint8List> archivos, List<FotoEvidencia> evidencias) async {
    // _downloadFile('Evidencia.zip', encoder);
    var encoder = ZipEncoder();
    var archive = Archive();
    int i = 0;
    for (Uint8List archivo in archivos) {
      ArchiveFile archiveFiles = ArchiveFile.stream(
        '${evidencias.elementAt(i).inventario.folio}/${evidencias.elementAt(i).nombrefoto.replaceAll(' ', '')}',
        archivo.length,
        InputStream(archivo,
            byteOrder: LITTLE_ENDIAN, start: 0, length: archivo.length),
      );
      archive.addFile(archiveFiles);
      i++;
    }

    var outputStream = OutputStream(
      byteOrder: LITTLE_ENDIAN,
    );
    var bytes = encoder.encode(archive,
        level: Deflate.BEST_COMPRESSION, output: outputStream);
    _downloadFile("Evidencia.zip", bytes);
  }

  _downloadFile(String fileName, Uint8List bytes) {
    final content = base64Encode(bytes);
    final anchor = html.AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "$fileName")
      ..click();
//     final blob = html.Blob([bytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.document.createElement('a') as html.AnchorElement
//       ..href = url
//       ..style.display = 'none'
//       ..download = fileName;
//     html.document.body.children.add(anchor);

// // download
//     anchor.click();

// // cleanup
//     html.document.body.children.remove(anchor);
//     html.Url.revokeObjectUrl(url);
  }
}
