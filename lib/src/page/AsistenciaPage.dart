import 'package:app_isae_desarrollo/src/models/Asistencia.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/ListaUsuarios.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:intl/intl.dart';

import '../models/Perfil.dart';
import '../models/Usuario.dart';

class AsistenciaPage extends StatefulWidget {
  AsistenciaPage({Key? key}) : super(key: key);

  @override
  _AsistenciaPageState createState() => _AsistenciaPageState();
}

class _AsistenciaPageState extends State<AsistenciaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollTabla = ScrollController();
  DateTime _diaSeleccionadoInicio = DateTime.now();
  DateTime _diaSeleccionadoFinal = DateTime.now();
  TextEditingController _controllerBuscar = TextEditingController();

  List<Usuario> _listaUsuarios = [];
  List<Usuario> _listaAMostrar = [];
  List<Perfil> _listaPerfiles = [];
  Usuario? _usuarioSeleccionado;
  bool filtro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      endDrawer: DrawerPrincipal(),
      body: _contenido(),
    );
  }

  Widget _contenido() {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'Asistencia'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            Container(
              child: Tarjetas.tarjeta(
                  MediaQuery.of(context).size,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      size.width > 800
                          ? Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Fecha inicio'),
                                  Container(
                                    margin: EdgeInsets.only(left: 20.0),
                                    width: 200.0,
                                    child: _obtenerFecha('inicio'),
                                  ),
                                  SizedBox(
                                    width: 50.0,
                                  ),
                                  Text('Fecha final'),
                                  Container(
                                    margin: EdgeInsets.only(left: 20.0),
                                    width: 200.0,
                                    child: _obtenerFecha('final'),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Fecha inicio'),
                                  Container(
                                    margin: EdgeInsets.only(left: 20.0),
                                    width: 200.0,
                                    child: _obtenerFecha('inicio'),
                                  ),
                                  SizedBox(
                                    height: 30.0,
                                  ),
                                  Text('Fecha final'),
                                  Container(
                                    margin: EdgeInsets.only(left: 20.0),
                                    width: 200.0,
                                    child: _obtenerFecha('final'),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 30.0,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            PantallaDeCarga.loadingI(context, true);
                            print(
                                'Fecha inicio: ${_diaSeleccionadoInicio.year}-${_diaSeleccionadoInicio.month}-${_diaSeleccionadoInicio.day}');
                            print(
                                'Fecha Final: ${_diaSeleccionadoFinal.year}-${_diaSeleccionadoFinal.month}-${_diaSeleccionadoFinal.day}');
                            if (_listaPerfiles.isEmpty) {
                              _listaPerfiles =
                                  await obtenerPerfiles(ApiDefinition.ipServer);
                            }
                            List<Usuario> listaAux = await obtenerUsuariosAsistencia(
                                ApiDefinition.ipServer,
                                '${_diaSeleccionadoInicio.year}-${_diaSeleccionadoInicio.month}-${_diaSeleccionadoInicio.day}',
                                '${_diaSeleccionadoFinal.year}-${_diaSeleccionadoFinal.month}-${_diaSeleccionadoFinal.day}');
                            print(VariablesGlobales.usuario.perfil!.idperfil);
                            if (VariablesGlobales.usuario.perfil!.idperfil ==
                                '3') {
                              for (Usuario usuario in listaAux) {
                                if (usuario.perfil!.idperfil == '6') {
                                  _listaUsuarios.add(usuario);
                                }
                              }
                            } else {
                              _listaUsuarios = listaAux;
                            }
                            _listaAMostrar = _listaUsuarios;
                            PantallaDeCarga.loadingI(context, false);
                            setState(() {});
                          },
                          child: Text('Buscar')),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //TODO: Arreglar la descarga del reporte de asistencia
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     DateTime fecha;
                          //     final formato =
                          //         new DateFormat('yyyy-MM-dd hh:mm');
                          //     if (_diaSeleccionadoInicio.year >
                          //             _diaSeleccionadoFinal.year ||
                          //         _diaSeleccionadoInicio.month >
                          //             _diaSeleccionadoFinal.month ||
                          //         _diaSeleccionadoInicio.day >
                          //             _diaSeleccionadoFinal.day) {
                          //       Dialogos.error(context,
                          //           'La fecha de inicio seleccionada tiene que ser menor a la fecha final seleccionada');
                          //     } else {
                          //       print(_diaSeleccionadoInicio.toString());
                          //       String fechaInicio =
                          //           '${_diaSeleccionadoInicio.year}-${_diaSeleccionadoInicio.month}-${_diaSeleccionadoInicio.day}';
                          //       String fechaFinal =
                          //           '${_diaSeleccionadoFinal.year}-${_diaSeleccionadoFinal.month}-${_diaSeleccionadoFinal.day}';
                          //       PantallaDeCarga.loadingI(context, true);
                          //       String url = ApiDefinition.ipServer +
                          //           '/asistencia/generarReporte/$fechaInicio/$fechaFinal';
                          //       html.window.open(url, 'PlaceholderName');
                          //     }

                          //     PantallaDeCarga.loadingI(context, false);
                          //   },
                          //   child: Text('Descargar reporte'),
                          // ),
                        ],
                      ),
                      _tablaUsuariosAsistencia(),
                      // _tablaUsuarios(),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _tablaUsuarios() {
    return Container(
      color: Colors.red,
      height: 500.0,
      child: SingleChildScrollView(
        controller: _scrollTabla,
        child: Column(
          children: [
            for (Perfil perfil in _listaPerfiles)
              Container(
                width: 300.0,
                color: Colors.green,
                child: Column(
                  children: [
                    for (Usuario usuario in _listaUsuarios)
                      usuario.perfil!.perfil == perfil.perfil
                          ? Container(
                              width: 250,
                              color: Colors.blue,
                              child: Text(usuario.usuario!),
                            )
                          : Container()
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _tablaUsuariosAsistencia() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Text('Lista de asistencias'.toUpperCase()),
          ),
          _listaAMostrar.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      Text('Buscar: '),
                      Container(
                          width: 250.0,
                          child: ListaUsuarios(
                            controllerUsuarios: _controllerBuscar,
                            listaUsuarios: _listaUsuarios,
                            usuarioSeleccionado: _usuarioSeleccionado,
                            actualizar: setState,
                            usuarioSeleccionadoAccion: (BuildContext context,
                                Usuario usuarioSeleccionado,
                                StateSetter actualizar) {
                              Usuario? usuarioAIngresar;
                              _listaAMostrar.forEach((usuario) {
                                if (usuario.nombre !=
                                    usuarioSeleccionado.nombre) {
                                  usuarioAIngresar = usuario;
                                }
                              });
                              if (usuarioAIngresar != null) {
                                setState(() {
                                  if (filtro) {
                                    _listaAMostrar.add(usuarioSeleccionado);
                                  } else {
                                    _listaAMostrar = [];
                                    _listaAMostrar.add(usuarioSeleccionado);
                                    filtro = true;
                                  }
                                });
                              }
                            },
                            tipoBusqueda: 'SIMPLE',
                            usuariosSeleccionado: [],
                            limiteSeleccion: 0,
                          )),
                      Container(
                        padding: EdgeInsets.only(left: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _listaAMostrar = _listaUsuarios;
                              filtro = false;
                            });
                          },
                          child: Text('Mostrar Todos'),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0),
            child: DataTable(
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text('Usuario'.toUpperCase())),
              ],
              rows: _listaAMostrar
                  .map((usuario) => DataRow(
                          onSelectChanged: (seleccion) async {
                            print('Seleccion: ${usuario.nombre}');
                            PantallaDeCarga.loadingI(context, true);
                            String fechaInicio =
                                '${_diaSeleccionadoInicio.year}-${_diaSeleccionadoInicio.month}-${_diaSeleccionadoInicio.day}';
                            String fechaFinal =
                                '${_diaSeleccionadoFinal.year}-${_diaSeleccionadoFinal.month}-${_diaSeleccionadoFinal.day}';
                            List<Asistencia> asistencia =
                                await obtenerAsistencia(ApiDefinition.ipServer,
                                    usuario, fechaInicio, fechaFinal);
                            PantallaDeCarga.loadingI(context, false);
                            _usuarioSeleccionadoDialogo(asistencia);
                          },
                          cells: [
                            DataCell(Text(usuario.nombre!.toUpperCase())),
                          ]))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  _usuarioSeleccionadoDialogo(List<Asistencia> asistenciaUsuario) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Text(
                          "Usuario: ${asistenciaUsuario.elementAt(0).usuario!.nombre}")),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          //_limpiarCampos();
                          Navigator.pop(context);
                        });
                      },
                      icon: Icon(Icons.close)),
                ],
              ),
            ),
            children: <Widget>[
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  //return _formularioEditar(setState, usuario);
                  return _tablaAsistencia(asistenciaUsuario);
                },
              ),
            ],
          );
        });
  }

  Widget _tablaAsistencia(List<Asistencia> asistenciaUsuario) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Text('Lista de asistencias'.toUpperCase()),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 10.0),
            child: DataTable(
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text('Dia'.toUpperCase())),
                DataColumn(label: Text('Hora de entrada'.toUpperCase())),
                DataColumn(label: Text('Hora de salida'.toUpperCase())),
                DataColumn(label: Text('Foto'.toUpperCase())),
                DataColumn(label: Text('Ubicacion'.toUpperCase())),
              ],
              rows: asistenciaUsuario.map((asistencia) {
                DateTime dia = DateTime.utc(
                    int.parse(asistencia.dia!.split('-')[0]),
                    int.parse(asistencia.dia!.split('-')[1]),
                    int.parse(asistencia.dia!.split('-')[2]));
                return DataRow(onSelectChanged: (seleccion) async {}, cells: [
                  DataCell(Text(
                      DateFormat.yMMMMEEEEd('es').format(dia).toUpperCase())),
                  DataCell(Text(asistencia.horaDeEntrada == null
                      ? '-'
                      : asistencia.horaDeEntrada!)),
                  DataCell(Text(asistencia.horaDeSalida == null
                      ? '-'
                      : asistencia.horaDeSalida!)),
                  DataCell(IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return SimpleDialog(
                              shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.white, width: 3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              title: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        child: Text(
                                            "Usuario: ${asistencia.usuario!.nombre}")),
                                    Expanded(child: Container()),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        icon: Icon(Icons.close)),
                                  ],
                                ),
                              ),
                              children: <Widget>[
                                Container(
                                  height: 200.0,
                                  child: Image.network(
                                    asistencia.urlFoto!,
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                  )),
                  DataCell(IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: () {
                      String url =
                          'https://www.google.es/maps?q=${asistencia.coordenadasFoto!.replaceAll('LatLng(', '').replaceAll(')', '')}';
                      html.window.open(url, 'Foto');
                    },
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _obtenerFecha(String opc) {
    return InkWell(
      onTap: () {
        _seleccionarDia(opc);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            opc == 'inicio'
                ? Text(
                    '${DateFormat.yMMMd().format(_diaSeleccionadoInicio)}',
                  )
                : Text(
                    '${DateFormat.yMMMd().format(_diaSeleccionadoFinal)}',
                  ),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarDia(String opc) async {
    final DateTime? picked = await showDatePicker(
        locale: Locale('es', 'ES'),
        context: context,
        initialDate:
            opc == 'inicio' ? _diaSeleccionadoInicio : _diaSeleccionadoFinal,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2040));
    if (picked != null &&
        picked !=
            (opc == 'inicio'
                ? _diaSeleccionadoInicio
                : _diaSeleccionadoFinal)) {
      setState(() {
        if (opc == 'inicio') {
          _listaUsuarios = [];
          _diaSeleccionadoInicio = picked;
        } else {
          _diaSeleccionadoFinal = picked;
        }
      });
    }
  }
}
