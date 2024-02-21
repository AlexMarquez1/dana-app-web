import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';
import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/page/widgets/EditarRegistro.dart';
import 'package:app_isae_desarrollo/src/page/widgets/ListaUsuarios.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TablaRegistros.dart';
import 'package:app_isae_desarrollo/src/page/widgets/tipoDeCampos.dart';

import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/models/CamposProyecto.dart';
import 'package:app_isae_desarrollo/src/models/EdicionAsignada.dart';
import 'package:app_isae_desarrollo/src/models/Estatus.dart';
import 'package:app_isae_desarrollo/src/models/Evidencia.dart';
import 'package:app_isae_desarrollo/src/models/Firma.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Pendiente.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../providers/registroProvider.dart';
import 'package:http/http.dart' as http;

class RegistroPage extends StatelessWidget {
  RegistroPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<PaginatedDataTableState> _dataTable =
      GlobalKey<PaginatedDataTableState>();
  final _formKeyRegistro = GlobalKey<FormState>();
  final _formKeyEditarAsignacion = GlobalKey<FormState>();
  late TabController _controller;
  late ScrollController _scrollRegistros = ScrollController();
  late ScrollController _scrollEditarRegistro = ScrollController();
  late ScrollController _scrollRegistors =
      ScrollController(initialScrollOffset: 0.0);

  late List<Inventario> _listaRegistros = [];
  late List<Inventario> _listaRegistrosCompleta = [];
  late List<Proyecto> _listaProyectos = [];
  late List<Usuario> _listaUsuarios = [];
  // List<Agrupaciones> _listaAgrupacionesObtenidas = [];
  List<String>? _listaBusqueda = [''];
  List<String>? _opciones = [''];
  // List<String> _listaFirmas = [];
  // List<String> _listaEvidencia = [];
  late List<EdicionAsignada> _listaCamposAsignados = [];
  late List<String> _listaEstatusRegistro = [
    'NUEVO',
    'ASIGNADO',
    'PENDIENTE',
    'EN PROCESO',
    'CERRADO'
  ];
  late List<String> _listaPendienteRegistro = [
    'Pendiente por firmas',
    'Pendiente por evidencia',
    'Motivo 3',
    'Motivo 4',
  ];

  late String _estatusRegistro;
  late String _motivoRegistro;
  late String _agrupacionSeleccionada;

  // Map<String, Catalogo> _catalogos = new Map<String, Catalogo>();
  // Map<String, bool> _comprobarFirma = new Map<String, bool>();
  // Map<String, ByteData> _firma = new Map<String, ByteData>();
  // Map<String, int> _idCampofirma = new Map<String, int>();
  // Map<String, DateTime> _camposCalendario = new Map<String, DateTime>();
  // Map<String, GlobalKey<SignatureState>> _keyFirma =
  //     new Map<String, GlobalKey<SignatureState>>();
  // Map<String, Map<String, Uint8List>> _evidenciaCheckList =
  //     <String, Map<String, Uint8List>>{};
  // Map<String, bool> _comprobarEvidenciaCheck = <String, bool>{};
  // Map<String, bool> _checkboxEvidencia = <String, bool>{};
  // Map<String, int> _idCampoEvidencias = <String, int>{};

  late Map<String, bool> _camposSeleccionados = new Map<String, bool>();
  late Map<String, bool> _agrupacionesSeleccionadas = new Map<String, bool>();
  // Map<String, bool> _comprobarEvidencia = new Map<String, bool>();
  // Map<String, int> _idCampoEvidencia = new Map<String, int>();
  // Map<String, Uint8List> _evidencia = new Map<String, Uint8List>();
  // Map<String, bool> _checkbox = new Map<String, bool>();

  late TextEditingController _controllerBusqueda = TextEditingController();
  late TextEditingController _controllerUsuarios = TextEditingController();
  late TextEditingController _controllerDescripcion = TextEditingController();
  Proyecto? _proyectoSeleccionado;
  Usuario? _usuarioSeleccionado;
  late List<Usuario> _usuariosSeleccionados = [];
  late Inventario _registroSeleccionado;
  String? _busquedaSeleccionada = '';
  late bool _mostrarBusqueda = false;
  late int _totalSeleccionado = 0;

  late StateSetter _setState;

  late RegistroProvider _registroProvider;
  late Map<int, bool> _registroSeleccion = <int, bool>{
    0: false,
  };

  late Map<int, List<int>> _relacionUsuarioInventario = <int, List<int>>{};
  late StateSetter _actualizarLista;

  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
    _listaProyectos =
        ModalRoute.of(context)!.settings.arguments as List<Proyecto> ?? [];
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(
        context,
        _scaffoldKey,
        registroProvider: _registroProvider,
      ),
      body: _contenido(context),
      endDrawer: DrawerPrincipal(),
      bottomNavigationBar: _registroProvider.mostrarMasOpciones
          ? _masOpciones(context)
          : BottomAppBar(),
      floatingActionButton: _registroProvider.mostrarMasOpciones
          ? _botonesMasOpciones(context)
          : _descargarDatos(context),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonLocation: _registroProvider.mostrarMasOpciones
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.endFloat,
    );
  }

  BottomAppBar _masOpciones(BuildContext context) {
    return BottomAppBar(
      shape:
          CircularNotchedRectangle(), //Crea un notch en caso de que exista un floatingActionButton
      color: Colors.blueGrey[800],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              const Icon(
                Icons.arrow_right_sharp,
                color: Colors.white,
                size: 30.0,
              ),
              Text(
                'Seleccionados: $_totalSeleccionado',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              Expanded(child: Container()),
              Tooltip(
                message: 'Volver a generar documentos seleccionados',
                child: FloatingActionButton.large(
                  onPressed: () async {
                    if (_proyectoSeleccionado!.idproyecto != 0) {
                      List<int> registrosSeleccionados =
                          _obtenerIdRegistrosSeleccionados();
                      Dialogos.advertencia(context,
                          'Se han seleccionado: ${registrosSeleccionados.length} registros en total, ten en cuenta que este proceso puede tardar dependiendo de la conexion a internet y la cantidad total de registros seleccionados',
                          () async {
                        Navigator.pop(context);
                        PantallaDeCarga.loadingI(context, true);
                        String respuesta =
                            await volverAGenerarDocumentosSeleccionados(
                                ApiDefinition.ipServer,
                                _proyectoSeleccionado!.idproyecto!,
                                registrosSeleccionados);
                        print(respuesta);
                        PantallaDeCarga.loadingI(context, false);
                        if (respuesta == 'Documentos Generados') {
                          Dialogos.mensaje(context,
                              'Los Documentos se generaron correctamente');
                        } else {
                          Dialogos.error(
                              context, 'Error al generar los documentos');
                        }
                      });
                    } else {
                      Dialogos.error(context,
                          'Es necesario que este seleccionado un solo proyecto para poder continuar');
                    }
                  },
                  child: Icon(Icons.replay_rounded),
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              _descargarDatos(context),
            ],
          ),
        ),
      ),
    );
  }

  List<int> _obtenerIdRegistrosSeleccionados() {
    List<int> ids = [];
    _registroSeleccion.forEach((key, value) {
      if (value && key != 0) {
        ids.add(key);
      }
    });
    return ids;
  }

  Widget _botonesMasOpciones(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () async {
        List<int> ids = _obtenerIdRegistrosSeleccionados();
        String? opcionSeleccionada = 'TODAS';
        GlobalKey<FormState> formKeyPaginas = GlobalKey<FormState>();
        TextEditingController controllerPaginas = TextEditingController();
        if (ids.isNotEmpty) {
          await showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (context, StateSetter actualizar) {
                  return SimpleDialog(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    title: Container(
                        child: Text(
                            'Se descargara un total de: ${ids.length} Pdf')),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(30.0),
                        width: 300.0,
                        child: Row(
                          children: [
                            Text('Paginas:'),
                            DropdownButton(
                              value: opcionSeleccionada,
                              items: const [
                                DropdownMenuItem(
                                  child: Text('TODAS'),
                                  value: 'TODAS',
                                ),
                                DropdownMenuItem(
                                  child: Text('PERSONALIZADO'),
                                  value: 'PERSONALIZADO',
                                )
                              ],
                              onChanged: (String? valor) {
                                opcionSeleccionada = valor;
                                actualizar(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      opcionSeleccionada == 'PERSONALIZADO'
                          ? Container(
                              width: 300.0,
                              child: Form(
                                key: formKeyPaginas,
                                child: TextFormField(
                                  controller: controllerPaginas,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      hintText: 'Ejemplo: 1-5'),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9\-]')),
                                  ],
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'INGRESE LAS PAGINAS QUE QUIERE DESCARGAR';
                                    }
                                  },
                                ),
                              ),
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10.0, right: 10.0),
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (opcionSeleccionada == 'PERSONALIZADO') {
                                  if (formKeyPaginas.currentState!.validate()) {
                                    _obtenerPDFS(context, ids,
                                        paginas: controllerPaginas.text);
                                  }
                                } else {
                                  _obtenerPDFS(context, ids);
                                }
                              },
                              child: Text('Aceptar'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10.0, right: 10.0),
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancelar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                });
              });
        } else {
          Dialogos.mensaje(context, 'No se a seleccionado ningun registro');
        }
      },
      child: Tooltip(
        message: 'Descargar documento',
        child: Icon(
          Icons.picture_as_pdf,
        ),
      ),
    );
  }

  void _obtenerPDFS(BuildContext context, List<int> ids,
      {String paginas = ''}) async {
    PantallaDeCarga.loadingI(context, true);
    Map<dynamic, dynamic> respuesta = await obtenerPDFUnidos(
        ApiDefinition.ipServer, _proyectoSeleccionado!, ids, paginas);
    String estatus = respuesta['respuesta'];
    if (estatus.contains('correcto')) {
      List<dynamic> jsonListPdf = respuesta['pdf'] as List<dynamic>;

      List<int> listaPdf = jsonListPdf.cast<int>();

      Uint8List bytes = Uint8List.fromList(listaPdf);

      final content = base64Encode(bytes);
      final anchor = html.AnchorElement(
          href:
              "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", "${_proyectoSeleccionado!.proyecto}.pdf")
        ..click();
    } else {
      await Dialogos.error(context, respuesta['respuesta']);
    }
    PantallaDeCarga.loadingI(context, false);
    Navigator.of(context).pop();
  }

  Widget _contenido(BuildContext context) {
    return SingleChildScrollView(
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter actualizar) {
        _actualizarLista = actualizar;
        return Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Registros'.toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              Container(
                child: Tarjetas.tarjeta(
                    MediaQuery.of(context).size,
                    Column(
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100.0,
                              child: Text('Proyecto'),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            _listarProyectos(context, actualizar),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        VariablesGlobales.usuario.perfil!.idperfil == '1' ||
                                VariablesGlobales.usuario.perfil!.idperfil ==
                                    '2' ||
                                VariablesGlobales.usuario.perfil!.idperfil ==
                                    '3' ||
                                VariablesGlobales.usuario.perfil!.idperfil ==
                                    '4'
                            ? _proyectoSeleccionado != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100.0,
                                        child: Text('Usuario'),
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Container(
                                        width: 300.0,
                                        child: _listaUsuarios.isEmpty
                                            ? _listarUsuariosBuilder(actualizar)
                                            : ListaUsuarios(
                                                controllerUsuarios:
                                                    _controllerUsuarios,
                                                listaUsuarios: _listaUsuarios,
                                                usuariosSeleccionado:
                                                    _usuariosSeleccionados,
                                                actualizar: actualizar,
                                                usuarioSeleccionadoAccion:
                                                    _usuarioSeleccionadoAccion,
                                                tipoBusqueda: 'MULTIPLE',
                                                limiteSeleccion: 3,
                                              ),
                                      )
                                    ],
                                  )
                                : Container()
                            : Container(),
                        SizedBox(
                          height: 20.0,
                        ),
                        _mostrarBusqueda
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100.0,
                                        child: Text('Buscar por:'),
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      _listarOpcionesBusqueda(
                                          context, actualizar),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100.0,
                                        child: Text('Buscar:'),
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      _autoCompletarBusqueda(actualizar),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          List<Inventario> registroAux = [];
                                          switch (_busquedaSeleccionada) {
                                            case 'FOLIO':
                                              for (Inventario registro
                                                  in _listaRegistrosCompleta) {
                                                if (registro.folio!
                                                    .toUpperCase()
                                                    .contains(
                                                        _controllerBusqueda.text
                                                            .toUpperCase())) {
                                                  registroAux.add(registro);
                                                }
                                              }
                                              break;
                                            case 'PROYECTO':
                                              for (Inventario registro
                                                  in _listaRegistrosCompleta) {
                                                if (registro
                                                        .proyecto!.proyecto ==
                                                    _controllerBusqueda.text
                                                        .toUpperCase()) {
                                                  registroAux.add(registro);
                                                }
                                              }
                                              break;
                                            case 'ESTATUS':
                                              for (Inventario registro
                                                  in _listaRegistrosCompleta) {
                                                if (registro.estatus ==
                                                    _controllerBusqueda.text
                                                        .toUpperCase()) {
                                                  registroAux.add(registro);
                                                }
                                              }
                                              break;
                                          }

                                          if (registroAux.isEmpty) {
                                            PantallaDeCarga.loadingI(
                                                context, true);
                                            registroAux = [];
                                            if (_usuariosSeleccionados
                                                .isEmpty) {
                                              registroAux.addAll(
                                                  await obtenerValoresCampos(
                                                      ApiDefinition.ipServer,
                                                      _proyectoSeleccionado!
                                                          .idproyecto!,
                                                      _busquedaSeleccionada!,
                                                      _controllerBusqueda.text,
                                                      0));
                                            } else {
                                              for (Usuario usuario
                                                  in _usuariosSeleccionados) {
                                                registroAux.addAll(
                                                    await obtenerValoresCampos(
                                                        ApiDefinition.ipServer,
                                                        _proyectoSeleccionado!
                                                            .idproyecto!,
                                                        _busquedaSeleccionada!,
                                                        _controllerBusqueda
                                                            .text,
                                                        usuario.idUsuario!));
                                              }
                                            }
                                            PantallaDeCarga.loadingI(
                                                context, false);
                                          }

                                          // _registroSeleccion = <int, bool>{};
                                          for (Inventario registro
                                              in _listaRegistros) {
                                            _registroSeleccion[
                                                registro.idinventario!] = false;
                                          }
                                          _registroProvider.mostrarMasOpciones =
                                              false;
                                          _listaRegistros = registroAux;
                                          _dataTable.currentState!.pageTo(0);
                                          actualizar(() {});
                                        },
                                        child: Text('Buscar'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    )),
              ),
              Tarjetas.tarjeta(
                MediaQuery.of(context).size,
                _tarjetaregistros(context, actualizar),
              ),
              SizedBox(
                height: 200.0,
              ),
            ],
          ),
        );
      }),
    );
  }
  // Widget _contenido(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: StatefulBuilder(
  //         builder: (BuildContext context, StateSetter actualizar) {
  //       _actualizarLista = actualizar;
  //       return Center(
  //         child: Column(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.only(top: 20.0),
  //               child: Text(
  //                 'Registros'.toUpperCase(),
  //                 style: TextStyle(fontSize: 40.0),
  //               ),
  //             ),
  //             Container(
  //               child: Tarjetas.tarjeta(
  //                   MediaQuery.of(context).size,
  //                   Column(
  //                     children: [
  //                       SizedBox(
  //                         height: 20.0,
  //                       ),
  //                       VariablesGlobales.usuario.perfil.idperfil == '1' ||
  //                               VariablesGlobales.usuario.perfil.idperfil ==
  //                                   '2' ||
  //                               VariablesGlobales.usuario.perfil.idperfil ==
  //                                   '3' ||
  //                               VariablesGlobales.usuario.perfil.idperfil == '4'
  //                           ? Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Container(
  //                                   width: 100.0,
  //                                   child: Text('Usuario'),
  //                                 ),
  //                                 SizedBox(
  //                                   width: 20.0,
  //                                 ),
  //                                 Container(
  //                                   width: 300.0,
  //                                   child: _listaUsuarios.isEmpty
  //                                       ? _listarUsuariosBuilder(actualizar)
  //                                       : ListaUsuarios(
  //                                           controllerUsuarios:
  //                                               _controllerUsuarios,
  //                                           listaUsuarios: _listaUsuarios,
  //                                           usuariosSeleccionado:
  //                                               _usuariosSeleccionados,
  //                                           actualizar: actualizar,
  //                                           usuarioSeleccionadoAccion:
  //                                               _usuarioSeleccionadoAccion,
  //                                           tipoBusqueda: 'MULTIPLE',
  //                                           limiteSeleccion: 3,
  //                                         ),
  //                                 )
  //                               ],
  //                             )
  //                           : Container(),
  //                       SizedBox(
  //                         height: 20.0,
  //                       ),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             width: 100.0,
  //                             child: Text('Proyecto'),
  //                           ),
  //                           SizedBox(
  //                             width: 20.0,
  //                           ),
  //                           _listarProyectos(context, actualizar),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         height: 20.0,
  //                       ),
  //                       _mostrarBusqueda
  //                           ? Column(
  //                               children: [
  //                                 Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Container(
  //                                       width: 100.0,
  //                                       child: Text('Buscar por:'),
  //                                     ),
  //                                     SizedBox(
  //                                       width: 20.0,
  //                                     ),
  //                                     _listarOpcionesBusqueda(
  //                                         context, actualizar),
  //                                   ],
  //                                 ),
  //                                 SizedBox(
  //                                   height: 20.0,
  //                                 ),
  //                                 Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Container(
  //                                       width: 100.0,
  //                                       child: Text('Buscar:'),
  //                                     ),
  //                                     SizedBox(
  //                                       width: 20.0,
  //                                     ),
  //                                     _autoCompletarBusqueda(actualizar),
  //                                     SizedBox(
  //                                       width: 20.0,
  //                                     ),
  //                                     ElevatedButton(
  //                                       onPressed: () async {
  //                                         List<Inventario> registroAux = [];
  //                                         switch (_busquedaSeleccionada) {
  //                                           case 'FOLIO':
  //                                             for (Inventario registro
  //                                                 in _listaRegistrosCompleta) {
  //                                               if (registro.folio
  //                                                   .toUpperCase()
  //                                                   .contains(
  //                                                       _controllerBusqueda.text
  //                                                           .toUpperCase())) {
  //                                                 registroAux.add(registro);
  //                                               }
  //                                             }
  //                                             break;
  //                                           case 'PROYECTO':
  //                                             for (Inventario registro
  //                                                 in _listaRegistrosCompleta) {
  //                                               if (registro
  //                                                       .proyecto.proyecto ==
  //                                                   _controllerBusqueda.text
  //                                                       .toUpperCase()) {
  //                                                 registroAux.add(registro);
  //                                               }
  //                                             }
  //                                             break;
  //                                           case 'ESTATUS':
  //                                             for (Inventario registro
  //                                                 in _listaRegistrosCompleta) {
  //                                               if (registro.estatus ==
  //                                                   _controllerBusqueda.text
  //                                                       .toUpperCase()) {
  //                                                 registroAux.add(registro);
  //                                               }
  //                                             }
  //                                             break;
  //                                         }

  //                                         if (registroAux.isEmpty) {
  //                                           PantallaDeCarga.loadingI(
  //                                               context, true);
  //                                           registroAux = [];
  //                                           for (Usuario usuario
  //                                               in _usuariosSeleccionados) {
  //                                             registroAux.addAll(
  //                                                 await obtenerValoresCampos(
  //                                                     ApiDefinition.ipServer,
  //                                                     _proyectoSeleccionado
  //                                                         .idproyecto,
  //                                                     _busquedaSeleccionada,
  //                                                     _controllerBusqueda.text,
  //                                                     usuario.idUsuario));
  //                                           }
  //                                           PantallaDeCarga.loadingI(
  //                                               context, false);
  //                                         }

  //                                         // _registroSeleccion = <int, bool>{};
  //                                         for (Inventario registro
  //                                             in _listaRegistros) {
  //                                           _registroSeleccion[
  //                                               registro.idinventario] = false;
  //                                         }
  //                                         _registroProvider.mostrarMasOpciones =
  //                                             false;
  //                                         _listaRegistros = registroAux;
  //                                         _dataTable.currentState.pageTo(0);
  //                                         actualizar(() {});
  //                                       },
  //                                       child: Text('Buscar'),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 SizedBox(
  //                                   height: 20.0,
  //                                 ),
  //                               ],
  //                             )
  //                           : Container(),
  //                     ],
  //                   )),
  //             ),
  //             Tarjetas.tarjeta(
  //               MediaQuery.of(context).size,
  //               _tarjetaregistros(context, actualizar),
  //             ),
  //             SizedBox(
  //               height: 200.0,
  //             ),
  //           ],
  //         ),
  //       );
  //     }),
  //   );
  // }

  Widget _descargarDatos(BuildContext context) {
    return Container(
      width: 350.0,
      child: Row(
        children: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter actualizar) {
            return Tooltip(
              message: 'Nuevo Registros',
              textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
              child: FloatingActionButton.large(
                heroTag: 'nuevo',
                child: Icon(Icons.add),
                onPressed: () async {
                  if (_proyectoSeleccionado != null) {
                    // _usuarioSeleccionado = null;
                    _usuarioSeleccionado = VariablesGlobales.usuario;
                    print(_usuariosSeleccionados.length);
                    if (_usuariosSeleccionados.length >= 2) {
                      _usuarioSeleccionado =
                          _usuariosSeleccionados.elementAt(0);
                      _usuarioSeleccionado = await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: Text(
                                  'Selecciona el usuario al que se le asignara el registro'),
                              children: [
                                StatefulBuilder(builder: (BuildContext context,
                                    StateSetter actualizar) {
                                  return DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Usuario',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Selecciona una opcion';
                                      }
                                      return null;
                                    },
                                    value: _usuarioSeleccionado,
                                    onChanged: (Usuario? valor) async {
                                      _usuarioSeleccionado = valor!;
                                      actualizar(() {});
                                    },
                                    items: _usuariosSeleccionados.map((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item.usuario!,
                                          maxLines: 3,
                                          overflow: TextOverflow.clip,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context, _usuarioSeleccionado);
                                        },
                                        child: Text('Aceptar')),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancelar')),
                                  ],
                                ),
                              ],
                            );
                          });
                      if (_usuarioSeleccionado != null) {
                        print(_usuarioSeleccionado!.nombre);
                        PantallaDeCarga.loadingI(context, true);
                        await _registroProvider.nuevoRegistro(
                          _proyectoSeleccionado!,
                        );
                        PantallaDeCarga.loadingI(context, false);
                        _mostrarCampos(
                            context, _proyectoSeleccionado!, actualizar, true);
                      }
                    } else {
                      PantallaDeCarga.loadingI(context, true);
                      await _registroProvider.nuevoRegistro(
                        _proyectoSeleccionado!,
                      );
                      PantallaDeCarga.loadingI(context, false);
                      _mostrarCampos(
                          context, _proyectoSeleccionado!, actualizar, true);
                    }

                    //TODO: Comprobar porque no se guardan las evidencias y firmar, actualizar lista para que se muestre el registro creado

                    _actualizarLista(() {});
                  } else {
                    Dialogos.mensaje(context,
                        'Selecciona un proyecto para poder generar un nuevo registro');
                  }
                },
              ),
            );
          }),
          SizedBox(
            width: 30.0,
          ),
          Tooltip(
            message: 'Descargar Registros',
            textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
            child: FloatingActionButton.large(
              heroTag: 'extracto',
              child: Icon(Icons.file_open_outlined),
              onPressed: () async {
                if (_listaRegistros.isNotEmpty) {
                  List<int> respuesta = [];
                  PantallaDeCarga.loadingI(context, true);
                  if (_proyectoSeleccionado!.proyecto == 'TODOS' ||
                      _proyectoSeleccionado!.proyecto != 'ISSSTE') {
                    respuesta = await generarDocumentoRegistros(
                        ApiDefinition.ipServer, _listaRegistros);
                  } else {
                    respuesta = await generarDocumentoRegistrosProyecto(
                        ApiDefinition.ipServer,
                        _listaRegistros,
                        _proyectoSeleccionado!.idproyecto!);
                  }

                  Uint8List bytes = Uint8List.fromList(respuesta);
                  final content = base64Encode(bytes);
                  final anchor = html.AnchorElement(
                      href:
                          "data:application/octet-stream;charset=utf-16le;base64,$content")
                    ..setAttribute("download", "file.csv")
                    ..click();
                  PantallaDeCarga.loadingI(context, false);
                } else {
                  Dialogos.mensaje(context,
                      'Selecciona al menos un usuario y un proyecto para poder descargar los datos');
                }
              },
            ),
          ),
          SizedBox(
            width: 30.0,
          ),
          Tooltip(
            message: 'Descargar Evidencias',
            textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
            child: FloatingActionButton.large(
              heroTag: 'evidencia',
              child: Icon(Icons.photo_size_select_actual_rounded),
              onPressed: () async {
                List<int> registrosSeleccionados =
                    _obtenerIdRegistrosSeleccionados();
                if (_listaRegistros.isNotEmpty) {
                  PantallaDeCarga.loadingI(context, true);
                  List<int> listaIdInventario = [];

                  _listaRegistros.forEach((element) {
                    listaIdInventario.add(element.idinventario!);
                  });
                  print(listaIdInventario);
                  List<FotoEvidencia> listaEvidencias = await obtenerEvidencias(
                      ApiDefinition.ipServer,
                      registrosSeleccionados.isEmpty
                          ? listaIdInventario
                          : registrosSeleccionados);
                  Map<String, Map<String, Uint8List>> archivos =
                      await _obtenerBytes(listaEvidencias);

                  _downloadFilesAsZIP(archivos);

                  PantallaDeCarga.loadingI(context, false);
                } else {
                  Dialogos.mensaje(context,
                      'Selecciona al menos un usuario y un proyecto para poder descargar los datos');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, Map<String, Uint8List>>> _obtenerBytes(
      List<FotoEvidencia> listaEvidencias) async {
    Map<String, Map<String, Uint8List>> respuesta = {};
    for (FotoEvidencia item in listaEvidencias) {
      if (respuesta[item.inventario!.folio] == null) {
        respuesta.addAll({
          item.inventario!.folio!: {
            item.usuario!.idUsuario == 0
                ? '${item.nombrefoto}.pdf'
                : '${item.nombrefoto}'.contains('.png')
                    ? '${item.nombrefoto}'
                    : '${item.nombrefoto}.png': await _obtenerArchivo(item.url!)
          }
        });
      } else {
        respuesta[item.inventario!.folio]!.addAll(
          {
            item.usuario!.idUsuario == 0
                ? '${item.nombrefoto}.pdf'
                : '${item.nombrefoto}'.contains('.png')
                    ? '${item.nombrefoto}'
                    : '${item.nombrefoto}.png': await _obtenerArchivo(item.url!)
          },
        );
      }
    }
    return respuesta;
  }

  Future<void> _downloadFilesAsZIP(
      Map<String, Map<String, Uint8List>> archivos) async {
    var encoder = ZipEncoder();
    var archive = Archive();
    archivos.forEach((folio, evidencias) {
      evidencias.forEach((nombre, bytes) {
        ArchiveFile archiveFiles = ArchiveFile.stream(
          '$folio/$nombre',
          bytes.length,
          InputStream(bytes,
              byteOrder: LITTLE_ENDIAN, start: 0, length: bytes.length),
        );
        archive.addFile(archiveFiles);
      });
    });

    var outputStream = OutputStream(
      byteOrder: LITTLE_ENDIAN,
    );
    var bytes = encoder.encode(archive,
        level: Deflate.BEST_COMPRESSION, output: outputStream);

    _downloadFile("Evidencia.zip", Uint8List.fromList(bytes!));
  }

  _downloadFile(String fileName, Uint8List bytes) {
    final content = base64Encode(bytes);
    final anchor = html.AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content")
      ..setAttribute("download", "$fileName")
      ..click();
  }

  Future<Uint8List> _obtenerArchivo(String url) async {
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(url));
    Uint8List bytes = req.bodyBytes;
    return bytes;
  }

  Widget _autoCompletarBusqueda(StateSetter actualizar) {
    return Autocomplete<Object>(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (_controllerBusqueda.text.isNotEmpty) {
          textEditingController.text = _controllerBusqueda.text;
        }
        _controllerBusqueda = textEditingController;
        return Container(
          width: 200.0,
          child: TextFormField(
            //enabled: _habilitarBusqueda,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una busqueda';
              } else {
                bool validacion = false;
                for (String busqueda in _listaBusqueda!) {
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
          if (_listaBusqueda!.isEmpty) {
            return ['Sin resultados'];
          } else {
            return _listaBusqueda!.where((String opcion) {
              return opcion
                  .toUpperCase()
                  .contains(textEditingValue.text.toUpperCase());
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
          actualizar(() {});
        } else {
          print('Se a seleccionado: $seleccion');
        }
      },
    );
  }

  Widget _tarjetaregistros(BuildContext context, StateSetter actualizar) {
    return SingleChildScrollView(
      child: Card(
        color: Colors.grey[300],
        child: _respuestaRegistros(context, actualizar),
        // child: _tablaRegistrosEditar(context, actualizar),
      ),
    );
  }

  Widget _respuestaRegistros(BuildContext context, StateSetter actualizar) {
    double ancho = MediaQuery.of(context).size.width;
    double alto = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(left: 10.0),
      width: ancho * 0.7,
      height: alto * 0.6,
      child: SingleChildScrollView(
        child: Theme(
            data: Theme.of(context).copyWith(
              cardColor: Colors.grey[300],
            ),
            child: PaginatedDataTable(
              key: _dataTable,
              rowsPerPage: 10,
              source: TablaRegistros(
                  listaInventario: _listaRegistros,
                  registroSeleccion: _registroSeleccion,
                  clickRegistro: (Inventario registro) async {
                    _registroSeleccionado = registro;
                    PantallaDeCarga.loadingI(context, true);
                    _relacionUsuarioInventario.forEach((key, value) {
                      for (int item in value) {
                        if (_registroSeleccionado.idinventario == item) {
                          _usuarioSeleccionado = Usuario(
                              idUsuario: key,
                              nombre: 'SIN RESULTADOS',
                              usuario: 'SIN RESULTADOS',
                              correo: '_correo',
                              telefono: '_telefono',
                              ubicacion: '_ubicacion',
                              jefeInmediato: '_jefeInmediato',
                              perfil: Perfil(),
                              password: '_password',
                              passTemp: 0,
                              clienteAplicacion: ClienteAplicacion(),
                              status: '',
                              token: '',
                              vistacliente: Cliente());
                          break;
                        }
                      }
                    });
                    if (_usuarioSeleccionado != null) {
                      print(
                          'Usuario seleccionado: ${_usuarioSeleccionado!.idUsuario}');
                      await _registroProvider.obtenerRegistro(
                          Inventario(
                              idinventario: registro.idinventario,
                              proyecto: registro.proyecto),
                          _usuarioSeleccionado!.idUsuario!);
                    } else {
                      await _registroProvider.obtenerRegistro(
                          Inventario(
                              idinventario: registro.idinventario,
                              proyecto: registro.proyecto),
                          0);
                    }
                    PantallaDeCarga.loadingI(context, false);

                    _mostrarCampos(
                        context, registro.proyecto!, actualizar, false);
                  },
                  accionSeleccionarRegistro: (bool valor, Inventario registro) {
                    print('Valor: $valor');
                    // _registroSeleccion[
                    //     registro.idinventario] = valor;
                    bool unaSeleccion = false;
                    for (bool item in _registroSeleccion.values) {
                      if (item) {
                        unaSeleccion = true;
                        break;
                      }
                    }
                    if (unaSeleccion) {
                      _registroProvider.mostrarMasOpciones = true;
                      _totalSeleccionado = _registroSeleccion.values
                          .where((element) => element == true)
                          .length;
                    } else {
                      _registroProvider.mostrarMasOpciones = false;
                    }
                    actualizar(() {});
                  },
                  clickEditarAsignacion: (Inventario registro) async {
                    //TODO: Arreglar el poder editar la asignacion en dado caso que no se ha seleccionado el usuario
                    _registroSeleccionado = registro;
                    PantallaDeCarga.loadingI(context, true);
                    _registroProvider.listaAgrupaciones =
                        // _listaAgrupacionesObtenidas =
                        await obtenerDatosCamposRegistro(
                            ApiDefinition.ipServer,
                            registro.proyecto!.idproyecto!,
                            registro.idinventario!);
                    _camposSeleccionados['Todos'] = false;
                    for (int i = 0;
                        i < _registroProvider.listaAgrupaciones.length;
                        i++) {
                      for (int j = 0;
                          j <
                              _registroProvider.listaAgrupaciones
                                  .elementAt(i)
                                  .campos!
                                  .length;
                          j++) {
                        _camposSeleccionados[_registroProvider.listaAgrupaciones
                            .elementAt(i)
                            .campos!
                            .elementAt(j)
                            .nombreCampo!] = false;
                      }
                      _agrupacionesSeleccionadas[_registroProvider
                          .listaAgrupaciones
                          .elementAt(i)
                          .agrupacion!] = false;
                    }
                    _controllerDescripcion.text = '';
                    _motivoRegistro = 'null';
                    if (_registroSeleccionado.estatus == 'PENDIENTE') {
                      Pendiente? pendiente =
                          await _obtenerPendiente(_registroSeleccionado);
                      _motivoRegistro = pendiente!.motivo!;
                      _controllerDescripcion.text = pendiente.descripcion!;
                    }

                    _listaCamposAsignados = await obtenerCamposEdicion(
                        ApiDefinition.ipServer,
                        _usuarioSeleccionado!.idUsuario!,
                        registro.idinventario!);

                    if (_listaCamposAsignados.isNotEmpty) {
                      for (EdicionAsignada edicion in _listaCamposAsignados) {
                        _camposSeleccionados[edicion.camposProyecto!.campo!] =
                            true;
                      }
                    }

                    PantallaDeCarga.loadingI(context, false);
                    _estatusRegistro = _registroSeleccionado.estatus!;
                    await _mostrarCamposAsignarEdicion(
                        context, registro.proyecto!);
                    actualizar(() {});
                  },
                  clickPdf: (Inventario registro) async {
                    if (registro.estatus != 'CERRADO') {
                      String documento = await obtenerUrlDocumento(
                          ApiDefinition.ipServer, registro.idinventario!);

                      if (documento.isNotEmpty) {
                        html.window.open(documento, 'new tab');
                      } else {
                        Dialogos.advertencia(context,
                            'El registro no se encuentra cerrado quieres generar el PDF?',
                            () async {
                          PantallaDeCarga.loadingI(context, true);
                          _registroProvider.listaAgrupaciones =
                              // _listaAgrupacionesObtenidas =
                              await obtenerDatosCamposRegistro(
                                  ApiDefinition.ipServer,
                                  registro.proyecto!.idproyecto!,
                                  registro.idinventario!);
                          Uint8List bytes = await obtenerPdf(
                              ApiDefinition.ipServer,
                              _registroProvider.listaAgrupaciones,
                              registro.idinventario!);

                          final blob = html.Blob([bytes], 'application/pdf');
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          html.window.open(url, '_blank');
                          html.Url.revokeObjectUrl(url);
                          PantallaDeCarga.loadingI(context, false);
                          Navigator.of(context).pop();
                        });
                      }
                    } else {
                      String urlDocumento = await obtenerUrlDocumento(
                          ApiDefinition.ipServer, registro.idinventario!);

                      html.window.open(urlDocumento, 'new tab');
                    }
                  },
                  clickVolverACargar: (Inventario registro) async {
                    PantallaDeCarga.loadingI(context, true);
                    await volverAGenerarDocumento(
                        ApiDefinition.ipServer, registro.idinventario!);
                    PantallaDeCarga.loadingI(context, false);
                  }),
              columns: [
                DataColumn(
                    label: Text(
                  'Folio'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'Estatus'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'Fecha Creacion'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'Abrir'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'PDF'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'Volver a cargar PDF'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                DataColumn(
                    label: Text(
                  'Evidencia'.toUpperCase(),
                  textAlign: TextAlign.center,
                )),
                // DataColumn(
                //   label: Text(
                //     'Editar Asignacion'.toUpperCase(),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
              ],
            )),
      ),
    );
    //Version vieja para mostrar los registros
    // ListView.builder(
    //   controller: _scrollRegistros,
    //   itemCount: _listaRegistros.length,
    //   itemBuilder: (BuildContext context, int ind) {
    //     return ListTile(
    //       leading: _listaRegistros.elementAt(ind).estatus == 'CERRADO'
    //           ? Checkbox(
    //               value: _registroSeleccion[
    //                   _listaRegistros.elementAt(ind).idinventario],
    //               onChanged: (bool valor) {
    //                 print('Valor: $valor');
    //                 _registroSeleccion[
    //                     _listaRegistros.elementAt(ind).idinventario] = valor;
    //                 bool unaSeleccion = false;
    //                 for (bool item in _registroSeleccion.values) {
    //                   if (item) {
    //                     unaSeleccion = true;
    //                     break;
    //                   }
    //                 }
    //                 if (unaSeleccion) {
    //                   _registroProvider.mostrarMasOpciones = true;
    //                   _totalSeleccionado = _registroSeleccion.values
    //                       .where((element) => element == true)
    //                       .length;
    //                 } else {
    //                   _registroProvider.mostrarMasOpciones = false;
    //                 }
    //                 actualizar(() {});
    //               },
    //             )
    //           : Tooltip(
    //               message:
    //                   'Para poder seleccionarlo el estatus tiene que estar en cerrado',
    //               textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
    //               child: Container(
    //                 padding: EdgeInsets.only(left: 4.0),
    //                 child: Icon(Icons.dangerous_outlined),
    //               ),
    //             ),
    //       onTap: () async {
    //         _registroSeleccionado = _listaRegistros.elementAt(ind);
    //         PantallaDeCarga.loadingI(context, true);
    //         _relacionUsuarioInventario.forEach((key, value) {
    //           for (int item in value) {
    //             if (_registroSeleccionado.idinventario == item) {
    //               _usuarioSeleccionado = Usuario(key, '', '', '', '', '', '',
    //                   Perfil(idperfil: '0', perfil: ''), '', 0);
    //               break;
    //             }
    //           }
    //         });
    //         print('Usuario seleccionado: ${_usuarioSeleccionado.idUsuario}');
    //         await _registroProvider.obtenerRegistro(
    //             Inventario(
    //                 idinventario: _listaRegistros.elementAt(ind).idinventario,
    //                 proyecto: _listaRegistros.elementAt(ind).proyecto),
    //             _usuarioSeleccionado.idUsuario);
    //         PantallaDeCarga.loadingI(context, false);

    //         _mostrarCampos(context, _listaRegistros.elementAt(ind).proyecto,
    //             actualizar, false);
    //       },
    //       title: Container(
    //         width: MediaQuery.of(context).size.width * 0.5,
    //         child: Wrap(
    //           spacing: 60.0,
    //           direction: Axis.horizontal,
    //           alignment: WrapAlignment.start,
    //           runAlignment: WrapAlignment.center,
    //           children: [
    //             Container(
    //               width: ancho * 0.15,
    //               height: 50.0,
    //               child: Center(
    //                 child: Text(
    //                   _listaRegistros.elementAt(ind).proyecto.proyecto,
    //                   style: TextStyle(overflow: TextOverflow.ellipsis),
    //                   maxLines: 2,
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               width: ancho * 0.1,
    //               height: 50.0,
    //               child: Center(
    //                 child: Text(
    //                   _listaRegistros.elementAt(ind).folio,
    //                   style: TextStyle(overflow: TextOverflow.ellipsis),
    //                   maxLines: 2,
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               width: ancho * 0.05,
    //               height: 50.0,
    //               child: Center(
    //                 child: Text(
    //                   _listaRegistros.elementAt(ind).estatus,
    //                   style: TextStyle(overflow: TextOverflow.ellipsis),
    //                   maxLines: 2,
    //                 ),
    //               ),
    //             ),
    //             Container(
    //               width: ancho * 0.05,
    //               height: 50.0,
    //               child: Center(
    //                 child: Text(
    //                   _listaRegistros.elementAt(ind).fechacreacion,
    //                   style: TextStyle(overflow: TextOverflow.ellipsis),
    //                   maxLines: 2,
    //                 ),
    //               ),
    //             ),
    //             IconButton(
    //               onPressed: () async {
    //                 if (_listaRegistros.elementAt(ind).estatus != 'CERRADO') {
    //                   String documento = await obtenerUrlDocumento(
    //                       ApiDefinition.ipServer,
    //                       _listaRegistros.elementAt(ind).idinventario);

    //                   if (documento.isNotEmpty) {
    //                     html.window.open(documento, 'new tab');
    //                   } else {
    //                     Dialogos.advertencia(context,
    //                         'El registro no se encuentra cerrado quieres generar el PDF?',
    //                         () async {
    //                       PantallaDeCarga.loadingI(context, true);
    //                       _registroProvider.listaAgrupaciones =
    //                           // _listaAgrupacionesObtenidas =
    //                           await obtenerDatosCamposRegistro(
    //                               ApiDefinition.ipServer,
    //                               _listaRegistros
    //                                   .elementAt(ind)
    //                                   .proyecto
    //                                   .idproyecto,
    //                               _listaRegistros.elementAt(ind).idinventario);
    //                       Uint8List bytes = await obtenerPdf(
    //                           ApiDefinition.ipServer,
    //                           _registroProvider.listaAgrupaciones,
    //                           _listaRegistros.elementAt(ind).idinventario);

    //                       final blob = html.Blob([bytes], 'application/pdf');
    //                       final url = html.Url.createObjectUrlFromBlob(blob);
    //                       html.window.open(url, '_blank');
    //                       html.Url.revokeObjectUrl(url);
    //                       PantallaDeCarga.loadingI(context, false);
    //                       Navigator.of(context).pop();
    //                     });
    //                   }
    //                 } else {
    //                   String urlDocumento = await obtenerUrlDocumento(
    //                       ApiDefinition.ipServer,
    //                       _listaRegistros.elementAt(ind).idinventario);

    //                   html.window.open(urlDocumento, 'new tab');
    //                 }
    //               },
    //               icon: Icon(Icons.picture_as_pdf_rounded),
    //             ),
    //             IconButton(
    //               onPressed: () async {
    //                 PantallaDeCarga.loadingI(context, true);
    //                 await volverAGenerarDocumento(ApiDefinition.ipServer,
    //                     _listaRegistros.elementAt(ind).idinventario);
    //                 PantallaDeCarga.loadingI(context, false);
    //               },
    //               icon: Icon(Icons.replay_outlined),
    //             ),
    //             VerEvidencia(
    //               inventario: _listaRegistros.elementAt(ind),
    //             ),
    //             IgnorePointer(
    //               ignoring: VariablesGlobales.usuario.perfil.idperfil == "4",
    //               child: IconButton(
    //                 onPressed: () async {
    //                   _registroSeleccionado = _listaRegistros.elementAt(ind);
    //                   PantallaDeCarga.loadingI(context, true);
    //                   _registroProvider.listaAgrupaciones =
    //                       // _listaAgrupacionesObtenidas =
    //                       await obtenerDatosCamposRegistro(
    //                           ApiDefinition.ipServer,
    //                           _listaRegistros
    //                               .elementAt(ind)
    //                               .proyecto
    //                               .idproyecto,
    //                           _listaRegistros.elementAt(ind).idinventario);
    //                   _camposSeleccionados['Todos'] = false;
    //                   for (int i = 0;
    //                       i < _registroProvider.listaAgrupaciones.length;
    //                       i++) {
    //                     for (int j = 0;
    //                         j <
    //                             _registroProvider.listaAgrupaciones
    //                                 .elementAt(i)
    //                                 .campos
    //                                 .length;
    //                         j++) {
    //                       _camposSeleccionados[_registroProvider
    //                           .listaAgrupaciones
    //                           .elementAt(i)
    //                           .campos
    //                           .elementAt(j)
    //                           .nombreCampo] = false;
    //                     }
    //                     _agrupacionesSeleccionadas[_registroProvider
    //                         .listaAgrupaciones
    //                         .elementAt(i)
    //                         .agrupacion] = false;
    //                   }
    //                   _controllerDescripcion.text = '';
    //                   _motivoRegistro = null;
    //                   if (_registroSeleccionado.estatus == 'PENDIENTE') {
    //                     Pendiente pendiente =
    //                         await _obtenerPendiente(_registroSeleccionado);
    //                     _motivoRegistro = pendiente.motivo;
    //                     _controllerDescripcion.text = pendiente.descripcion;
    //                   }

    //                   _listaCamposAsignados = await obtenerCamposEdicion(
    //                       ApiDefinition.ipServer,
    //                       _usuarioSeleccionado.idUsuario,
    //                       _listaRegistros.elementAt(ind).idinventario);

    //                   if (_listaCamposAsignados.isNotEmpty) {
    //                     for (EdicionAsignada edicion in _listaCamposAsignados) {
    //                       _camposSeleccionados[edicion.camposProyecto.campo] =
    //                           true;
    //                     }
    //                   }

    //                   PantallaDeCarga.loadingI(context, false);
    //                   _estatusRegistro = _registroSeleccionado.estatus;
    //                   await _mostrarCamposAsignarEdicion(
    //                       context, _listaRegistros.elementAt(ind).proyecto);
    //                   actualizar(() {});
    //                 },
    //                 icon: Icon(Icons.edit_note),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  Widget _tablaRegistrosEditar(BuildContext context, StateSetter actualizar) {
    double ancho = MediaQuery.of(context).size.width;
    double alto = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Text('Lista de Registros'.toUpperCase()),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.67999,
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.spaceAround,
            runAlignment: WrapAlignment.center,
            spacing: 50.0,
            children: [
              Container(
                width: 5.0,
                // height: 50.0,
                child: Center(
                  child: Checkbox(
                    value: _registroSeleccion[0],
                    onChanged: (bool? valor) {
                      print('Valor: $valor');
                      _registroSeleccion[0] = valor!;
                      for (Inventario registro in _listaRegistros) {
                        if (registro.estatus == 'CERRADO') {
                          _registroSeleccion[registro.idinventario!] = valor!;
                        }
                      }

                      if (valor!) {
                        _registroProvider.mostrarMasOpciones = true;
                        _totalSeleccionado = (_registroSeleccion.values
                                .where((element) => element == true)
                                .length) -
                            1;
                      } else {
                        _registroProvider.mostrarMasOpciones = false;
                      }

                      actualizar(() {});
                    },
                  ),
                ),
              ),
              Container(
                width: ancho * 0.05,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Proyecto',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.1,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Folio',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.05,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Estatus',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.05,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Fecha Creacion',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.02,
                height: 50.0,
                child: Center(
                  child: Text(
                    'PDF',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.04,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Volver a cargar PDF',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.04,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Evidencia',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                width: ancho * 0.04,
                height: 50.0,
                child: Center(
                  child: Text(
                    'Editar Asignacion',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 50.0,
        ),
        _respuestaRegistros(context, actualizar),
        // Container(
        //   margin: EdgeInsets.only(top: 10.0, left: 10.0),
        //   child: DataTable(
        //     showCheckboxColumn: false,
        //     columns: [
        //       DataColumn(
        //         label: Text('Proyecto'.toUpperCase()),
        //         tooltip: 'Proyecto'.toUpperCase(),
        //         onSort: (colIndex, asc) {
        //           _sort<String>((registro) => registro.proyecto.proyecto, asc,
        //               actualizar);
        //         },
        //       ),
        //       DataColumn(
        //         label: Text('Folio'.toUpperCase()),
        //         tooltip: 'Folio'.toUpperCase(),
        //         onSort: (colIndex, asc) {
        //           _sort<String>((registro) => registro.folio, asc, actualizar);
        //         },
        //       ),
        //       DataColumn(
        //         label: Text('Estatus'.toUpperCase()),
        //         tooltip: 'Estatus'.toUpperCase(),
        //         onSort: (colIndex, asc) {
        //           _sort<String>(
        //               (registro) => registro.estatus, asc, actualizar);
        //         },
        //       ),
        //       DataColumn(
        //         label: Text('Fecha creacion'.toUpperCase()),
        //         tooltip: 'Fecha creacion'.toUpperCase(),
        //         onSort: (colIndex, asc) {
        //           _sort<String>(
        //               (registro) => registro.fechaCreacion, asc, actualizar);
        //         },
        //       ),
        //       DataColumn(
        //         label: Text('PDF'.toUpperCase()),
        //         tooltip: 'PDF'.toUpperCase(),
        //       ),
        //       DataColumn(
        //         label: Text('RECARGAR PDF'.toUpperCase()),
        //         tooltip: 'VOLVER A GENERAR DOCUMENTO'.toUpperCase(),
        //       ),
        //       DataColumn(
        //         label: Text('Evidencia'.toUpperCase()),
        //         tooltip: 'Evidencia'.toUpperCase(),
        //       ),
        //       DataColumn(
        //         label: Text('Asignar edicion'.toUpperCase()),
        //         tooltip: 'Asignar edicion'.toUpperCase(),
        //       ),
        //     ],
        //     rows: _listaRegistros
        //         .map((registro) => DataRow.byIndex(
        //                 index: registro.idRegistro,
        //                 onSelectChanged: (seleccion) async {
        //                   _registroSeleccionado = registro;
        //                   PantallaDeCarga.loadingI(context, true);
        //                   await _registroProvider.obtenerRegistro(
        //                       Inventario(
        //                           idinventario: registro.idRegistro,
        //                           proyecto: registro.proyecto),
        //                       _usuarioSeleccionado.idUsuario);
        //                   PantallaDeCarga.loadingI(context, false);
        //                   _mostrarCampos(context, registro.proyecto);
        //                 },
        //                 cells: [
        //                   DataCell(Text(registro.proyecto.proyecto)),
        //                   DataCell(Text(registro.folio)),
        //                   DataCell(Text(registro.estatus)),
        //                   DataCell(Text(registro.fechaCreacion)),
        //                   DataCell(IconButton(
        //                     onPressed: () async {
        //                       if (registro.estatus != 'CERRADO') {
        //                         Dialogos.advertencia(context,
        //                             'El registro no se encuentra cerrado quieres generar el PDF?',
        //                             () async {
        //                           PantallaDeCarga.loadingI(context, true);
        //                           _registroProvider.listaAgrupaciones =
        //                               // _listaAgrupacionesObtenidas =
        //                               await obtenerDatosCamposRegistro(
        //                                   ApiDefinition.ipServer,
        //                                   registro.proyecto.idproyecto,
        //                                   registro.idRegistro);
        //                           Uint8List bytes = await obtenerPdf(
        //                               ApiDefinition.ipServer,
        //                               _registroProvider.listaAgrupaciones,
        //                               registro.idRegistro);

        //                           final blob =
        //                               html.Blob([bytes], 'application/pdf');
        //                           final url =
        //                               html.Url.createObjectUrlFromBlob(blob);
        //                           html.window.open(url, '_blank');
        //                           html.Url.revokeObjectUrl(url);
        //                           PantallaDeCarga.loadingI(context, false);
        //                           Navigator.of(context).pop();
        //                         });
        //                       } else {
        //                         String urlDocumento = await obtenerUrlDocumento(
        //                             ApiDefinition.ipServer,
        //                             registro.idRegistro);

        //                         html.window.open(urlDocumento, 'new tab');
        //                       }
        //                     },
        //                     icon: Icon(Icons.picture_as_pdf_rounded),
        //                   )),
        //                   DataCell(
        //                     IconButton(
        //                       onPressed: () async {
        //                         PantallaDeCarga.loadingI(context, true);
        //                         await volverAGenerarDocumento(
        //                             ApiDefinition.ipServer,
        //                             registro.idRegistro);
        //                         PantallaDeCarga.loadingI(context, false);
        //                       },
        //                       icon: Icon(Icons.replay_outlined),
        //                     ),
        //                   ),
        //                   DataCell(VerEvidencia(
        //                     inventario: registro,
        //                   )),
        //                   DataCell(IconButton(
        //                       onPressed: () async {
        //                         _registroSeleccionado = registro;
        //                         PantallaDeCarga.loadingI(context, true);
        //                         _registroProvider.listaAgrupaciones =
        //                             // _listaAgrupacionesObtenidas =
        //                             await obtenerDatosCamposRegistro(
        //                                 ApiDefinition.ipServer,
        //                                 registro.proyecto.idproyecto,
        //                                 registro.idRegistro);
        //                         _camposSeleccionados['Todos'] = false;
        //                         for (int i = 0;
        //                             i <
        //                                 _registroProvider
        //                                     .listaAgrupaciones.length;
        //                             i++) {
        //                           for (int j = 0;
        //                               j <
        //                                   _registroProvider.listaAgrupaciones
        //                                       .elementAt(i)
        //                                       .campos
        //                                       .length;
        //                               j++) {
        //                             //TODO: Comprobar campos seleccionados para editar
        //                             _camposSeleccionados[_registroProvider
        //                                 .listaAgrupaciones
        //                                 .elementAt(i)
        //                                 .campos
        //                                 .elementAt(j)
        //                                 .nombreCampo] = false;
        //                           }
        //                           _agrupacionesSeleccionadas[_registroProvider
        //                               .listaAgrupaciones
        //                               .elementAt(i)
        //                               .agrupacion] = false;
        //                         }
        //                         _controllerDescripcion.text = '';
        //                         _motivoRegistro = null;
        //                         if (_registroSeleccionado.estatus ==
        //                             'PENDIENTE') {
        //                           Pendiente pendiente = await _obtenerPendiente(
        //                               _registroSeleccionado);
        //                           _motivoRegistro = pendiente.motivo;
        //                           _controllerDescripcion.text =
        //                               pendiente.descripcion;
        //                         }

        //                         _listaCamposAsignados =
        //                             await obtenerCamposEdicion(
        //                                 ApiDefinition.ipServer,
        //                                 _usuarioSeleccionado.idUsuario,
        //                                 registro.idRegistro);

        //                         if (_listaCamposAsignados.isNotEmpty) {
        //                           for (EdicionAsignada edicion
        //                               in _listaCamposAsignados) {
        //                             _camposSeleccionados[
        //                                 edicion.camposProyecto.campo] = true;
        //                           }
        //                         }

        //                         PantallaDeCarga.loadingI(context, false);
        //                         _estatusRegistro =
        //                             _registroSeleccionado.estatus;
        //                         await _mostrarCamposAsignarEdicion(
        //                             context, registro.proyecto);

        //                         actualizar(() {});
        //                       },
        //                       icon: Icon(Icons.edit_note))),
        //                 ]))
        //         .toList(),
        //   ),
        // ),
      ],
    );
  }

  Future<Pendiente?> _obtenerPendiente(Inventario inventario) async {
    return await obtenerPendienteActual(
        ApiDefinition.ipServer, inventario.idinventario!);
  }

  void _sort<T>(Comparable<T> Function(Inventario r) getField, bool ascendente,
      StateSetter actualizar) {
    _listaRegistros.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascendente
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    actualizar(() {});
  }

  Future<List<Usuario>> _obtenerUsuarios() async {
    return await obtenerUsuarios(ApiDefinition.ipServer);
  }

  Widget _listarUsuariosBuilder(StateSetter actualizar) {
    return FutureBuilder(
      future: _obtenerUsuarios(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _listaUsuarios = snapshot.data;
          // _listaUsuarios.insert(
          //   0,
          //   Usuario(
          //       idUsuario: 0,
          //       nombre: 'TODOS',
          //       usuario: 'TODOS',
          //       correo: '_correo',
          //       telefono: '_telefono',
          //       ubicacion: '_ubicacion',
          //       jefeInmediato: '_jefeInmediato',
          //       perfil: Perfil(),
          //       password: '_password',
          //       passTemp: 0),
          // );
          return ListaUsuarios(
            controllerUsuarios: _controllerUsuarios,
            listaUsuarios: _listaUsuarios,
            usuariosSeleccionado: _usuariosSeleccionados,
            actualizar: actualizar,
            usuarioSeleccionadoAccion: _usuarioSeleccionadoAccion,
            tipoBusqueda: 'MULTIPLE',
            limiteSeleccion: 3,
          );
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  void _registrosSeleccionadosEnCero() {
    for (Inventario registro in _listaRegistros) {
      _registroSeleccion[registro.idinventario!] = false;
    }
    if (_registroProvider.mostrarMasOpciones) {
      _registroProvider.mostrarMasOpciones = false;
    }
  }

  Future<void> _usuarioSeleccionadoAccion(
      BuildContext context,
      Usuario usuarioSeleccionado,
      List<Usuario> usuariosSeleccionados,
      StateSetter actualizar) async {
    // if (usuarioSeleccionado != null) {
    //   _usuariosSeleccionados = usuariosSeleccionados;
    //   _usuarioSeleccionado = usuarioSeleccionado;
    //   _controllerUsuarios.text = usuarioSeleccionado.usuario.toUpperCase();
    //   _proyectoSeleccionado = null;
    //   _listaProyectos = [];
    //   _listaRegistros = [];
    //   _mostrarBusqueda = false;
    //   _registrosSeleccionadosEnCero();
    //   PantallaDeCarga.loadingI(context, true);

    //   if (usuarioSeleccionado.usuario == 'TODOS') {
    //     _listaProyectos = await obtenerProyectos(ApiDefinition.ipServer);
    //   } else {
    //     _listaProyectos = [];
    //     if (_usuariosSeleccionados.isNotEmpty) {
    //       for (Usuario usuario in _usuariosSeleccionados) {
    //         _listaProyectos.addAll(await obtenerProyectosAsignados(
    //             ApiDefinition.ipServer, usuario));
    //         // _listaProyectos.insert(
    //         //     0, Proyecto(idproyecto: 0, proyecto: 'TODOS'));
    //       }
    //     }
    //   }
    //   PantallaDeCarga.loadingI(context, false);
    // } else {
    //   // _listaProyectos = [];
    //   // _proyectoSeleccionado = null;
    //   _listaRegistros = _listaRegistrosCompleta;
    // }
    if (usuarioSeleccionado != null) {
      _usuariosSeleccionados = usuariosSeleccionados;
      _usuarioSeleccionado = usuarioSeleccionado;
      _controllerUsuarios.text = usuarioSeleccionado.usuario!.toUpperCase();
      _listaRegistros = [];
      _registrosSeleccionadosEnCero();
      PantallaDeCarga.loadingI(context, true);
      for (Usuario usuario in _usuariosSeleccionados) {
        //TODO: almacenar los id inventario de los usuarios
        List<Inventario> respuesta = await obtenerRegistrosUsuarioProyecto(
            ApiDefinition.ipServer, usuario, _proyectoSeleccionado!);
        List<int> inventarios = [];
        respuesta.forEach((element) {
          inventarios.add(element.idinventario!);
        });
        _relacionUsuarioInventario.addAll({usuario.idUsuario!: inventarios});
        _listaRegistros.addAll(respuesta);
      }

      PantallaDeCarga.loadingI(context, false);
    } else {
      _listaRegistros = _listaRegistrosCompleta;
    }
    actualizar(() {});
  }

  Widget _listarProyectos(BuildContext context, StateSetter actualizar) {
    if (VariablesGlobales.usuario.perfil!.idperfil == '1' ||
        VariablesGlobales.usuario.perfil!.idperfil == '2' ||
        VariablesGlobales.usuario.perfil!.idperfil == '3' ||
        VariablesGlobales.usuario.perfil!.idperfil == '4') {
      return Container(
        width: 300.0,
        child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Proyectos',
          ),
          value: _proyectoSeleccionado,
          onChanged: (Proyecto? valor) async {
            _proyectoSeleccionado = valor!;
            PantallaDeCarga.loadingI(context, true);
            _listaRegistros = [];
            _relacionUsuarioInventario = {};
            _listaRegistros = await getRegistrosPorProyecto(
                ApiDefinition.ipServer, _proyectoSeleccionado!);
            print('Lista Registros obtenida: ${_listaRegistros.length}');

            // for (Usuario usuario in _usuariosSeleccionados) {
            //   //TODO: almacenar los id inventario de los usuarios
            //   List<Inventario> respuesta =
            //       await obtenerRegistrosUsuarioProyecto(
            //           ApiDefinition.ipServer, usuario, _proyectoSeleccionado);
            //   List<int> inventarios = [];
            //   respuesta.forEach((element) {
            //     inventarios.add(element.idinventario);
            //   });
            //   _relacionUsuarioInventario
            //       .addAll({usuario.idUsuario: inventarios});
            //   _listaRegistros.addAll(respuesta);
            // }
            // print('Relacion Usuario-Inventario: $_relacionUsuarioInventario');

            _listaRegistrosCompleta = _listaRegistros;
            _controllerBusqueda.text = '';
            _opciones = await obtenerCamposProyectoBusqueda(
                ApiDefinition.ipServer, _proyectoSeleccionado!.idproyecto!);
            _opciones!.insert(0, '');
            _opciones!.insert(1, 'ESTATUS');
            if (_listaRegistros.isNotEmpty) {
              _mostrarBusqueda = true;
            }
            _busquedaSeleccionada = '';
            _registrosSeleccionadosEnCero();
            PantallaDeCarga.loadingI(context, false);
            actualizar(() {});
          },
          items: _listaProyectos.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item.proyecto!),
            );
          }).toList(),
          validator: (Proyecto? value) {
            if (value == null) {
              return 'Selecciona un proyecto';
            } else {
              return null;
            }
          },
        ),
      );
    } else {
      _usuarioSeleccionado = VariablesGlobales.usuario;
      return FutureBuilder(
          future: obtenerProyectosAsignados(
              ApiDefinition.ipServer, VariablesGlobales.usuario),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (_listaProyectos.isEmpty) {
                _listaProyectos = snapshot.data;
              }
              return _dropProyectos(context, actualizar, _listaProyectos);
            } else {
              return Container(
                width: 300.0,
                child: LinearProgressIndicator(),
              );
            }
          });
    }
  }

  Widget _dropProyectos(
      BuildContext context, StateSetter actualizar, List<Proyecto> lista) {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Proyectos',
        ),
        value: _proyectoSeleccionado,
        onChanged: (Proyecto? valor) async {
          // _proyectoSeleccionado = valor;
          // PantallaDeCarga.loadingI(context, true);
          // _listaRegistros = await obtenerRegistrosUsuarioProyecto(
          //     ApiDefinition.ipServer,
          //     VariablesGlobales.usuario,
          //     _proyectoSeleccionado);
          // _listaRegistrosCompleta = _listaRegistros;
          // _controllerBusqueda.text = '';
          // _opciones = await obtenerCamposProyectoBusqueda(
          //     ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto);
          // _opciones.insert(0, 'ESTATUS');

          // if (_listaRegistros.isNotEmpty) {
          //   _mostrarBusqueda = true;
          // }
          // _busquedaSeleccionada = null;
          // for (Inventario registro in _listaRegistros) {
          //   _registroSeleccion[registro.idinventario] = false;
          // }
          // PantallaDeCarga.loadingI(context, false);
          // actualizar(() {});

          _proyectoSeleccionado = valor!;
          PantallaDeCarga.loadingI(context, true);
          _listaRegistros = [];
          _relacionUsuarioInventario = {};
          _listaRegistros = await getRegistrosPorProyecto(
              ApiDefinition.ipServer, _proyectoSeleccionado!);
          print('Lista Registros obtenida: ${_listaRegistros.length}');
          // for (Usuario usuario in _usuariosSeleccionados) {
          //   //TODO: almacenar los id inventario de los usuarios
          //   List<Inventario> respuesta =
          //       await obtenerRegistrosUsuarioProyecto(
          //           ApiDefinition.ipServer, usuario, _proyectoSeleccionado);
          //   List<int> inventarios = [];
          //   respuesta.forEach((element) {
          //     inventarios.add(element.idinventario);
          //   });
          //   _relacionUsuarioInventario
          //       .addAll({usuario.idUsuario: inventarios});
          //   _listaRegistros.addAll(respuesta);
          // }
          // print('Relacion Usuario-Inventario: $_relacionUsuarioInventario');
          _listaRegistrosCompleta = _listaRegistros;
          _controllerBusqueda.text = '';
          _opciones = await obtenerCamposProyectoBusqueda(
              ApiDefinition.ipServer, _proyectoSeleccionado!.idproyecto!);
          _opciones!.insert(0, 'ESTATUS');
          if (_listaRegistros.isNotEmpty) {
            _mostrarBusqueda = true;
          }
          _busquedaSeleccionada = '';
          _registrosSeleccionadosEnCero();
          PantallaDeCarga.loadingI(context, false);
          actualizar(() {});
        },
        items: _listaProyectos.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.proyecto!),
          );
        }).toList(),
        validator: (Proyecto? value) {
          if (value == null) {
            return 'Selecciona un proyecto';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _listarOpcionesBusqueda(BuildContext context, StateSetter actualizar) {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Buscar Por',
        ),
        value: _busquedaSeleccionada,
        onChanged: (String? valor) async {
          _busquedaSeleccionada = valor!;
          _listaBusqueda = [''];
          _controllerBusqueda.text = '';
          if (valor == 'ESTATUS') {
            _listaBusqueda!.add('NUEVO');
            _listaBusqueda!.add('ASIGNADO');
            _listaBusqueda!.add('EN PROCESO');
            _listaBusqueda!.add('PENDIENTE');
            _listaBusqueda!.add('CERRADO');
          } else if (valor == 'FOLIO') {
            for (Inventario registro in _listaRegistrosCompleta) {
              _listaBusqueda!.add(registro.folio!);
            }
          } else if (valor == 'PROYECTO') {
            for (Inventario registro in _listaRegistrosCompleta) {
              if (!_listaBusqueda!.contains(registro.proyecto!.proyecto)) {
                _listaBusqueda!.add(registro.proyecto!.proyecto!);
              }
            }
          } else {
            PantallaDeCarga.loadingI(context, true);
            _listaBusqueda = [''];
            if (_usuariosSeleccionados.isEmpty) {
              _listaBusqueda!.addAll(await obtenerValoresBusqueda(
                  ApiDefinition.ipServer,
                  _proyectoSeleccionado!.idproyecto!,
                  0,
                  valor));
            } else {
              for (Usuario usuario in _usuariosSeleccionados) {
                _listaBusqueda!.addAll(await obtenerValoresBusqueda(
                    ApiDefinition.ipServer,
                    _proyectoSeleccionado!.idproyecto!,
                    usuario.idUsuario!,
                    valor));
              }
            }
            PantallaDeCarga.loadingI(context, false);
          }
          actualizar(() {});
        },
        items: _opciones!.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  _mostrarCampos(BuildContext context, Proyecto proyecto,
      StateSetter actualizar, bool nuevo) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(child: Text('PROYECTO: ${proyecto.proyecto}')),
                      nuevo
                          ? Container()
                          : Container(
                              child: Text(
                                  'Registro: ${_registroSeleccionado.folio}')),
                    ],
                  ),
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
              EditarRegistro(
                size: size,
                proyecto: proyecto,
                formKeyRegistro: _formKeyRegistro,
                usuarioSeleccionado: _usuarioSeleccionado != null
                    ? _usuarioSeleccionado!
                    : VariablesGlobales.usuario,
                inventarioSeleccionado: _registroSeleccionado,
                registroProvider: _registroProvider,
                actualizar: actualizar,
                nuevo: nuevo,
              )
              // Center(
              //   child: size.width > 700
              //       ? StatefulBuilder(
              //           builder: (BuildContext context, StateSetter setState) {
              //           _setState = setState;
              //           return _cargarCampos(
              //               context, 'columna', proyecto, setState);
              //         })
              //       : StatefulBuilder(
              //           builder: (BuildContext context, StateSetter setState) {
              //           _setState = setState;
              //           return _cargarCampos(
              //               context, 'fila', proyecto, setState);
              //         }),
              // ),
              // Container(
              //   margin: EdgeInsets.only(left: 20.0),
              //   child: Row(
              //     children: [
              //       Container(
              //           padding: EdgeInsets.only(top: 10.0, right: 10.0),
              //           alignment: Alignment.centerRight,
              //           child: ElevatedButton(
              //             onPressed: () async {
              //               PantallaDeCarga.loadingI(context, true);
              //               _formKeyRegistro.currentState.save();
              //               List<ValoresCampos> valores = [];
              //               for (Agrupaciones agrupaciones
              //                   in _registroProvider.listaAgrupaciones) {
              //                 for (Campos item in agrupaciones.campos) {
              //                   try {
              //                     print('Valor: ${item.valorController.text}');
              //                     valores.add(ValoresCampos(
              //                       valor: item.valorController.text,
              //                       idcampoproyecto: item.idCampo,
              //                       idinventario:
              //                           _registroSeleccionado.idRegistro,
              //                     ));

              //                     if (item.tipoCampo == 'CATALOGO-INPUT') {
              //                       if (item.valorController.text.isNotEmpty) {
              //                         await nuevoCatalogoAutoCompleteUsuario(
              //                             ApiDefinition.ipServer,
              //                             item.nombreCampo,
              //                             proyecto.idproyecto,
              //                             _usuarioSeleccionado.idUsuario,
              //                             item.valorController.text);
              //                       }
              //                     }
              //                   } catch (e) {
              //                     print(
              //                         'Error en el ordenamiento de datos: $e');
              //                   }
              //                 }
              //               }
              //               PantallaDeCarga.loadingI(context, false);
              //               Dialogos.advertencia(context,
              //                   'Seguro que quieres guardar los cambios?',
              //                   () async {
              //                 PantallaDeCarga.loadingI(context, true);

              //                 await actualizarValoresCampos(
              //                     ApiDefinition.ipServer, valores);
              //                 await _guardarFirmas(_registroSeleccionado);
              //                 await eliminarEvidencia(ApiDefinition.ipServer,
              //                     _registroSeleccionado.idRegistro);
              //                 await _guardarEvidencias(
              //                     _registroSeleccionado.idRegistro);
              //                 await _guardarEvidencia(
              //                     _registroSeleccionado.idRegistro);
              //                 Future.delayed(Duration(seconds: 5), () {
              //                   PantallaDeCarga.loadingI(context, false);
              //                   Navigator.pop(context);
              //                   Navigator.pop(context);
              //                 });
              //               });
              //             },
              //             child: Text('Aceptar'),
              //           )),
              //       Container(
              //           padding: EdgeInsets.only(top: 10.0, right: 10.0),
              //           alignment: Alignment.centerRight,
              //           child: ElevatedButton(
              //             onPressed: () {
              //               Navigator.of(context).pop();
              //             },
              //             child: Text('Cancelar'),
              //           )),
              //     ],
              //   ),
              // ),
            ],
          );
        });
  }

  _mostrarCamposAsignarEdicion(BuildContext context, Proyecto proyecto) async {
    String respuesta = await showDialog(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(child: Text('PROYECTO: ${proyecto.proyecto}')),
                      Container(
                          child:
                              Text('Registro: ${_registroSeleccionado.folio}')),
                    ],
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            _camposSeleccionados['Todos'] = false;
                            for (int i = 0;
                                i < _registroProvider.listaAgrupaciones.length;
                                i++) {
                              for (int j = 0;
                                  j <
                                      _registroProvider.listaAgrupaciones
                                          .elementAt(i)
                                          .campos!
                                          .length;
                                  j++) {
                                _camposSeleccionados[_registroProvider
                                    .listaAgrupaciones
                                    .elementAt(i)
                                    .campos!
                                    .elementAt(j)
                                    .nombreCampo!] = false;
                              }
                              _agrupacionesSeleccionadas[_registroProvider
                                  .listaAgrupaciones
                                  .elementAt(i)
                                  .agrupacion!] = false;
                            }
                            if (_listaCamposAsignados.isNotEmpty) {
                              for (EdicionAsignada edicion
                                  in _listaCamposAsignados) {
                                _camposSeleccionados[
                                    edicion.camposProyecto!.campo!] = true;
                              }
                            }
                            _setState(() {});
                          },
                          child: Text('Restablecer seleccion anterior')),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop('cancelado');
                          },
                          icon: Icon(Icons.close)),
                    ],
                  )
                ],
              ),
            ),
            children: <Widget>[
              Center(
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  _setState = setState;
                  return _cargarCamposAEditar(context, proyecto, setState);
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
                            if (_estatusRegistro == 'PENDIENTE') {
                              print('Dentro de pendiente');
                              if (_formKeyEditarAsignacion.currentState!
                                  .validate()) {
                                PantallaDeCarga.loadingI(context, true);
                                Estatus estatus = Estatus(
                                    agrupacion: _agrupacionSeleccionada,
                                    estatus: 'PENDIENTE',
                                    motivo: _motivoRegistro,
                                    descripcion: _controllerDescripcion.text,
                                    inventario: _registroSeleccionado);

                                await cambiarEstatus(
                                    ApiDefinition.ipServer, estatus);
                                PantallaDeCarga.loadingI(context, false);
                                await _obtenerRegistros();

                                Navigator.of(context).pop('echo');
                              }
                            } else {
                              print('Fuera de pendiente');
                              PantallaDeCarga.loadingI(context, true);
                              Estatus estatus = Estatus(
                                  agrupacion: _agrupacionSeleccionada,
                                  estatus: _estatusRegistro,
                                  motivo: _motivoRegistro,
                                  descripcion: _controllerDescripcion.text,
                                  inventario: _registroSeleccionado);

                              await cambiarEstatus(
                                  ApiDefinition.ipServer, estatus);

                              await _obtenerRegistros();

                              List<EdicionAsignada> listaEdicionSeleccionada =
                                  [];

                              for (Agrupaciones agrupacion
                                  in _registroProvider.listaAgrupaciones) {
                                for (Campos campo in agrupacion.campos!) {
                                  if (_camposSeleccionados[
                                      campo.nombreCampo]!) {
                                    EdicionAsignada aux = EdicionAsignada(
                                      idedicion: 0,
                                      camposProyecto: CamposProyecto(
                                        idcamposproyecto: campo.idCampo,
                                        campo: campo.nombreCampo,
                                        tipocampo: campo.tipoCampo,
                                      ),
                                      inventario: Inventario(
                                        idinventario:
                                            _registroSeleccionado.idinventario,
                                        estatus: _registroSeleccionado.estatus,
                                        fechacreacion:
                                            _registroSeleccionado.fechacreacion,
                                        folio: _registroSeleccionado.folio,
                                        proyecto:
                                            _registroSeleccionado.proyecto,
                                      ),
                                      usuario: _usuarioSeleccionado,
                                    );
                                    listaEdicionSeleccionada.add(aux);
                                  }
                                }
                              }
                              print(
                                  'Total de campos seleccionados: ${listaEdicionSeleccionada.length}');
                              await asignarEdicion(ApiDefinition.ipServer,
                                  listaEdicionSeleccionada);

                              PantallaDeCarga.loadingI(context, false);

                              Navigator.of(context).pop('echo');
                            }
                            // Database db = database();
                            // DatabaseReference ref = db.ref('TotalDatos');

                            // await ref
                            //     .child(_registroSeleccionado.proyecto.proyecto)
                            //     .set({
                            //   'NUEVO': Random().nextInt(100),
                            //   'ASIGNADO': Random().nextInt(100),
                            //   'PENDIENTE': Random().nextInt(100),
                            //   'EN PROCESO': Random().nextInt(100),
                            //   'CERRADO': Random().nextInt(100),
                            // });
                          },
                          child: Text('Aceptar'),
                        )),
                    Container(
                        padding: EdgeInsets.only(top: 10.0, right: 10.0),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop('cancelado');
                          },
                          child: Text('Cancelar'),
                        )),
                  ],
                ),
              ),
            ],
          );
        });
    print('Respuesta: $respuesta');
    // _setState(() {});
  }

  Future<void> _obtenerRegistros() async {
    _listaRegistros = [];
    _listaRegistros = await obtenerRegistrosUsuarioProyecto(
        ApiDefinition.ipServer, _usuarioSeleccionado!, _proyectoSeleccionado!);
  }

  _guardarFirmas(Inventario registro) async {
    for (String firma in _registroProvider.firmas.keys) {
      if (_registroProvider.comprobarFirmas[firma]!) {
        List<int> firmaInt = [];
        Uint8List byte = _registroProvider.firmas[firma]!.buffer.asUint8List(
            _registroProvider.firmas[firma]!.offsetInBytes,
            _registroProvider.firmas[firma]!.lengthInBytes);
        firmaInt = byte.cast<int>();

        Firma datosFirma = Firma(
          firma: firmaInt,
          idCampo: _obtenerIdCampo(firma),
          idInventario: registro.idinventario,
          nombreFirma: firma,
        );
        await actualizarFirmas(ApiDefinition.ipServer, datosFirma);
      }
    }
  }

  _guardarEvidencia(int idRegistro) async {
    for (String evidencia in _registroProvider.evidencia.keys) {
      if (_registroProvider.comprobarFotos[evidencia]!) {
        List<int> evidenciaInt = [];
        Uint8List byte = _registroProvider.evidencia[evidencia]!;
        evidenciaInt = byte.cast<int>();

        Evidencia datosFirma = Evidencia(
          evidencia: evidenciaInt,
          idCampo: _obtenerIdCampo(evidencia),
          idInventario: idRegistro,
          nombreEvidencia: evidencia,
        );
        await actualizarEvidencia(ApiDefinition.ipServer, datosFirma,
            _usuarioSeleccionado!.idUsuario!);
      }
    }
  }

  Future<void> _guardarEvidencias(int idRegistro) async {
    if (_registroProvider.evidenciaCheckList.isNotEmpty) {
      _registroProvider.evidenciaCheckList.forEach((key, value) {
        value.forEach((nombre, valor) async {
          List<int> evidenciaArray = valor.cast<int>();

          Evidencia fotoEvidencia = Evidencia(
            idEvidencia: 0,
            evidencia: evidenciaArray,
            idCampo: _obtenerIdCampo(key),
            idInventario: idRegistro,
            nombreEvidencia: nombre,
          );

          await actualizarEvidencia(ApiDefinition.ipServer, fotoEvidencia,
              VariablesGlobales.usuario.idUsuario!);
        });
      });
    }
  }

  int _obtenerIdCampo(String campoARecuperar) {
    int respuesta = 0;
    for (Agrupaciones agrupacion in _registroProvider.listaAgrupaciones) {
      for (Campos campo in agrupacion.campos!) {
        if (campoARecuperar == campo.nombreCampo) {
          respuesta = campo.idCampo!;
          break;
        }
      }
    }

    return respuesta;
  }

  Widget _cargarCampos(BuildContext context, String orientacion,
      Proyecto proyecto, StateSetter actualizar) {
    return Form(
      key: _formKeyRegistro,
      child: Container(
        width: orientacion == 'columna'
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        child: ListView.builder(
          itemCount: _registroProvider.listaAgrupaciones.length,
          itemBuilder: (BuildContext context, int index) {
            print(_registroProvider.listaAgrupaciones
                .elementAt(index)
                .agrupacion);
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
                    '${_registroProvider.listaAgrupaciones.elementAt(index).agrupacion}'),
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

  Widget _cargarCamposAEditar(
      BuildContext context, Proyecto proyecto, StateSetter actualizar) {
    return Form(
      key: _formKeyEditarAsignacion,
      child: Container(
        width: MediaQuery.of(context).size.width > 1600
            ? MediaQuery.of(context).size.width * 0.7
            : MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        child: ListView.builder(
          itemCount: _registroProvider.listaAgrupaciones.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                index == 0
                    ? MediaQuery.of(context).size.width > 800
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                                elevation: 2,
                                margin:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Row(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          width: 100.0,
                                          child: Text('Estatus registro'),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 20.0),
                                          width: 200.0,
                                          height: 100.0,
                                          child: DropdownButtonFormField(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Estatus',
                                            ),
                                            value: _estatusRegistro,
                                            onChanged: (String? valor) async {
                                              _estatusRegistro = valor!;
                                              actualizar(() {});
                                            },
                                            items: _listaEstatusRegistro
                                                .map((item) {
                                              return DropdownMenuItem(
                                                value: item,
                                                child: Text(item),
                                              );
                                            }).toList(),
                                            validator: (String? value) {
                                              if (value == null) {
                                                return 'Selecciona un estatus';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    _estatusRegistro == 'PENDIENTE'
                                        ? Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10.0,
                                                      left: 20.0,
                                                    ),
                                                    width: 100.0,
                                                    child: Text('Motivo'),
                                                  ),
                                                  Container(
                                                    width: 200.0,
                                                    child:
                                                        DropdownButtonFormField(
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'Motivo',
                                                      ),
                                                      value: _motivoRegistro,
                                                      onChanged: (String?
                                                          valor) async {
                                                        _motivoRegistro =
                                                            valor!;
                                                        actualizar(() {});
                                                      },
                                                      items:
                                                          _listaPendienteRegistro
                                                              .map((item) {
                                                        return DropdownMenuItem(
                                                          value: item,
                                                          child: Text(item),
                                                        );
                                                      }).toList(),
                                                      validator:
                                                          (String? value) {
                                                        if (value == null) {
                                                          return 'Selecciona un motivo';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10.0,
                                                      left: 20.0,
                                                    ),
                                                    width: 100.0,
                                                    child: Text('Descripcion'),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 20.0),
                                                    width: 200.0,
                                                    child: TextFormField(
                                                      controller:
                                                          _controllerDescripcion,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Colors.white,
                                                          hintText:
                                                              'DESCRIPCION'),
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .characters,
                                                      inputFormatters: <TextInputFormatter>[
                                                        UpperCaseTextFormatter(),
                                                      ],
                                                      maxLength: 100,
                                                      validator: (value) {
                                                        if (value!.isNotEmpty) {
                                                          return null;
                                                        } else {
                                                          return 'INGRESE LA DESCRIPCION';
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10.0,
                                                      left: 20.0,
                                                    ),
                                                    width: 100.0,
                                                    child: Text('Agrupacion'),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 20.0),
                                                    width: 150.0,
                                                    height: 100.0,
                                                    child:
                                                        DropdownButtonFormField(
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'Agrupacion',
                                                      ),
                                                      value:
                                                          _agrupacionSeleccionada,
                                                      onChanged: (String?
                                                          valor) async {
                                                        _agrupacionSeleccionada =
                                                            valor!;
                                                        actualizar(() {});
                                                      },
                                                      items: _registroProvider
                                                          .listaAgrupaciones
                                                          .map((item) {
                                                        return DropdownMenuItem(
                                                          value:
                                                              item.agrupacion,
                                                          child: Text(
                                                              item.agrupacion!),
                                                        );
                                                      }).toList(),
                                                      validator:
                                                          (String? value) {
                                                        if (value == null) {
                                                          return 'Selecciona un estatus';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                )),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                                elevation: 2,
                                margin:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          width: 150.0,
                                          child: Text('Estatus registro'),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 20.0),
                                          width: 150.0,
                                          height: 100.0,
                                          child: DropdownButtonFormField(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Estatus',
                                            ),
                                            value: _estatusRegistro,
                                            onChanged: (String? valor) async {
                                              _estatusRegistro = valor!;
                                              actualizar(() {});
                                            },
                                            items: _listaEstatusRegistro
                                                .map((item) {
                                              return DropdownMenuItem(
                                                value: item,
                                                child: Text(item),
                                              );
                                            }).toList(),
                                            validator: (String? value) {
                                              if (value == null) {
                                                return 'Selecciona un estatus';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    _estatusRegistro == 'PENDIENTE'
                                        ? Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            left: 20.0,
                                                            right: 20.0),
                                                    width: 150.0,
                                                    child: Text('Motivo'),
                                                  ),
                                                  Container(
                                                    width: 150.0,
                                                    child:
                                                        DropdownButtonFormField(
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'Motivo',
                                                      ),
                                                      value: _motivoRegistro,
                                                      onChanged: (String?
                                                          valor) async {
                                                        _motivoRegistro =
                                                            valor!;
                                                        actualizar(() {});
                                                      },
                                                      items:
                                                          _listaPendienteRegistro
                                                              .map((item) {
                                                        return DropdownMenuItem(
                                                          value: item,
                                                          child: Text(item),
                                                        );
                                                      }).toList(),
                                                      validator:
                                                          (String? value) {
                                                        if (value == null) {
                                                          return 'Selecciona un motivo';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            left: 20.0,
                                                            right: 20.0),
                                                    width: 150.0,
                                                    child: Text('Descripcion'),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 20.0),
                                                    width: 150.0,
                                                    child: TextFormField(
                                                      controller:
                                                          _controllerDescripcion,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                          fillColor:
                                                              Colors.white,
                                                          hintText:
                                                              'DESCRIPCION'),
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .characters,
                                                      inputFormatters: <TextInputFormatter>[
                                                        UpperCaseTextFormatter(),
                                                      ],
                                                      maxLength: 100,
                                                      validator:
                                                          (String? value) {
                                                        if (value!.isNotEmpty) {
                                                          return null;
                                                        } else {
                                                          return 'INGRESE LA DESCRIPCION';
                                                        }
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0,
                                                            left: 20.0,
                                                            right: 20.0),
                                                    width: 150.0,
                                                    child: Text('Agrupacion'),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 20.0),
                                                    width: 150.0,
                                                    height: 100.0,
                                                    child:
                                                        DropdownButtonFormField(
                                                      isExpanded: true,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        hintText: 'Agrupacion',
                                                      ),
                                                      value:
                                                          _agrupacionSeleccionada,
                                                      onChanged: (String?
                                                          valor) async {
                                                        _agrupacionSeleccionada =
                                                            valor!;
                                                        actualizar(() {});
                                                      },
                                                      items: _registroProvider
                                                          .listaAgrupaciones
                                                          .map((item) {
                                                        return DropdownMenuItem(
                                                          value:
                                                              item.agrupacion,
                                                          child: Text(
                                                              item.agrupacion!),
                                                        );
                                                      }).toList(),
                                                      validator:
                                                          (String? value) {
                                                        if (value == null) {
                                                          return 'Selecciona un estatus';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        : Container(),
                                  ],
                                )),
                          )
                    : Container(),
                index == 0
                    ? Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              elevation: 1,
                              margin: EdgeInsets.only(
                                  top: 15.0, left: 30.0, right: 30.0),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Seleccionar todos'),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                                elevation: 2,
                                margin:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text('Todos'),
                                    ),
                                    Expanded(child: Container()),
                                    Checkbox(
                                        value: _camposSeleccionados['Todos'],
                                        onChanged: (bool? valor) {
                                          actualizar(() {
                                            _camposSeleccionados['Todos'] =
                                                valor!;
                                            for (Agrupaciones agrupacion
                                                in _registroProvider
                                                    .listaAgrupaciones) {
                                              _agrupacionesSeleccionadas[
                                                      agrupacion.agrupacion!] =
                                                  valor;
                                              for (Campos campo
                                                  in agrupacion.campos!) {
                                                _camposSeleccionados[
                                                    campo.nombreCampo!] = valor;
                                              }
                                            }
                                          });
                                        })
                                  ],
                                )),
                          ),
                        ],
                      )
                    : Container(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(_registroProvider.listaAgrupaciones
                              .elementAt(index)
                              .agrupacion!),
                        ),
                        Expanded(child: Container()),
                        Checkbox(
                            value: _agrupacionesSeleccionadas[_registroProvider
                                .listaAgrupaciones
                                .elementAt(index)
                                .agrupacion],
                            onChanged: (bool? valor) {
                              actualizar(() {
                                _agrupacionesSeleccionadas[_registroProvider
                                    .listaAgrupaciones
                                    .elementAt(index)
                                    .agrupacion!] = valor!;
                                if (_camposSeleccionados['Todos']!) {
                                  _camposSeleccionados['Todos'] = false;
                                }
                                for (Agrupaciones agrupacion
                                    in _registroProvider.listaAgrupaciones) {
                                  for (Campos campo in agrupacion.campos!) {
                                    if (campo.agrupacion ==
                                        _registroProvider.listaAgrupaciones
                                            .elementAt(index)
                                            .agrupacion) {
                                      _camposSeleccionados[campo.nombreCampo!] =
                                          valor;
                                    }
                                  }
                                }

                                bool todasLasAgrupaciones = true;

                                for (Agrupaciones agrupacion
                                    in _registroProvider.listaAgrupaciones) {
                                  if (!_agrupacionesSeleccionadas[
                                      agrupacion.agrupacion]!) {
                                    todasLasAgrupaciones = false;
                                    print(
                                        'Dentro del if agrupciones: ${agrupacion.agrupacion}');
                                    break;
                                  }
                                }

                                if (todasLasAgrupaciones) {
                                  _camposSeleccionados['Todos'] = true;
                                } else {
                                  _camposSeleccionados['Todos'] = false;
                                }
                              });
                            })
                      ],
                    ),
                  ),
                ),
                for (int i = 0;
                    i <
                        _registroProvider.listaAgrupaciones
                            .elementAt(index)
                            .campos!
                            .length;
                    i++)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                        elevation: 2,
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(_registroProvider.listaAgrupaciones
                                  .elementAt(index)
                                  .campos!
                                  .elementAt(i)
                                  .nombreCampo!),
                            ),
                            Expanded(child: Container()),
                            Checkbox(
                                value: _camposSeleccionados[_registroProvider
                                    .listaAgrupaciones
                                    .elementAt(index)
                                    .campos!
                                    .elementAt(i)
                                    .nombreCampo],
                                onChanged: (bool? valor) {
                                  actualizar(() {
                                    _camposSeleccionados[_registroProvider
                                        .listaAgrupaciones
                                        .elementAt(index)
                                        .campos!
                                        .elementAt(i)
                                        .nombreCampo!] = valor!;
                                    if (_camposSeleccionados['Todos']!) {
                                      _camposSeleccionados['Todos'] = false;
                                    }
                                    bool todos = true;
                                    bool todasLasAgrupaciones = true;
                                    for (Campos campo in _registroProvider
                                        .listaAgrupaciones
                                        .elementAt(index)
                                        .campos!) {
                                      if (!_camposSeleccionados[
                                          campo.nombreCampo]!) {
                                        print(
                                            'Dentro del if: ${campo.nombreCampo}');
                                        todos = false;
                                        break;
                                      }
                                    }

                                    if (todos) {
                                      _agrupacionesSeleccionadas[
                                          _registroProvider.listaAgrupaciones
                                              .elementAt(index)
                                              .agrupacion!] = true;
                                    } else {
                                      _agrupacionesSeleccionadas[
                                          _registroProvider.listaAgrupaciones
                                              .elementAt(index)
                                              .agrupacion!] = false;
                                    }
                                    for (Agrupaciones agrupacion
                                        in _registroProvider
                                            .listaAgrupaciones) {
                                      if (!_agrupacionesSeleccionadas[
                                          agrupacion.agrupacion]!) {
                                        todasLasAgrupaciones = false;
                                        print(
                                            'Dentro del if agrupciones: ${agrupacion.agrupacion}');
                                        break;
                                      }
                                    }

                                    if (todasLasAgrupaciones) {
                                      _camposSeleccionados['Todos'] = true;
                                    } else {
                                      _camposSeleccionados['Todos'] = false;
                                    }
                                  });
                                })
                          ],
                        )),
                  ),
              ],
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
                _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos!
                    .length;
            i++)
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _nombreCampo(
                    '${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos!.elementAt(i).nombreCampo}'),
                TipoDeCampos(
                    indAgrupacion: indAgrupacion,
                    indCampo: i,
                    proyecto: proyecto,
                    actualizar: actualizar),
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
                _registroProvider.listaAgrupaciones
                    .elementAt(indAgrupacion)
                    .campos!
                    .length;
            i++)
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _nombreCampo(
                    '${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos!.elementAt(i).nombreCampo}'),
                SizedBox(
                  width: 10.0,
                ),
                TipoDeCampos(
                    indAgrupacion: indAgrupacion,
                    indCampo: i,
                    proyecto: proyecto,
                    actualizar: actualizar),
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

  Widget _nombreCampo(String titulo) {
    return Container(
        width: 250.0,
        child: Center(
          child: Tooltip(
            message: titulo,
            textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            margin: EdgeInsets.only(left: 50.0, right: 50.0),
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              maxLines: 100,
              softWrap: false,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ));
  }
}


// Consulta ISSSTE
// SELECT * FROM `vista_datos_issste` WHERE idinventario IN (SELECT idinventario FROM `inventario` WHERE fechacreacion BETWEEN '2022-08-22 00:00:00' AND '2022-09-08 00:00:00' AND idproyecto=116) AND CODIGODEBARRAS != 'NO'