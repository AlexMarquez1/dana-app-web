import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:checkbox_formfield/checkbox_list_tile_formfield.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/Catalogo.dart';
import '../../models/Proyecto.dart';
import '../../services/APIWebService/ApiDefinitions.dart';
import '../../services/APIWebService/Consultas.dart';
import '../../utils/UpperCaseTextFormatterCustom.dart';
import 'dart:ui' as ui;

import 'DetallesImagenEvidencia.dart';
import 'Dialogos.dart';

class TipoDeCampos extends StatelessWidget {
  int indAgrupacion;
  int indCampo;
  Proyecto proyecto;
  StateSetter actualizar;

  TipoDeCampos(
      {Key key,
      @required this.indAgrupacion,
      @required this.indCampo,
      @required this.proyecto,
      @required this.actualizar})
      : super(key: key);

  ScrollController _scrollEvidencia = ScrollController();

  RegistroProvider _registroProvider;
  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
    return _tipoDeComponente(context);
  }

  Widget _tipoDeComponente(BuildContext context) {
    String caracteresPermitidos = _registroProvider.listaAgrupaciones
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
    switch (_registroProvider.listaAgrupaciones
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .tipoCampo) {
      case 'ALFANUMERICO':
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            readOnly:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            enableInteractiveSelection:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? true : false,
            controller: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              _registroProvider.listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo ==
                      'FOLIO'
                  ? FilteringTextInputFormatter.singleLineFormatter
                  : FilteringTextInputFormatter.allow(
                      RegExp('[a-z A-Z 0-9˜ñÑ $caracteresPermitidos]')),
              // UpperCaseTextFormatter(),
            ],
            maxLength: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
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
            readOnly:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            enableInteractiveSelection:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? true : false,
            controller: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp('[a-z A-Z˜ñÑ $caracteresPermitidos]')),
              UpperCaseTextFormatter(),
            ],
            maxLength: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
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
            readOnly:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            enableInteractiveSelection:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? true : false,
            controller: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo),
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
            readOnly:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            enableInteractiveSelection:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? true : false,
            controller: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp('[0-9 $caracteresPermitidos]')),
            ],
            maxLength: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;

      case 'CATALOGO-INPUT':
        return SizedBox(
          width: 250.0,
          child: IgnorePointer(
            ignoring:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            child: Autocomplete<String>(
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                fieldTextEditingController.text = _registroProvider
                    .listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text;
                return TextFormField(
                  readOnly: VariablesGlobales.usuario.perfil.idperfil != 4
                      ? false
                      : true,
                  enableInteractiveSelection:
                      VariablesGlobales.usuario.perfil.idperfil != 4
                          ? true
                          : false,
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white,
                    hintText: _registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo,
                  ),
                  onChanged: (value) {
                    TextEditingValue(
                      text: value.toUpperCase(),
                      selection: fieldTextEditingController.selection,
                    );
                    _registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .valorController = fieldTextEditingController;
                  },
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp('[a-z A-Z˜ñÑ $caracteresPermitidos]')),
                    UpperCaseTextFormatter(),
                  ],
                  validator: (value) {
                    if (value.isNotEmpty) {
                      return null;
                    } else {
                      return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
                    }
                  },
                );
              },
              optionsBuilder: (TextEditingValue value) {
                // When the field is empty
                if (value.text.isEmpty) {
                  return [];
                } else {
                  // The logic to find out which ones should appear
                  if (_registroProvider
                          .catalogos[_registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo]
                          .catalogo !=
                      null) {
                    return _registroProvider
                        .catalogos[_registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo]
                        .catalogo
                        .where((suggestion) => suggestion
                            .toUpperCase()
                            .contains(value.text.toUpperCase()));
                  } else {
                    return [];
                  }
                }
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelect,
                  Iterable<String> option) {
                if (option.isNotEmpty) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        width: 250.0,
                        height: 150.0,
                        // color: Colors.white,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue),
                            right: BorderSide(color: Colors.blue),
                            bottom: BorderSide(color: Colors.blue),
                          ),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.all(5.0),
                          itemCount: option.length,
                          itemBuilder: (BuildContext context, int ind) {
                            final opt = option.elementAt(ind);
                            return InkWell(
                              onTap: () {
                                onSelect(opt);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  height: 30.0,
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 200,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
              onSelected: (value) {
                _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text = value;
                actualizar(() {
                  TextEditingValue(
                    text: value.toUpperCase(),
                    selection: _registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .valorController
                        .selection,
                  );
                });
              },
            ),
          ),
        );
        break;

      case 'CATALOGO':
        print('Catalogo');
        if (!_registroProvider
            .catalogos[_registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .nombreCampo]
            .catalogo
            .contains(_registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController
                .text)) {
          _registroProvider
              .catalogos[_registroProvider.listaAgrupaciones
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .nombreCampo]
              .catalogo
              .add(_registroProvider.listaAgrupaciones
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .valorController
                  .text);
        }
        if (_registroProvider.listaAgrupaciones
            .elementAt(indAgrupacion)
            .campos
            .elementAt(indCampo)
            .valorController
            .text
            .isEmpty) {
          if (_registroProvider.listaAgrupaciones
              .elementAt(indAgrupacion)
              .campos
              .elementAt(indCampo)
              .restriccion
              .contains('CAT')) {
            _registroProvider.catalogos[_registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .restriccion
                    .split(',')[1]] =
                Catalogo(
                    catalogo: [],
                    proyecto: proyecto,
                    tipoCatalogo: _registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo);
          }
        }

        return Container(
          width: 250.0,
          child: IgnorePointer(
            ignoring:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                hintText: _registroProvider.listaAgrupaciones
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
              value: _registroProvider.listaAgrupaciones
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .valorController
                      .text
                      .isEmpty
                  ? null
                  : _registroProvider.listaAgrupaciones
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .valorController
                      .text,
              onChanged: (valor) async {
                PantallaDeCarga.loadingI(context, true);
                if (_registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .restriccion !=
                    '[N/A]') {
                  Catalogo catalogoRespuesta =
                      await obtenerDatosCatalogoCamposProyectoRelacionado(
                          ApiDefinition.ipServer,
                          proyecto,
                          _registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .restriccion
                              .split(',')[1],
                          valor);

                  for (int i = 0;
                      i <
                          _registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .length;
                      i++) {
                    if (_registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(i)
                            .nombreCampo ==
                        _registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .restriccion
                            .split(',')[1]) {
                      if (catalogoRespuesta != null) {
                        print(
                            'Ingresando este dato: ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).valorController.text}');
                        //TODO: Erreglar error :(
                        if (!catalogoRespuesta.catalogo.contains(
                                _registroProvider.listaAgrupaciones
                                    .elementAt(indAgrupacion)
                                    .campos
                                    .elementAt(i)
                                    .valorController
                                    .text) &&
                            _registroProvider.listaAgrupaciones
                                .elementAt(indAgrupacion)
                                .campos
                                .elementAt(i)
                                .valorController
                                .text
                                .isEmpty) {
                          _registroProvider.actualizarValor(
                              indAgrupacion, i, '');
                          catalogoRespuesta.catalogo.add(_registroProvider
                                  .listaAgrupaciones
                                  .elementAt(indAgrupacion)
                                  .campos
                                  .elementAt(indCampo)
                                  .valorController
                                  .text
                                  .isEmpty
                              ? ''
                              : _registroProvider.listaAgrupaciones
                                  .elementAt(indAgrupacion)
                                  .campos
                                  .elementAt(i)
                                  .valorController
                                  .text);
                        }
                        _registroProvider.actualizarCatalogos(
                            _registroProvider.listaAgrupaciones
                                .elementAt(indAgrupacion)
                                .campos
                                .elementAt(indCampo)
                                .restriccion
                                .split(',')[1],
                            catalogoRespuesta);
                      }

                      print(
                          'Campo : ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}');
                      print(
                          'Eliminar dato de : ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).valorController.text}');
                      // _registroProvider.listaAgrupaciones
                      //     .elementAt(indAgrupacion)
                      //     .campos
                      //     .elementAt(i)
                      //     .valorController
                      //     .text = '';

                      break;
                      // _registroProvider.listaAgrupaciones
                      //     .elementAt(indAgrupacion)
                      //     .campos
                      //     .elementAt(i)
                      //     .valorController = new TextEditingController();
                    }
                  }
                }
                _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text = valor;
                print(_registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .valorController
                    .text);
                // actualizar(() {

                // });

                PantallaDeCarga.loadingI(context, false);
              },
              items: _registroProvider
                          .catalogos[_registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo]
                          .catalogo !=
                      null
                  ? _registroProvider
                      .catalogos[_registroProvider.listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo]
                      .catalogo
                      .map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                        ),
                      );
                    }).toList()
                  : [],
            ),
          ),
        );
        break;
      case 'FIRMA':
        return Container(
          width: 250.0,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10.0),
                width: 130.0,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter state) {
                  return IgnorePointer(
                    ignoring: VariablesGlobales.usuario.perfil.idperfil != 4
                        ? false
                        : true,
                    child: ElevatedButton(
                      onPressed: () async {
                        String datos = await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 3),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                title: Container(
                                    child: Text(_registroProvider
                                        .listaAgrupaciones
                                        .elementAt(indAgrupacion)
                                        .campos
                                        .elementAt(indCampo)
                                        .nombreCampo)),
                                children: <Widget>[
                                  Center(
                                    child: Container(
                                      color: Colors.grey[300],
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 500.0,
                                      child: Signature(
                                        color: Colors.black,
                                        strokeWidth: 5.0,
                                        backgroundPainter: null,
                                        onSign: () {
                                          state(() {
                                            final sing = _registroProvider
                                                .keyFirma[_registroProvider
                                                    .listaAgrupaciones
                                                    .elementAt(indAgrupacion)
                                                    .campos
                                                    .elementAt(indCampo)
                                                    .nombreCampo]
                                                .currentState;
                                            //print(sing.points.length);
                                          });
                                        },
                                        key: _registroProvider.keyFirma[
                                            _registroProvider.listaAgrupaciones
                                                .elementAt(indAgrupacion)
                                                .campos
                                                .elementAt(indCampo)
                                                .nombreCampo],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(
                                          top: 10.0, left: 10.0),
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              final sing = _registroProvider
                                                  .keyFirma[_registroProvider
                                                      .listaAgrupaciones
                                                      .elementAt(indAgrupacion)
                                                      .campos
                                                      .elementAt(indCampo)
                                                      .nombreCampo]
                                                  .currentState;
                                              sing.clear();
                                              state(() {
                                                _registroProvider.firmas[
                                                        _registroProvider
                                                            .listaAgrupaciones
                                                            .elementAt(
                                                                indAgrupacion)
                                                            .campos
                                                            .elementAt(indCampo)
                                                            .nombreCampo] =
                                                    ByteData(0);
                                              });
                                            },
                                            child: Text('Borrar'),
                                          ),
                                          SizedBox(
                                            width: 25.0,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final sing = _registroProvider
                                                  .keyFirma[_registroProvider
                                                      .listaAgrupaciones
                                                      .elementAt(indAgrupacion)
                                                      .campos
                                                      .elementAt(indCampo)
                                                      .nombreCampo]
                                                  .currentState;
                                              final imagen =
                                                  await sing.getData();
                                              var data =
                                                  await imagen.toByteData(
                                                      format: ui
                                                          .ImageByteFormat.png);
                                              sing.clear();
                                              final encoded = base64.encode(
                                                  data.buffer.asUint8List());
                                              state(() {
                                                _registroProvider.firmas[
                                                    _registroProvider
                                                        .listaAgrupaciones
                                                        .elementAt(
                                                            indAgrupacion)
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
                                              Navigator.of(context)
                                                  .pop('cancelado');
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
                          _registroProvider.comprobarFirmasActualizarDato(
                              _registroProvider.listaAgrupaciones
                                  .elementAt(indAgrupacion)
                                  .campos
                                  .elementAt(indCampo)
                                  .nombreCampo,
                              true);
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
                  );
                }),
              ),
              SizedBox(
                width: 10.0,
              ),
              IconButton(
                  onPressed: () async {
                    if (!_registroProvider.comprobarFirmas[_registroProvider
                        .listaAgrupaciones
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
                                  side:
                                      BorderSide(color: Colors.white, width: 3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              title: Container(
                                  child: Text(_registroProvider
                                      .listaAgrupaciones
                                      .elementAt(indAgrupacion)
                                      .campos
                                      .elementAt(indCampo)
                                      .nombreCampo)),
                              children: <Widget>[
                                Center(
                                  child: Container(
                                      //color: Colors.grey[300],
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 500.0,
                                      child: LimitedBox(
                                          maxHeight: 200.0,
                                          child: Image.memory(_registroProvider
                                              .firmas[_registroProvider
                                                  .listaAgrupaciones
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
                                                'Quieres eliminar la firma?',
                                                () {
                                              _registroProvider
                                                  .comprobarFirmasActualizarDato(
                                                      _registroProvider
                                                          .listaAgrupaciones
                                                          .elementAt(
                                                              indAgrupacion)
                                                          .campos
                                                          .elementAt(indCampo)
                                                          .nombreCampo,
                                                      false);
                                              _registroProvider.firmas[
                                                  _registroProvider
                                                      .listaAgrupaciones
                                                      .elementAt(indAgrupacion)
                                                      .campos
                                                      .elementAt(indCampo)
                                                      .nombreCampo] = ByteData(
                                                  0);
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
              _registroProvider.comprobarFirmas[_registroProvider
                      .listaAgrupaciones
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .nombreCampo]
                  ? Icon(Icons.check_circle_outline, color: Colors.green)
                  : Icon(Icons.cancel_outlined, color: Colors.red),
            ],
          ),
        );
        break;
      case 'FOTO':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              child: Container(
                child: Row(
                  children: [
                    Icon(Icons.camera_alt_outlined),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('Subir Evidencia'),
                    SizedBox(
                      width: 10.0,
                    ),
                    _registroProvider.comprobarFotos[_registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo]
                        ? Icon(Icons.check_circle_outline, color: Colors.green)
                        : Icon(Icons.cancel_outlined, color: Colors.red),
                    SizedBox(
                      width: 10.0,
                    ),
                    IgnorePointer(
                      ignoring: VariablesGlobales.usuario.perfil.idperfil != 4
                          ? false
                          : true,
                      child: IconButton(
                          onPressed: () async {
                            if (_registroProvider
                                    .evidencia[_registroProvider
                                        .listaAgrupaciones
                                        .elementAt(indAgrupacion)
                                        .campos
                                        .elementAt(indCampo)
                                        .nombreCampo]
                                    .length !=
                                0) {
                              String datos = await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.white, width: 3),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      title: Container(
                                          child: Text(_registroProvider
                                              .listaAgrupaciones
                                              .elementAt(indAgrupacion)
                                              .campos
                                              .elementAt(indCampo)
                                              .nombreCampo)),
                                      children: <Widget>[
                                        Center(
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            height: 500.0,
                                            child: Image.memory(
                                                _registroProvider.evidencia[
                                                    _registroProvider
                                                        .listaAgrupaciones
                                                        .elementAt(
                                                            indAgrupacion)
                                                        .campos
                                                        .elementAt(indCampo)
                                                        .nombreCampo]),
                                          ),
                                        ),
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: 10.0, left: 10.0),
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Dialogos.advertencia(
                                                        context,
                                                        'Seguro que quieres eliminar la imagen?',
                                                        () {
                                                      _registroProvider
                                                              .evidencia[
                                                          _registroProvider
                                                              .listaAgrupaciones
                                                              .elementAt(
                                                                  indAgrupacion)
                                                              .campos
                                                              .elementAt(
                                                                  indCampo)
                                                              .nombreCampo] = Uint8List(
                                                          0);
                                                      _registroProvider
                                                              .comprobarFotos[
                                                          _registroProvider
                                                              .listaAgrupaciones
                                                              .elementAt(
                                                                  indAgrupacion)
                                                              .campos
                                                              .elementAt(
                                                                  indCampo)
                                                              .nombreCampo] = false;
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop('borrado');
                                                    });
                                                  },
                                                  child: Text('Borrar'),
                                                ),
                                                SizedBox(
                                                  width: 25.0,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop('cancelado');
                                                  },
                                                  child: Text('Cancelar'),
                                                ),
                                              ],
                                            )),
                                      ],
                                    );
                                  });
                              print('Datos: $datos');
                              if (datos == 'borrado') {
                                actualizar(() {});
                              }
                            } else {
                              Dialogos.mensaje(
                                  context, 'No se a subido ninguna evidencia');
                            }
                          },
                          icon: Icon(Icons.image)),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                FilePickerResult result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'png'],
                );
                if (result != null) {
                  print('Imagen seleccionada');
                  PlatformFile lectura = result.files.first;
                  Uint8List fileBytes;
                  String fileName;
                  if (result.files.first.bytes == null) {
                    File archivo = new File(lectura.path);
                    fileBytes = await archivo.readAsBytes();
                    fileName = lectura.name;
                  } else {
                    fileBytes = lectura.bytes;
                    fileName = lectura.name;
                  }
                  actualizar(() {
                    _registroProvider.evidencia[_registroProvider
                        .listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo] = fileBytes;
                    _registroProvider.comprobarFotos[_registroProvider
                        .listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo] = true;
                  });
                } else {
                  print('Operacion cancelada');
                }
              },
            ),
            Container(
              //margin: EdgeInsets.only(left: 10.0),
              width: 250.0,
              child: TextFormField(
                controller: _registroProvider.listaAgrupaciones
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
                  _registroProvider.listaAgrupaciones
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
                maxLength: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .longitud,
                validator: (value) {
                  if (value.isNotEmpty) {
                    return null;
                  } else {
                    return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
                  }
                },
              ),
            ),
          ],
        );
        break;
      case 'CALENDARIO':
        return IgnorePointer(
          ignoring:
              VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
          child: Container(
              margin: EdgeInsets.only(left: 10.0),
              width: 250.0,
              child: InkWell(
                onTap: () async {
                  print(
                      'Fecha actual: ${_registroProvider.camposCalendario[_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo]}');
                  final DateTime picked = await showDatePicker(
                      locale: Locale('es', 'ES'),
                      context: context,
                      initialDate: _registroProvider.camposCalendario[
                          _registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo],
                      firstDate: new DateTime(2000),
                      lastDate: new DateTime(2040));
                  if (picked != null) {
                    _registroProvider.actualizarCampoCalendario(
                        _registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo,
                        picked);
                    _registroProvider.actualizarValor(indAgrupacion, indCampo,
                        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}");
                    // actualizar(() {});
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        '${DateFormat.yMMMd().format(_registroProvider.camposCalendario[_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo])}',
                      ),
                      Icon(Icons.arrow_drop_down,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade700
                                  : Colors.white70),
                    ],
                  ),
                ),
              )),
        );
        break;
      case 'HORA':
        return IgnorePointer(
          ignoring:
              VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
          child: Container(
              margin: const EdgeInsets.only(left: 10.0),
              width: 250.0,
              child: InkWell(
                onTap: () async {
                  print(
                      'Hora actual: ${_registroProvider.camposHora[_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo]}');
                  final TimeOfDay picked = await showTimePicker(
                    initialTime: _registroProvider.camposHora[_registroProvider
                        .listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo],
                    context: context,
                  );
                  if (picked != null) {
                    String hora =
                        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0').replaceAll(' ', '')}";

                    print('Hora Seleccionada: $hora');
                    _registroProvider.actualizarCampoHorao(
                        _registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo,
                        picked);
                    _registroProvider.actualizarValor(
                        indAgrupacion, indCampo, hora);
                  }
                  // actualizar(() {});
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "${_registroProvider.camposHora[_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo].hour.toString().padLeft(2, '0')}:${_registroProvider.camposHora[_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo].minute.toString().padLeft(2, '0')}",
                      ),
                      Icon(Icons.arrow_drop_down,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade700
                                  : Colors.white70),
                    ],
                  ),
                ),
              )),
        );
        break;
      case 'CHECKBOX':
        return IgnorePointer(
          ignoring:
              VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            width: 250.0,
            child: CheckboxListTileFormField(
              initialValue: _registroProvider.checkBox[_registroProvider
                  .listaAgrupaciones
                  .elementAt(indAgrupacion)
                  .campos
                  .elementAt(indCampo)
                  .nombreCampo],
              onSaved: (valor) {
                _registroProvider.checkBox[_registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo] = valor;
                if (_registroProvider.checkBox[_registroProvider
                    .listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo]) {
                  _registroProvider.listaAgrupaciones
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .valorController
                      .text = 'true';
                } else {
                  _registroProvider.listaAgrupaciones
                      .elementAt(indAgrupacion)
                      .campos
                      .elementAt(indCampo)
                      .valorController
                      .text = 'false';
                }
              },
              validator: (valor) {
                if (valor) {
                  return null;
                } else {
                  return 'NECESITAS MARCAR ESTE CAMPO';
                }
              },
            ),
          ),
        );
        break;
      case 'CHECKBOX-EVIDENCIA':
        return Center(
          child: SizedBox(
            width: 170.0,
            child: IgnorePointer(
              ignoring: VariablesGlobales.usuario.perfil.idperfil != "4"
                  ? false
                  : true,
              child: ElevatedButton(
                  onPressed: () async {
                    Map<String, Uint8List> datosAnteriores =
                        <String, Uint8List>{};
                    Map<String, Map<String, Uint8List>> argumentos =
                        <String, Map<String, Uint8List>>{};
                    argumentos['evidencias'] =
                        _registroProvider.evidenciaCheckList[_registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo];

                    _registroProvider.evidenciaCheckList[_registroProvider
                            .listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo]
                        .forEach((key, value) {
                      datosAnteriores[key] = value;
                    });

                    _registroProvider.evidenciaCheckList[
                        _registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo] = await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, state) {
                              return SimpleDialog(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 3),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                title: Row(
                                  children: [
                                    Text('Evidencia'),
                                    Expanded(child: Container()),
                                    ElevatedButton(
                                        onPressed: () async {
                                          FilePickerResult result =
                                              await FilePicker.platform
                                                  .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: [
                                              'jpg',
                                              'jpeg',
                                              'png',
                                              'pdf',
                                            ],
                                            allowMultiple: true,
                                          );
                                          state(() {
                                            if (result != null) {
                                              result.files.forEach((element) {
                                                argumentos['evidencias']
                                                        [element.name] =
                                                    element.bytes;
                                              });
                                            }
                                          });
                                        },
                                        child: Text('Subir evidencia')),
                                  ],
                                ),
                                children: [
                                  Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 500.0,
                                      child: SingleChildScrollView(
                                        controller: _scrollEvidencia,
                                        child: Wrap(
                                          runSpacing: 10.0,
                                          children: [
                                            _dropTarget(
                                              context,
                                              state,
                                              argumentos['evidencias'],
                                              null,
                                              false,
                                            ),
                                            // for (Uint8List item
                                            //     in argumentos['evidencias']
                                            //         .values)
                                            //   DetallesImagenEvidencia(
                                            //       evidencia: item,
                                            //       nombreEvidencia:
                                            //           'nombreEvidencia',
                                            //       anchoImagen: 200,
                                            //       altoImagen: 250)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.only(
                                          top: 10.0, left: 10.0),
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context,
                                                  argumentos['evidencias']);
                                            },
                                            child: Text('Aceptar'),
                                          ),
                                          SizedBox(
                                            width: 25.0,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, datosAnteriores);
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                        ],
                                      )),
                                ],
                              );
                            },
                          );
                        });

                    if (_registroProvider
                        .evidenciaCheckList[_registroProvider.listaAgrupaciones
                            .elementAt(indAgrupacion)
                            .campos
                            .elementAt(indCampo)
                            .nombreCampo]
                        .isNotEmpty) {
                      _registroProvider.comprobarEvidenciaCheck[
                          _registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo] = true;
                      _registroProvider.checkBoxEvidencia[_registroProvider
                          .listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo] = true;
                      _registroProvider.listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .valorController
                          .text = 'TRUE';
                    } else {
                      _registroProvider.comprobarEvidenciaCheck[
                          _registroProvider.listaAgrupaciones
                              .elementAt(indAgrupacion)
                              .campos
                              .elementAt(indCampo)
                              .nombreCampo] = false;
                      _registroProvider.checkBoxEvidencia[_registroProvider
                          .listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo] = false;
                      _registroProvider.listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .valorController
                          .text = 'FALSE';
                    }
                    actualizar(() {});
                  },
                  child: Row(
                    children: [
                      const Text('Subir Evidencia'),
                      SizedBox(
                        width: 10.0,
                      ),
                      _registroProvider.comprobarEvidenciaCheck[
                              _registroProvider.listaAgrupaciones
                                  .elementAt(indAgrupacion)
                                  .campos
                                  .elementAt(indCampo)
                                  .nombreCampo]
                          ? const Icon(Icons.check_circle_outline,
                              color: Colors.white)
                          : const Icon(Icons.cancel_outlined,
                              color: Colors.red),
                    ],
                  )),
            ),
          ),
        );
        break;
      default:
        return Container(
          //margin: EdgeInsets.only(left: 10.0),
          width: 250.0,
          child: TextFormField(
            readOnly:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? false : true,
            enableInteractiveSelection:
                VariablesGlobales.usuario.perfil.idperfil != "4" ? true : false,
            enabled: _registroProvider.listaAgrupaciones
                        .elementAt(indAgrupacion)
                        .campos
                        .elementAt(indCampo)
                        .nombreCampo ==
                    'FOLIO'
                ? false
                : true,
            controller: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .valorController,
            decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                hintText: _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos
                    .elementAt(indCampo)
                    .nombreCampo),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              _registroProvider.listaAgrupaciones
                          .elementAt(indAgrupacion)
                          .campos
                          .elementAt(indCampo)
                          .nombreCampo ==
                      'FOLIO'
                  ? FilteringTextInputFormatter.singleLineFormatter
                  : FilteringTextInputFormatter.allow(
                      RegExp('[a-z A-Z 0-9˜ñÑ $caracteresPermitidos]')),
              UpperCaseTextFormatter(),
            ],
            maxLength: _registroProvider.listaAgrupaciones
                .elementAt(indAgrupacion)
                .campos
                .elementAt(indCampo)
                .longitud,
            validator: (value) {
              if (value.isNotEmpty) {
                return null;
              } else {
                return 'INGRESE DATOS A ${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(indCampo).nombreCampo}';
              }
            },
          ),
        );
        break;
    }
  }

  Widget _dropTarget(BuildContext context, StateSetter state,
      Map<String, Uint8List> evidencia, Offset offset, bool dragging) {
    return DropTarget(
      onDragDone: (detail) async {
        for (int i = 0; i < detail.files.length; i++) {
          evidencia[detail.files.elementAt(i).name.split('.')[0]] =
              await detail.files.elementAt(i).readAsBytes();
        }
        state(() {});
      },
      onDragUpdated: (details) {
        state(() {
          offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        state(() {
          dragging = true;
          offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        state(() {
          dragging = false;
          offset = null;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width * 0.5,
        color: dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        child: Wrap(
          children: [
            if (evidencia.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text("Arrastra la evidencia que quieras subir aqui!"),
              ))
            else
              for (String item in evidencia.keys)
                DetallesImagenEvidencia(
                  evidencia: evidencia[item],
                  nombreEvidencia: item,
                  anchoImagen: 180,
                  altoImagen: 230,
                  eliminar: () {
                    state(() {
                      evidencia.remove(item);
                    });
                  },
                ),
          ],
        ),
      ),
    );
  }
}
