import 'dart:convert';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/models/Catalogo.dart';
import 'package:app_isae_desarrollo/src/models/FirmaDocumento.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/ValoresCampos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;

class RegistrosDataTable extends DataTableSource {
  final _formKeyRegistro = GlobalKey<FormState>();
  List<Inventario> _listaRegistro;
  BuildContext context;
  List<Agrupaciones> _listaAgrupacionesObtenidas = [];
  Inventario _registroSeleccionado;

  Map<String, Catalogo> _catalogos = new Map<String, Catalogo>();
  Map<String, bool> _comprobarFirma = new Map<String, bool>();
  Map<String, ByteData> _firma = new Map<String, ByteData>();
  Map<String, GlobalKey<SignatureState>> _keyFirma =
      new Map<String, GlobalKey<SignatureState>>();

  RegistrosDataTable({@required List<Inventario> listaRegistro, this.context})
      : _listaRegistro = listaRegistro,
        assert(listaRegistro != null);

  @override
  DataRow getRow(int index) {
    final registro = _listaRegistro.elementAt(index);
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (seleccion) async {
        _registroSeleccionado = registro;
        PantallaDeCarga.loadingI(context, true);
        _listaAgrupacionesObtenidas = await obtenerDatosCamposRegistro(
            ApiDefinition.ipServer,
            registro.proyecto.idproyecto,
            registro.idinventario);
        _catalogos = await obtenerCatalogosProyecto(
            ApiDefinition.ipServer, registro.proyecto);
        TextEditingController valor = TextEditingController();
        valor.text = 'PRUEBA';

        for (int i = 0; i < _listaAgrupacionesObtenidas.length; i++) {
          for (int j = 0;
              j < _listaAgrupacionesObtenidas.elementAt(i).campos.length;
              j++) {
            if (_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .tipoCampo ==
                'FIRMA') {
              List<FirmaDocumento> firma = [];
              if (firma.isEmpty) {
                _comprobarFirma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = false;
                _keyFirma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = GlobalKey<SignatureState>();
                _firma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = ByteData(0);
              } else {
                _comprobarFirma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = true;
                _keyFirma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = GlobalKey<SignatureState>();
                _firma[_listaAgrupacionesObtenidas
                    .elementAt(i)
                    .campos
                    .elementAt(j)
                    .nombreCampo] = ByteData(0);
              }
            }

            TextEditingController aux = TextEditingController();
            aux.text = _listaAgrupacionesObtenidas
                .elementAt(i)
                .campos
                .elementAt(j)
                .valor;
            _listaAgrupacionesObtenidas
                .elementAt(i)
                .campos
                .elementAt(j)
                .valorController = aux;

            _listaAgrupacionesObtenidas
                .elementAt(i)
                .campos
                .elementAt(j)
                .controladorLongitud = new TextEditingController();
            _listaAgrupacionesObtenidas
                .elementAt(i)
                .campos
                .elementAt(j)
                .controladorNombreCampo = new TextEditingController();
            _listaAgrupacionesObtenidas
                .elementAt(i)
                .campos
                .elementAt(j)
                .controladorRestriccion = new TextEditingController();
          }
        }
        PantallaDeCarga.loadingI(context, false);
        _mostrarCampos(registro.proyecto);
      },
      cells: <DataCell>[
        DataCell(Text(registro.proyecto.proyecto)),
        DataCell(Text(registro.folio)),
        DataCell(Text(registro.estatus)),
        DataCell(Text(registro.fechacreacion)),
        DataCell(IconButton(
          onPressed: () async {
            if (registro.estatus != 'CERRADO') {
              Dialogos.advertencia(context,
                  'El registro no se encuentra cerrado quieres generar el PDF?',
                  () async {
                PantallaDeCarga.loadingI(context, true);
                _listaAgrupacionesObtenidas = await obtenerDatosCamposRegistro(
                    ApiDefinition.ipServer,
                    registro.proyecto.idproyecto,
                    registro.idinventario);
                Uint8List bytes = await obtenerPdf(ApiDefinition.ipServer,
                    _listaAgrupacionesObtenidas, registro.idinventario);

                final blob = html.Blob([bytes], 'application/pdf');
                final url = html.Url.createObjectUrlFromBlob(blob);
                html.window.open(url, '_blank');
                html.Url.revokeObjectUrl(url);
                PantallaDeCarga.loadingI(context, false);
                Navigator.of(context).pop();
              });
            } else {
              String urlDocumento = await obtenerUrlDocumento(
                  ApiDefinition.ipServer, registro.idinventario);

              html.window.open(urlDocumento, 'new tab');
            }
          },
          icon: Icon(Icons.picture_as_pdf_rounded),
        )),
      ],
    );
  }

  _mostrarCampos(Proyecto proyecto) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
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
                  Container(child: Text('PROYECTO: ${proyecto.proyecto}')),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close))
                ],
              ),
            ),
            children: <Widget>[
              Center(
                child: size.width > 700
                    ? StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                        return _cargarCampos('columna', proyecto, setState);
                      })
                    : StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                        return _cargarCampos('fila', proyecto, setState);
                      }),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 10.0, right: 10.0),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            List<ValoresCampos> valores = [];
                            for (Agrupaciones agrupaciones
                                in _listaAgrupacionesObtenidas) {
                              for (Campos item in agrupaciones.campos) {
                                valores.add(ValoresCampos(
                                  valor: item.valorController.text,
                                  idcampoproyecto: item.idCampo,
                                  idinventario:
                                      _registroSeleccionado.idinventario,
                                ));
                              }
                            }
                            Dialogos.advertencia(context,
                                'Seguro que quieres guardar los cambios?',
                                () async {
                              PantallaDeCarga.loadingI(context, true);
                              await actualizarValoresCampos(
                                  ApiDefinition.ipServer, valores);
                              PantallaDeCarga.loadingI(context, false);
                              Navigator.pop(context);
                            });
                          },
                          child: Text('Aceptar'),
                        )),
                    Container(
                        padding: EdgeInsets.only(top: 10.0, right: 10.0),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar'),
                        )),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _cargarCampos(
      String orientacion, Proyecto proyecto, StateSetter actualizar) {
    return Form(
      key: _formKeyRegistro,
      child: Container(
        width: orientacion == 'columna'
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        child: ListView.builder(
          itemCount: _listaAgrupacionesObtenidas.length,
          itemBuilder: (BuildContext context, int index) {
            print(_listaAgrupacionesObtenidas.elementAt(index).agrupacion);
            return Card(
              //color: Color.fromRGBO(36, 90, 149, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 2,
              margin: EdgeInsets.all(15.0),
              child: ExpansionTile(
                maintainState: true,
                onExpansionChanged: (condicion) {
                  if (condicion) {
                  } else {}
                  //setState(() {});
                },
                title: _buildTitle(
                    '${_listaAgrupacionesObtenidas.elementAt(index).agrupacion}'),
                trailing: SizedBox(),
                children: <Widget>[
                  orientacion == 'fila'
                      ? Container(
                          margin: EdgeInsets.all(15.0),
                          child:
                              _contruirCamposFila(index, proyecto, actualizar),
                        )
                      : _contruirCamposColumna(index, proyecto, actualizar)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _contruirCamposColumna(
      int indAgrupacion, Proyecto proyecto, StateSetter actualizar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0;
            i <
                _listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .length;
            i++)
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(
                    '${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
                _tipoDeComponente(indAgrupacion, i, proyecto, actualizar),
              ],
            ),
          ),
      ],
    );
  }

  Widget _contruirCamposFila(
      int indAgrupacion, Proyecto proyecto, StateSetter actualizar) {
    return Column(
      children: [
        for (int i = 0;
            i <
                _listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .length;
            i++)
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(
                    '${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
                SizedBox(
                  width: 10.0,
                ),
                _tipoDeComponente(indAgrupacion, i, proyecto, actualizar),
                SizedBox(
                  height: 5.0,
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(String titulo) {
    return Container(
        width: 200.0,
        child: Row(
          children: <Widget>[
            Text(
              titulo,
              overflow: TextOverflow.fade,
              maxLines: 5,
              softWrap: false,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              //textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  Widget _tipoDeComponente(int indAgrupacion, int indCampo, Proyecto proyecto,
      StateSetter actualizar) {
    String caracteresPermitidos = _listaAgrupacionesObtenidas
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .restriccion
        .replaceAll('[', '');
    caracteresPermitidos = caracteresPermitidos.replaceAll(']', '');
    if (caracteresPermitidos == 'N/A' ||
        caracteresPermitidos == 'N /A' ||
        caracteresPermitidos == 'N/ A' ||
        caracteresPermitidos == 'N / A' ||
        caracteresPermitidos == 'n/a' ||
        caracteresPermitidos == 'n/ a' ||
        caracteresPermitidos == 'n /a' ||
        caracteresPermitidos == 'n / a') {
      caracteresPermitidos = '';
    }
    switch (_listaAgrupacionesObtenidas
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .tipoCampo) {
      case 'ALFANUMERICO':
        if (_listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .nombreCampo ==
            'FOLIO') {
          print('Folio');
          print(
              'Valor del controlador de folio: ${_listaAgrupacionesObtenidas.elementAt(0).campos.elementAt(0).valor}');
        }
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            controller: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: 'Alfanumerico'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              _listaAgrupacionesObtenidas
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo ==
                      'FOLIO'
                  ? FilteringTextInputFormatter.singleLineFormatter
                  : FilteringTextInputFormatter.allow(
                      RegExp('[a-z A-Z 0-9 $caracteresPermitidos]')),
              UpperCaseTextFormatter(),
            ],
            maxLength: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;
      case 'ALFABETICO':
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            controller: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: 'Alfabetico'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[a-z A-Z]')),
              UpperCaseTextFormatter(),
            ],
            maxLength: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;
      case 'CORREO':
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            controller: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: 'Alfabetico'),
            validator: (value) {
              bool emailValid =
                  RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                      .hasMatch(value);
              if (emailValid) {
                print(value.split('@')[1]);
                return null;
              } else {
                return 'Ingresa un correo valido';
              }
            },
          ),
        );
        break;
      case 'NUMERICO':
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            controller: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: 'Numerico'),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            maxLength: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;
      case 'CATALOGO':
        if (_listaAgrupacionesObtenidas
            .elementAt(indAgrupacion)
            .campos
            .elementAt(indCampo)
            .valorController
            .text
            .isEmpty) {
          if (_listaAgrupacionesObtenidas
              .elementAt(indAgrupacion)
              .campos
              .elementAt(indCampo)
              .restriccion
              .contains('CAT')) {
            _catalogos[_listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .restriccion
                    .split(',')[1]] =
                Catalogo(
                    catalogo: [],
                    proyecto: proyecto,
                    tipoCatalogo: _listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo);
          }
        }
        print(
            'Catalogo: ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(indCampo).valorController.text}');
        if (_catalogos[_listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo]
                .catalogo ==
            null) {
          _catalogos[_listaAgrupacionesObtenidas
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .nombreCampo]
              .catalogo = [];
        }
        if (_listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController
                .text
                .isEmpty ||
            _listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text
                    .length <=
                2) {
          _listaAgrupacionesObtenidas
              .elementAt(indAgrupacion)
              .campos
              .elementAt(indCampo)
              .valorController
              .text = '';
        }
        return Container(
          width: 250.0,
          child: DropdownButtonFormField(
            decoration: InputDecoration(
              hintText: _listaAgrupacionesObtenidas
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .nombreCampo,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null) {
                return 'Selecciona una opcion';
              }
              return null;
            },
            value: _listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text
                    .isEmpty
                ? null
                : _listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text,
            onChanged: (valor) async {
              PantallaDeCarga.loadingI(context, true);
              if (_listaAgrupacionesObtenidas
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .restriccion !=
                  '[N/A]') {
                _catalogos[_listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .restriccion
                        .split(',')[1]] =
                    await obtenerDatosCatalogoCamposProyectoRelacionado(
                        ApiDefinition.ipServer,
                        proyecto,
                        _listaAgrupacionesObtenidas
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .restriccion
                            .split(',')[1],
                        valor);

                for (int i = 0;
                    i <
                        _listaAgrupacionesObtenidas
                            .elementAt(indAgrupacion)
                            .campos
                            .length;
                    i++) {
                  if (_listaAgrupacionesObtenidas
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(i)
                          .nombreCampo ==
                      _listaAgrupacionesObtenidas
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .restriccion
                          .split(',')[1]) {
                    print(
                        'Campo : ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}');
                    print(
                        'Eliminar dato de : ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(i).valorController.text}');
                    _listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(i)
                        .valorController = new TextEditingController();
                  }
                }
              }
              _listaAgrupacionesObtenidas
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .valorController
                  .text = valor;
              print(_listaAgrupacionesObtenidas
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .valorController
                  .text);
              actualizar(() {});

              PantallaDeCarga.loadingI(context, false);
            },
            items: _catalogos[_listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo] ==
                    null
                ? []
                : _catalogos[_listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo]
                    .catalogo
                    .map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
          ),
        );
        break;
      case 'FIRMA':
        return Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0),
              width: 150.0,
              child: ElevatedButton(
                onPressed: () async {
                  String datos = await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 3),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          title: Container(child: Text('Mensaje')),
                          children: <Widget>[
                            Center(
                              child: Container(
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 500.0,
                                child: Signature(
                                  color: Colors.black,
                                  strokeWidth: 5.0,
                                  backgroundPainter: null,
                                  onSign: () {
                                    final sing = _keyFirma[
                                            _listaAgrupacionesObtenidas
                                                .elementAt(indAgrupacion)
                                                .campos
                                                .elementAt(indCampo)
                                                .nombreCampo]
                                        .currentState;
                                    //print(sing.points.length);
                                  },
                                  key: _keyFirma[_listaAgrupacionesObtenidas
                                      .elementAt(indAgrupacion)
                                      .campos
                                      .elementAt(indCampo)
                                      .nombreCampo],
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(top: 10.0, left: 10.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        final sing = _keyFirma[
                                                _listaAgrupacionesObtenidas
                                                    .elementAt(indAgrupacion)
                                                    .campos
                                                    .elementAt(indCampo)
                                                    .nombreCampo]
                                            .currentState;
                                        sing.clear();
                                        actualizar(() {
                                          _firma[_listaAgrupacionesObtenidas
                                              .elementAt(indAgrupacion)
                                              .campos
                                              .elementAt(indCampo)
                                              .nombreCampo] = ByteData(0);
                                        });
                                      },
                                      child: Text('Borrar'),
                                    ),
                                    SizedBox(
                                      width: 25.0,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final sing = _keyFirma[
                                                _listaAgrupacionesObtenidas
                                                    .elementAt(indAgrupacion)
                                                    .campos
                                                    .elementAt(indCampo)
                                                    .nombreCampo]
                                            .currentState;
                                        final imagen = await sing.getData();
                                        var data = await imagen.toByteData(
                                            format: ui.ImageByteFormat.png);
                                        sing.clear();
                                        final encoded = base64
                                            .encode(data.buffer.asUint8List());
                                        actualizar(() {
                                          _firma[_listaAgrupacionesObtenidas
                                              .elementAt(indAgrupacion)
                                              .campos
                                              .elementAt(indCampo)
                                              .nombreCampo] = data;
                                        });
                                        Dialogos.advertencia(context,
                                            'Estas seguro de guardar la firma?',
                                            () {
                                          Navigator.pop(context);
                                          Navigator.of(context)
                                              .pop('respuesta');
                                        });
                                      },
                                      child: Text('Aceptar'),
                                    ),
                                    SizedBox(
                                      width: 25.0,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop('cancelado');
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                  ],
                                )),
                          ],
                        );
                      });
                  if (datos == 'respuesta') {
                    print(datos);
                    _comprobarFirma[_listaAgrupacionesObtenidas
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo] = true;
                    actualizar(() {});
                  } else {
                    print(datos);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('Firmar'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            IconButton(
                onPressed: () async {
                  if (!_comprobarFirma[_listaAgrupacionesObtenidas
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .nombreCampo]) {
                    Dialogos.error(context, 'No existe firma registrada');
                  } else {
                    await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.white, width: 3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            title: Container(child: Text('Mensaje')),
                            children: <Widget>[
                              Center(
                                child: Container(
                                    //color: Colors.grey[300],
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 500.0,
                                    child: LimitedBox(
                                        maxHeight: 200.0,
                                        child: Image.memory(_firma[
                                                _listaAgrupacionesObtenidas
                                                    .elementAt(indAgrupacion)
                                                    .campos
                                                    .elementAt(indCampo)
                                                    .nombreCampo]
                                            .buffer
                                            .asUint8List()))),
                              ),
                              Container(
                                  padding:
                                      EdgeInsets.only(top: 10.0, left: 10.0),
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Dialogos.advertencia(context,
                                              'Quieres eliminar la firma?', () {
                                            _comprobarFirma[
                                                _listaAgrupacionesObtenidas
                                                    .elementAt(indAgrupacion)
                                                    .campos
                                                    .elementAt(indCampo)
                                                    .nombreCampo] = false;
                                            _firma[_listaAgrupacionesObtenidas
                                                .elementAt(indAgrupacion)
                                                .campos
                                                .elementAt(indCampo)
                                                .nombreCampo] = ByteData(0);
                                            actualizar(() {});
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text('Borrar'),
                                      ),
                                      SizedBox(
                                        width: 25.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cerrar'),
                                      ),
                                    ],
                                  )),
                            ],
                          );
                        });
                  }
                },
                icon: Icon(Icons.image)),
            SizedBox(
              width: 10.0,
            ),
            _comprobarFirma[_listaAgrupacionesObtenidas
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo]
                ? Icon(Icons.check_circle_outline, color: Colors.green)
                : Icon(Icons.cancel_outlined, color: Colors.red),
          ],
        );
        break;
      default:
        return Container(
          margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            controller: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white
                //hintText: controlador.text),
                ),
            textCapitalization: TextCapitalization.characters,
            maxLength: _listaAgrupacionesObtenidas
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_listaAgrupacionesObtenidas.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;
    }
  }

  @override
  bool get isRowCountApproximate => throw UnimplementedError();

  @override
  int get rowCount => throw UnimplementedError();

  @override
  int get selectedRowCount => throw UnimplementedError();
}
