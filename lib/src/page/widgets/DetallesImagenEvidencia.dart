import 'dart:convert';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/page/widgets/VistaPreviaFoto.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class DetallesImagenEvidencia extends StatefulWidget {
  Uint8List evidencia;
  String nombreEvidencia;
  double anchoImagen;
  double altoImagen;
  Function() eliminar;
  DetallesImagenEvidencia({
    Key? key,
    required this.evidencia,
    required this.nombreEvidencia,
    required this.anchoImagen,
    required this.altoImagen,
    required this.eliminar,
  }) : super(key: key);

  @override
  _DetallesImagenState createState() => _DetallesImagenState();
}

class _DetallesImagenState extends State<DetallesImagenEvidencia> {
  bool _seleccion = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        setState(() {
          _seleccion = true;
        });
      },
      onExit: (_) {
        setState(() {
          _seleccion = false;
        });
      },
      child: Card(
        color: Colors.white,
        child: SizedBox(
          height: widget.altoImagen,
          width: widget.anchoImagen,
          child: InkWell(
            onTap: () {
              setState(() {
                _vistaPreviaImagen();
              });
            },
            onLongPress: () {
              _vistaPreviaImagen();
            },
            splashColor: Colors.blue,
            child: Stack(
              children: [
                widget.nombreEvidencia.contains('.pdf')
                    ? Positioned(
                        top: 10.0,
                        child: Container(
                          width: 45.0,
                          height: 45.0,
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.blue[300],
                            size: 150.0,
                          ),
                        ),
                      )
                    : Image.memory(widget.evidencia, fit: BoxFit.cover),
                Container(
                  width: 45.0,
                  height: 45.0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red[300],
                    child: IconButton(
                        onPressed: widget.eliminar,
                        icon: Icon(Icons.delete, color: Colors.white)),
                  ),
                ),
                Positioned(
                  right: 0.0,
                  child: Container(
                    width: 45.0,
                    height: 45.0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue[300],
                      child: IconButton(
                          onPressed: () {
                            _downloadFile(
                                widget.nombreEvidencia, widget.evidencia);
                          },
                          icon: Icon(Icons.download, color: Colors.white)),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  // bottom: 0,
                  duration: const Duration(milliseconds: 500),
                  top: _seleccion ? 170 : 300.0,
                  // top: 170.0,
                  child: Container(
                    width: 200.0,
                    height: 100.0,
                    color: Colors.black.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tooltip(
                            message: 'Nombre: ${widget.nombreEvidencia}',
                            child: Container(
                              width: 190.0,
                              height: 50.0,
                              child: Text(
                                widget.nombreEvidencia,
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Tooltip(
                          //   message:
                          //       'Registro: ${widget.evidencia.inventario.folio}',
                          //   child: Container(
                          //     width: 190.0,
                          //     child: Text(
                          //       'Registro: ${widget.evidencia.inventario.folio}',
                          //       style: TextStyle(color: Colors.white),
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                          // ),
                          // Tooltip(
                          //   message: 'Nombre: ${widget.evidencia.nombrefoto}',
                          //   child: Container(
                          //     width: 190.0,
                          //     child: Text(
                          //       'Nombre: ${widget.evidencia.nombrefoto}',
                          //       style: TextStyle(color: Colors.white),
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _vistaPreviaImagen() async {
    if (widget.nombreEvidencia.contains('.pdf')) {
    } else {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) => VistaPreviaFoto(
          urlImagen: '',
          bytes: widget.evidencia,
        ),
      );
    }
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

  // void _actualizarComponente() {
  //   if (widget.tipoComponente == 'MARCAR') {
  //     widget.seleccionCheck = !widget.seleccionCheck;
  //     if (widget.seleccionCheck) {
  //       _evidenciaSeleccionada.add(widget.evidencia);
  //     } else {
  //       _evidenciaSeleccionada.remove(widget.evidencia);
  //     }
  //   } else {
  //     _vistaPreviaImagen();
  //   }
  // }
}
