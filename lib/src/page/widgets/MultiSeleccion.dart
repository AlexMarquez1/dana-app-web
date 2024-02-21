import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DetallesImagen.dart';
import 'package:app_isae_desarrollo/src/providers/evidenciaSeleccionadaProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MultiSeleccion extends StatefulWidget {
  List<FotoEvidencia> listaEvidenacia;
  MultiSeleccion({
    Key? key,
    required this.listaEvidenacia,
  }) : super(key: key);

  @override
  _MultiSeleccionState createState() => _MultiSeleccionState();
}

class _MultiSeleccionState extends State<MultiSeleccion> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerSeleccionado = ScrollController();
  final ScrollController _scrollControllerVentana = ScrollController();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _urlController = TextEditingController();
  Map<int, bool> _descripcion = Map<int, bool>();
  late int conteo;
  List<DetallesImagen> _listaComponenteImagen = [];
  List<DetallesImagen> _listaComponenteImagenSeleccionado = [];
  late EvidenciaSeleccionadaProvider _evidenciaSeleccionada;
  @override
  void initState() {
    conteo = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _evidenciaSeleccionada =
        Provider.of<EvidenciaSeleccionadaProvider>(context);
    _cargarComponentes();
    return MediaQuery.of(context).size.width < 2000.0
        ? _contenidoLargo()
        : _contenidoAncho();
  }

  Widget _contenidoAncho() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Text(
                        'Evidencia disponible',
                        style: TextStyle(fontSize: 40.0),
                      )),
                  Container(
                    height: 470.0,
                    width: 700.0,
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 1.5,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.center,
                            children: _listaComponenteImagen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    child: Text(
                      'Evidencia seleccionada (${_evidenciaSeleccionada.evidenciaSeleccionada.length})',
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  Container(
                    height: 470.0,
                    width: 700.0,
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 1.5,
                      child: SingleChildScrollView(
                        controller: _scrollControllerSeleccionado,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.center,
                              children: _comprobarLista()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _agregarImagenUrl(),
        ],
      ),
    );
  }

  Widget _contenidoLargo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  'Evidencia disponible',
                  style: TextStyle(fontSize: 40.0),
                )),
            Container(
              height: 470.0,
              width: 700.0,
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 1.5,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: _listaComponenteImagen,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (DetallesImagen item in _listaComponenteImagen) {
                    print('Evidencia: ${item.evidencia.nombrefoto}');
                    print('Valores seleccion: ${item.seleccionCheck}');
                  }
                });
              },
              child: Text('Listo'),
            ),
            Container(
              padding: const EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                'Evidencia seleccionada (${_evidenciaSeleccionada.evidenciaSeleccionada.length})',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            Container(
              height: 470.0,
              width: 700.0,
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 1.5,
                child: SingleChildScrollView(
                  controller: _scrollControllerSeleccionado,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: _comprobarLista()),
                  ),
                ),
              ),
            ),
            _agregarImagenUrl(),
          ],
        ),
      ),
    );
  }

  Widget _agregarImagenUrl() {
    return Column(
      children: [
        Text(
          'Agregar imagen externa',
          style: TextStyle(fontSize: 40.0),
        ),
        SizedBox(
          height: 20.0,
        ),
        Form(
          key: _formKey,
          child: Container(
            width: 500.0,
            child: TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print('Url valido');

                            _evidenciaSeleccionada.add(FotoEvidencia(
                              idfoto: 0,
                              idCampoProyecto: 0,
                              nombrefoto: '',
                              url: _urlController.text,
                              inventario: Inventario(
                                idinventario: 0,
                                folio: '',
                                proyecto: Proyecto(
                                  idproyecto: 0,
                                  descripcion: '',
                                  proyecto: '',
                                ),
                              ),
                            ));
                            setState(() {
                              _urlController.text = '';
                            });
                          } else {
                            print('Url invalido');
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.blue,
                        )),
                    border: OutlineInputBorder(),
                    hintText: 'Url magen'),
                validator: (String? validar) {
                  String respuesta;
                  if (validar!.isEmpty) {
                    respuesta = 'Ingresa un url valido';
                  } else {
                    if (Uri.tryParse(validar)?.hasAbsolutePath ?? false) {
                      return null;
                    } else {
                      respuesta = 'Ingresa un url valido';
                    }
                  }
                  return respuesta;
                }),
          ),
        ),
      ],
    );
  }

  List<Widget> _comprobarLista() {
    List<Widget> respuesta = [];

    if (_evidenciaSeleccionada.evidenciaSeleccionada.isNotEmpty) {
      for (FotoEvidencia evidencia
          in _evidenciaSeleccionada.evidenciaSeleccionada)
        respuesta.add(DetallesImagen(
          evidencia: evidencia,
          seleccionCheck: false,
          tipoComponente: 'ELIMINAR',
          anchoImagen: 200.0,
          altoImagen: 200.0,
        ));
      return respuesta;
    } else {
      print('La lista esta Vacia');
      return respuesta;
    }
  }

  void _cargarComponentes() {
    if (_listaComponenteImagenSeleccionado.isEmpty) {
      for (FotoEvidencia evidencia
          in _evidenciaSeleccionada.evidenciaSeleccionada) {
        _listaComponenteImagenSeleccionado.add(DetallesImagen(
          evidencia: evidencia,
          seleccionCheck: true,
          tipoComponente: 'ELIMINAR',
          anchoImagen: 200.0,
          altoImagen: 200.0,
        ));
      }
    }

    if (_listaComponenteImagen.isEmpty) {
      for (FotoEvidencia evidencia in widget.listaEvidenacia) {
        if (_listaComponenteImagenSeleccionado.isNotEmpty) {
          bool seleccion = false;
          for (DetallesImagen item in _listaComponenteImagenSeleccionado) {
            if (item.evidencia.idfoto == evidencia.idfoto) {
              seleccion = true;
              break;
            }
          }
          _listaComponenteImagen.add(DetallesImagen(
            evidencia: evidencia,
            seleccionCheck: seleccion,
            tipoComponente: 'MARCAR',
            anchoImagen: 200.0,
            altoImagen: 200.0,
          ));
        } else {
          _listaComponenteImagen.add(DetallesImagen(
            evidencia: evidencia,
            seleccionCheck: false,
            tipoComponente: 'MARCAR',
            anchoImagen: 200.0,
            altoImagen: 200.0,
          ));
        }
      }
    }
  }
}
