import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/Evidencia.dart';
import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/page/widgets/VistaPreviaFoto.dart';
import 'package:app_isae_desarrollo/src/providers/evidenciaSeleccionadaProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetallesImagenEvidenciaUrl extends StatefulWidget {
  String evidenciaUrl;
  String nombreEvidencia;
  double anchoImagen;
  double altoImagen;
  Function() eliminar;
  DetallesImagenEvidenciaUrl({
    Key? key,
    required this.evidenciaUrl,
    required this.nombreEvidencia,
    required this.anchoImagen,
    required this.altoImagen,
    required this.eliminar,
  }) : super(key: key);

  @override
  _DetallesImagenState createState() => _DetallesImagenState();
}

class _DetallesImagenState extends State<DetallesImagenEvidenciaUrl> {
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
                _vistaPreviaImagen(widget.evidenciaUrl);
              });
            },
            onLongPress: () {
              _vistaPreviaImagen(widget.evidenciaUrl);
            },
            splashColor: Colors.blue,
            child: Stack(
              children: [
                Image.network(
                  widget.evidenciaUrl,
                  fit: BoxFit.cover,
                ),
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

  void _vistaPreviaImagen(String url) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => VistaPreviaFoto(
        urlImagen: url,
        bytes: Uint8List(0),
      ),
    );
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
