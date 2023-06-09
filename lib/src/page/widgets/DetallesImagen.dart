import 'package:app_isae_desarrollo/src/models/Evidencia.dart';
import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/page/widgets/VistaPreviaFoto.dart';
import 'package:app_isae_desarrollo/src/providers/evidenciaSeleccionadaProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class DetallesImagen extends StatefulWidget {
  FotoEvidencia evidencia;
  bool seleccionCheck;
  String tipoComponente;
  double anchoImagen;
  double altoImagen;
  DetallesImagen({
    Key key,
    @required this.evidencia,
    @required this.seleccionCheck,
    @required this.tipoComponente,
    @required this.anchoImagen,
    @required this.altoImagen,
  }) : super(key: key);

  @override
  _DetallesImagenState createState() => _DetallesImagenState();
}

class _DetallesImagenState extends State<DetallesImagen> {
  EvidenciaSeleccionadaProvider _evidenciaSeleccionada;
  bool _seleccion = false;

  @override
  void initState() {
    _evidenciaSeleccionada =
        Provider.of<EvidenciaSeleccionadaProvider>(context, listen: false);
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
                _actualizarComponente();
              });
            },
            onLongPress: () {
              _vistaPreviaImagen();
            },
            splashColor: Colors.blue,
            child: Stack(
              children: [
                widget.evidencia.nombrefoto.contains('.pdf')
                    ? SizedBox(
                        width: widget.anchoImagen,
                        height: widget.altoImagen,
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.blue,
                          size: 100.0,
                        ),
                      )
                    : Material(
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/img/loadingImage.gif',
                          image: widget.evidencia.url,
                          fit: BoxFit.cover,
                          width: widget.anchoImagen,
                          height: widget.altoImagen,
                        ),
                        type: MaterialType.transparency,
                      ),
                // Image.network(widget.evidencia.url),
                for (Widget item in _tipoComponente()) item,

                AnimatedPositioned(
                  // bottom: 0,
                  duration: const Duration(milliseconds: 500),
                  top: _seleccion ? 130 : 200.0,
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
                            message:
                                'Proyecto: ${widget.evidencia.inventario.proyecto.proyecto}',
                            child: Container(
                              width: 190.0,
                              child: Text(
                                'Proyecto: ${widget.evidencia.inventario.proyecto.proyecto}',
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Tooltip(
                            message:
                                'Registro: ${widget.evidencia.inventario.folio}',
                            child: Container(
                              width: 190.0,
                              child: Text(
                                'Registro: ${widget.evidencia.inventario.folio}',
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'Nombre: ${widget.evidencia.nombrefoto}',
                            child: Container(
                              width: 190.0,
                              child: Text(
                                'Nombre: ${widget.evidencia.nombrefoto}',
                                style: TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
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

  List<Widget> _tipoComponente() {
    List<Widget> respuesta = [];
    switch (widget.tipoComponente) {
      case 'MARCAR':
        respuesta.add(Positioned(
          right: 165.0,
          bottom: 165,
          child: CircleAvatar(
            backgroundColor: Colors.blue[300],
          ),
        ));
        respuesta.add(Positioned(
          child: Checkbox(
            value: widget.seleccionCheck,
            onChanged: (bool valor) {
              setState(() {
                _actualizarComponente();
              });
            },
          ),
        ));
        return respuesta;
        break;
      case 'ELIMINAR':
        respuesta.add(Positioned(
          // left: 165.0,
          // bottom: 165,
          right: 0,
          top: 0,
          child: CircleAvatar(
            backgroundColor: Colors.red[300],
          ),
        ));
        respuesta.add(Positioned(
          right: 0,
          child: IconButton(
              onPressed: () {
                _evidenciaSeleccionada.remove(widget.evidencia);
              },
              icon: Icon(
                Icons.delete_forever,
                color: Colors.white,
              )),
        ));

        return respuesta;
        break;
      default:
        return respuesta;
        break;
    }
  }

  void _vistaPreviaImagen() async {
    if (widget.evidencia.nombrefoto.contains('.pdf')) {
      html.window.open(widget.evidencia.url, 'new tab');
    } else {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) => VistaPreviaFoto(
          urlImagen: widget.evidencia.url,
        ),
      );
    }
  }

  void _actualizarComponente() {
    if (widget.tipoComponente == 'MARCAR') {
      widget.seleccionCheck = !widget.seleccionCheck;
      if (widget.seleccionCheck) {
        _evidenciaSeleccionada.add(widget.evidencia);
      } else {
        _evidenciaSeleccionada.remove(widget.evidencia);
      }
    } else {
      _vistaPreviaImagen();
    }
  }
}
