import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DatosInventario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/EditarRegistro.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/page/widgets/tipoDeCampos.dart';
import 'package:app_isae_desarrollo/src/providers/duplicadosProvider.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../models/Agrupaciones.dart';
import '../models/Campos.dart';
import '../utils/UpperCaseTextFormatterCustom.dart';

class Duplicados extends StatelessWidget {
  Duplicados({Key key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Proyecto> _listaProyectos = [];
  Map<String, List<String>> _duplicadosGlobal = {};
  GlobalKey<FormState> _formKeyRegistro = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyEliminarProyecto = GlobalKey<FormState>();
  TextEditingController _passwordEliminarProyectoController =
      TextEditingController();
  TextEditingController _controllerBusqueda = TextEditingController();
  Proyecto _proyectoSeleccionado;
  RegistroProvider _registroProvider;
  DuplicadosProvider _duplicadosProvider;
  ScrollController _scrollControllerDuplicado = ScrollController();
  ScrollController _scrollControllerDuplicadoHorizontal = ScrollController();
  ScrollController _scrollControllerEditar = ScrollController();

  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
    _duplicadosProvider =
        Provider.of<DuplicadosProvider>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      endDrawer: DrawerPrincipal(),
      body: _contenido(context),
    );
  }

  Widget _contenido(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter actualizar) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Center(
                child: Text(
                  'Duplicados'.toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            Tarjetas.tarjeta(
              size,
              _seleccionarProyecto(context, actualizar),
            ),
            _proyectoSeleccionado != null
                ? _duplicados(context, size)
                : Container()
          ],
        );
      }),
    );
  }

  Widget _seleccionarProyecto(BuildContext context, StateSetter actualizar) {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Proyecto: '),
              _listarProyectos(context, actualizar),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          _proyectoSeleccionado != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Buscar:'),
                    _autoCompletarBusqueda(),
                    ElevatedButton(
                        onPressed: () {
                          Map<String, List<String>> aux = {};
                          for (String item in _duplicadosGlobal.keys) {
                            if (item.contains(_controllerBusqueda.text)) {
                              aux[item] = _duplicadosGlobal[item];
                            }
                          }
                          _duplicadosProvider.camposDuplicados = aux;
                        },
                        child: Text('Buscar')),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _autoCompletarBusqueda() {
    return Autocomplete(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (_controllerBusqueda.text.isNotEmpty) {
          textEditingController.text = _controllerBusqueda.text;
        }
        _controllerBusqueda = textEditingController;
        return Container(
          padding: EdgeInsets.only(left: 20.0),
          width: 250.0,
          child: TextFormField(
            //enabled: _habilitarBusqueda,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una busqueda';
              } else {
                bool validacion = false;
                for (String busqueda in _duplicadosProvider.listaBusqueda) {
                  if (busqueda == value) {
                    validacion = true;
                    break;
                  }
                }
                if (validacion) {
                  return null;
                } else {
                  return 'Ingresa una busqueda valida';
                }
              }
            },
            controller: _controllerBusqueda,
            focusNode: focusNode,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Buscar'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: <TextInputFormatter>[
              UpperCaseTextFormatter(),
            ],
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return Iterable.empty();
        } else {
          if (_duplicadosProvider.listaBusqueda.isEmpty) {
            return ['Sin resultados'];
          } else {
            return _duplicadosProvider.listaBusqueda.where((String opcion) {
              return opcion.contains(textEditingValue.text.toUpperCase());
            });
          }
        }
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected onSelected, Iterable<dynamic> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 300.0,
              height: 250,
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (seleccion) {
        if (seleccion == 'Sin resultados') {
          _controllerBusqueda.text = '';
        } else {
          print('Se a seleccionado: $seleccion');
        }
      },
    );
  }

  Widget _listarProyectos(BuildContext context, StateSetter actualizar) {
    if (_listaProyectos.isEmpty) {
      return FutureBuilder(
        future: obtenerProyectos(ApiDefinition.ipServer),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            _listaProyectos = snapshot.data;
            return _dropDownProyectos(context, actualizar);
          } else {
            return SizedBox(
              width: 300.0,
              height: 10.0,
              child: LinearProgressIndicator(),
            );
          }
        },
      );
    } else {
      return _dropDownProyectos(context, actualizar);
    }
  }

  Widget _dropDownProyectos(BuildContext context, StateSetter actualizar) {
    return Container(
      padding: EdgeInsets.only(left: 20.0),
      width: 300.0,
      child: DropdownButtonFormField<Proyecto>(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Proyectos',
          hintStyle: TextStyle(),
        ),
        value: _proyectoSeleccionado,
        onChanged: (valor) async {
          _proyectoSeleccionado = valor;
          PantallaDeCarga.loadingI(context, true);
          _duplicadosProvider.camposDuplicados =
              await obtenerDuplicadosPorProyecto(
                  ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto);
          _duplicadosGlobal = _duplicadosProvider.camposDuplicados;
          List<String> respuesta = [];
          for (String item in _duplicadosProvider.camposDuplicados.keys) {
            respuesta.add(item);
          }
          _duplicadosProvider.listaBusqueda = respuesta;
          PantallaDeCarga.loadingI(context, false);
          actualizar(() {});
        },
        items: _listaProyectos.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.proyecto),
          );
        }).toList(),
        validator: (Proyecto value) {
          if (value == null) {
            return 'Selecciona un proyecto';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _duplicados(BuildContext context, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: size.height * 0.65,
          child: Tarjetas.tarjeta(
            size * 0.2,
            LayoutBuilder(builder: (context, boxConstraints) {
              return _agrupacionDuplicada(boxConstraints);
            }),
          ),
        ),
        SizedBox(
          height: size.height * 0.65,
          child: Tarjetas.tarjeta(
            size * 0.8,
            _duplicadosProvider.listaAgrupaciones.isEmpty
                ? _sinInventarioSeleccionado()
                : SingleChildScrollView(
                    controller: _scrollControllerDuplicado,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Valor duplicado: ${_duplicadosProvider.duplicadoSeleccionado}',
                          style: TextStyle(
                              color: Color.fromRGBO(36, 90, 149, 1),
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                        _datosDuplicados(
                          context,
                          _duplicadosProvider.listaAgrupaciones,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _datosDuplicados(
      BuildContext context, List<List<Agrupaciones>> agrupaciones) {
    return SingleChildScrollView(
      controller: _scrollControllerDuplicadoHorizontal,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int indRegistro = 0;
              indRegistro < agrupaciones.length;
              indRegistro++)
            DatosInventario(
              agrupaciones: agrupaciones.elementAt(indRegistro),
              indRegistro: indRegistro,
              editar: () async {
                List<List<Agrupaciones>> agrupacionDiferente = [];
                for (int i = 0;
                    i < _duplicadosProvider.listaAgrupaciones.length;
                    i++) {
                  if (i != indRegistro) {
                    agrupacionDiferente.add(
                        _duplicadosProvider.listaAgrupaciones.elementAt(i));
                  }
                }
                PantallaDeCarga.loadingI(context, true);
                await _registroProvider.obtenerRegistro(
                    Inventario(
                        idinventario: agrupaciones
                            .elementAt(indRegistro)
                            .elementAt(0)
                            .idInventario,
                        proyecto: _proyectoSeleccionado),
                    0);
                PantallaDeCarga.loadingI(context, false);

                await showMaterialModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => _modalEditar(
                      context,
                      agrupacionDiferente,
                      agrupaciones
                          .elementAt(indRegistro)
                          .elementAt(0)
                          .idInventario),
                );
              },
              eliminar: () async {
                await _confirmarEliminarRegistro(
                    context,
                    _proyectoSeleccionado,
                    agrupaciones
                        .elementAt(indRegistro)
                        .elementAt(0)
                        .idInventario,
                    agrupaciones
                        .elementAt(indRegistro)
                        .elementAt(0)
                        .campos
                        .elementAt(0)
                        .valor);
              },
            )
        ],
      ),
    );
  }

  Widget _modalEditar(BuildContext context,
      List<List<Agrupaciones>> agrupacionDiferente, int idInventario) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(right: 20.0),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          color: Color.fromRGBO(36, 90, 149, 1),
          // alignment: AlignmentDirectional.centerEnd,
          child: Row(
            children: [
              Expanded(child: Container()),
              Text(
                'Folio del registro',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Expanded(child: Container()),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: size.height - 200.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditarRegistro(
                  size: size,
                  proyecto: _proyectoSeleccionado,
                  formKeyRegistro: _formKeyRegistro,
                  usuarioSeleccionado: Usuario(0, '', '', '', '', '', '',
                      Perfil(perfil: '', idperfil: '0'), '', 0),
                  inventarioSeleccionado:
                      Inventario(idinventario: idInventario),
                  registroProvider: _registroProvider),
              Container(
                child: SingleChildScrollView(
                  controller: _scrollControllerEditar,
                  child: Row(
                    children: [
                      for (List<Agrupaciones> item in agrupacionDiferente)
                        Container(
                          // height: size.height - 100.0,
                          child: DatosInventario(
                            agrupaciones: item,
                            indRegistro: -1,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sinInventarioSeleccionado() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.web_asset_off,
                size: 100.0, color: Color.fromRGBO(36, 90, 149, 1)),
            Text(
              'No se ha seleccionado ningun registro',
              style: TextStyle(
                  color: Color.fromRGBO(36, 90, 149, 1),
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _agrupacionDuplicada(BoxConstraints boxConstraints) {
    return Container(
      height: boxConstraints.maxHeight - 10.0,
      padding: EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        itemCount: _duplicadosProvider.camposDuplicados.keys.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: _duplicadosProvider.indDuplicadoSeleccionado != index
                ? null
                : Color.fromRGBO(36, 90, 149, 1),
            child: InkWell(
              hoverColor: Color.fromRGBO(36, 90, 149, 1),
              onTap: () async {
                String duplicado =
                    _duplicadosProvider.camposDuplicados.keys.elementAt(index);
                _duplicadosProvider.indDuplicadoSeleccionado = index;
                _duplicadosProvider.duplicadoSeleccionado = duplicado;
                print('Clic en el elemento: $duplicado');
                PantallaDeCarga.loadingI(context, true);
                _duplicadosProvider.listaAgrupaciones =
                    await obtenerRegistrosDuplicados(ApiDefinition.ipServer,
                        _proyectoSeleccionado, duplicado);
                PantallaDeCarga.loadingI(context, false);
              },
              splashColor: Color.fromARGB(255, 137, 164, 193),
              child: Container(
                width: boxConstraints.maxWidth,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      const Radius.circular(20.0),
                    )),
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(10.0),
                child: boxConstraints.maxWidth > 300
                    ? Row(
                        children: [
                          Text(_duplicadosProvider.camposDuplicados.keys
                                      .elementAt(index)
                                      .length <=
                                  15
                              ? _duplicadosProvider.camposDuplicados.keys
                                  .elementAt(index)
                              : '${_duplicadosProvider.camposDuplicados.keys.elementAt(index).substring(0, 15)}...'),
                          Expanded(child: Container()),
                          Text(
                              'Veces duplicado: ${_duplicadosProvider.camposDuplicados[_duplicadosProvider.camposDuplicados.keys.elementAt(index)].elementAt(3)}'),
                        ],
                      )
                    : Column(
                        children: [
                          Text(_duplicadosProvider.camposDuplicados.keys
                              .elementAt(index)),
                          Text(
                              'Veces duplicado: ${_duplicadosProvider.camposDuplicados[_duplicadosProvider.camposDuplicados.keys.elementAt(index)].elementAt(3)}'),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmarEliminarRegistro(BuildContext context,
      Proyecto proyecto, int idInventario, String folio) async {
    print('Codigo Registro: $idInventario');
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white, width: 3.0),
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            title: Container(
              child: Row(
                children: [
                  Text('Eliminar Registro: $folio'),
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
                padding: EdgeInsets.all(20.0),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Estas seguro de eliminar este registro, toda la informacion que contenga sera eliminada permanentemente (Evidencias, Fotografias, Documentos generados (PDF))'),
                    SizedBox(
                      height: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contraseña para poder eliminar el registro'),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          width: 250.0,
                          child: Form(
                            key: _formKeyEliminarProyecto,
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordEliminarProyectoController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Contraseña'),
                              validator: (String valor) {
                                if (valor.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'Ingresa la contraseña para poder eliminar el proyecto';
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 100.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKeyEliminarProyecto.currentState
                                      .validate()) {
                                    print(
                                        'Contraseña: ${_passwordEliminarProyectoController.text}');
                                    if (_passwordEliminarProyectoController
                                            .text ==
                                        'eliminarregistro170313') {
                                      Dialogos.advertencia(context,
                                          'Estas seguro de eliminar el registro?',
                                          () async {
                                        PantallaDeCarga.loadingI(context, true);
                                        String respuesta = await eliminarRegistro(
                                            ApiDefinition.ipServer,
                                            idInventario,
                                            _passwordEliminarProyectoController
                                                .text);
                                        _passwordEliminarProyectoController
                                            .text = '';
                                        PantallaDeCarga.loadingI(
                                            context, false);
                                        if (respuesta == 'Correcto') {
                                          _listaProyectos = [];
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } else {
                                          Dialogos.error(context,
                                              'Ocurrio un problema al intentar eliminar el registro');
                                        }
                                      });
                                    } else {
                                      Dialogos.error(
                                          context, 'Contraseña incorrecta');
                                    }
                                  }
                                },
                                child: Text('Aceptar'),
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Container(
                              width: 100.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _passwordEliminarProyectoController.text = '';
                                },
                                child: Text('Cancelar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }
}
