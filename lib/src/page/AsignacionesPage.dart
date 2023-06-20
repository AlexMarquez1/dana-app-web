import 'dart:math';

import 'package:app_isae_desarrollo/src/models/Estatus.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/TotalDatos.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:firebase/firebase.dart';
// import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
// import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsignacionesPage extends StatefulWidget {
  @override
  _AsignacionesPageState createState() => _AsignacionesPageState();
}

class _AsignacionesPageState extends State<AsignacionesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeyProyecto = GlobalKey<FormState>();
  final _formKeyRegistro = GlobalKey<FormState>();

  //Lista para asignar proyecto
  List<Usuario> _listaUsuarios = [];
  List<Proyecto> _listaProyectosSinAsignar = [];
  List<Proyecto> _listaProyectosAsignados;

  //Lista para asignar registro
  List<Usuario> _listaUsuarioAsignar = [];
  List<Proyecto> _listaProyectos = [];
  List<String> _listaCampos = [];
  List<String> _listaBusqueda = [];
  List<Inventario> _listaRegistros = [];
  List<Inventario> _listaRegistrosAsignados = [];

  Usuario _usuarioSeleccionado;
  Usuario _usuarioSeleccionadoAsignar;
  Proyecto _proyectoSeleccionadoAsignar;
  Proyecto _proyectoSeleccionado;
  String _campoSeleccionado;

  bool _habilitarBusqueda = false;

  Map<String, bool> _seleccionRegistro = new Map<String, bool>();

  TextEditingController _busquedaController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      endDrawer: DrawerPrincipal(),
      body: _contenedor(context),
    );
  }

  Widget _contenedor(BuildContext context) {
    Size sizePantalla = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.center,
        children: [
          Container(
            width: sizePantalla.width,
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                'Asignaciones'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _tarjetaPersonalizada(600.0, _asignarProyectos()),
          _tarjetaPersonalizada(800.0, _tablaProyectosAsignados()),
          _tarjetaPersonalizada(600.0, _asignarRegistro()),
          _tarjetaPersonalizada(800.0, _tablaRegistrosAsignados()),
        ],
      ),
    );
  }

  Widget _tablaRegistrosAsignados() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Registros Asignados',
                style: TextStyle(fontSize: 30.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(20.0),
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(label: Text('Proyecto'.toUpperCase())),
                    DataColumn(label: Text('Folio'.toUpperCase())),
                    DataColumn(label: Text('Fecha Crecion'.toUpperCase())),
                    DataColumn(label: Text('Estatus'.toUpperCase())),
                    DataColumn(label: Text('Eliminar'.toUpperCase())),
                  ],
                  rows: _listaRegistrosAsignados == null
                      ? []
                      : _listaRegistrosAsignados
                          .map(
                            (registro) => DataRow(
                              onSelectChanged: (seleccion) {
                                if (seleccion) {}
                              },
                              cells: [
                                DataCell(Text(_proyectoSeleccionado.proyecto)),
                                DataCell(Text(registro.folio)),
                                DataCell(Text(registro.fechacreacion)),
                                DataCell(Text(registro.estatus)),
                                DataCell(IconButton(
                                    onPressed: () {
                                      Dialogos.advertencia(context,
                                          'Estas seguro de eliminar la asignacion del registro: ${registro.folio} \nal usuario: ${_usuarioSeleccionadoAsignar.usuario}',
                                          () async {
                                        PantallaDeCarga.loadingI(context, true);
                                        await eliminarAsignacionRegistro(
                                            ApiDefinition.ipServer,
                                            _usuarioSeleccionadoAsignar
                                                .idUsuario,
                                            registro.idinventario);
                                        _listaProyectosSinAsignar = [];
                                        _listaRegistros =
                                            await obtenerRegistros(
                                                ApiDefinition.ipServer,
                                                _proyectoSeleccionado
                                                    .idproyecto);
                                        for (Inventario item
                                            in _listaRegistros) {
                                          _seleccionRegistro[item.folio] =
                                              false;
                                        }
                                        await _consultarRegistros();

                                        if (registro.estatus == 'ASIGNADO') {
                                          Database db = database();
                                          DatabaseReference ref =
                                              db.ref('TotalDatos');

                                          await ref
                                              .child(_proyectoSeleccionado
                                                  .proyecto)
                                              .set({
                                            'NUEVO': Random().nextInt(100),
                                            'ASIGNADO': Random().nextInt(100),
                                            'PENDIENTE': Random().nextInt(100),
                                            'EN PROCESO': Random().nextInt(100),
                                            'CERRADO': Random().nextInt(100),
                                          });

                                          // DatabaseSnapshot snap =
                                          //     await FirebaseDatabaseWeb.instance
                                          //         .reference()
                                          //         .child('TotalDatos')
                                          //         .child(_proyectoSeleccionado
                                          //             .proyecto)
                                          //         .once();
                                          // TotalDatos datos =
                                          //     TotalDatos.fromJson(snap.value);

                                          // datos.totalAsignados =
                                          //     datos.totalAsignados - 1;
                                          // datos.totalNuevos =
                                          //     datos.totalNuevos + 1;

                                          // FirebaseDatabaseWeb.instance
                                          //     .reference()
                                          //     .child('TotalDatos')
                                          //     .child(_proyectoSeleccionado
                                          //         .proyecto)
                                          //     .update(datos.toJson());

                                          Estatus estatus = Estatus(
                                              estatus: 'NUEVO',
                                              inventario: registro);

                                          await cambiarEstatus(
                                              ApiDefinition.ipServer, estatus);
                                        }

                                        setState(() {});
                                        PantallaDeCarga.loadingI(
                                            context, false);
                                        Navigator.pop(context);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete_sweep,
                                      color: Colors.red,
                                    ))),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tablaProyectosAsignados() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Proyectos Asignados',
                style: TextStyle(fontSize: 30.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                margin: EdgeInsets.all(20.0),
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(label: Text('Usuario'.toUpperCase())),
                    DataColumn(label: Text('Proyecto'.toUpperCase())),
                    DataColumn(label: Text('Tipo proyecto'.toUpperCase())),
                    DataColumn(label: Text('Fecha Crecion'.toUpperCase())),
                    DataColumn(label: Text('Eliminar'.toUpperCase())),
                  ],
                  rows: _listaProyectosAsignados == null
                      ? []
                      : _listaProyectosAsignados
                          .map(
                            (proyecto) => DataRow(
                              onSelectChanged: (seleccion) {
                                if (seleccion) {}
                              },
                              cells: [
                                DataCell(Text(_usuarioSeleccionado.usuario)),
                                DataCell(Text(proyecto.proyecto)),
                                DataCell(Text(proyecto.descripcion == null
                                    ? ''
                                    : proyecto.descripcion)),
                                DataCell(Text(proyecto.fechacreacion)),
                                DataCell(IconButton(
                                    onPressed: () {
                                      Dialogos.advertencia(context,
                                          'Estas seguro de eliminar la asignacion del proyecto: ${proyecto.proyecto} \nal usuario: ${_usuarioSeleccionado.usuario}',
                                          () async {
                                        await eliminarAsignacionProyecto(
                                            ApiDefinition.ipServer,
                                            proyecto,
                                            _usuarioSeleccionado);
                                        Navigator.pop(context);
                                        _cargarProyectosSinAsignar(
                                            _usuarioSeleccionado);

                                        setState(() {});
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete_sweep,
                                      color: Colors.red,
                                    ))),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tablaRegistros() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: EdgeInsets.all(20.0),
            child: DataTable(
              showCheckboxColumn: true,
              columns: [
                DataColumn(label: Text('Proyecto'.toUpperCase())),
                DataColumn(label: Text('Folio'.toUpperCase())),
                DataColumn(label: Text('Fecha Crecion'.toUpperCase())),
                DataColumn(label: Text('Estatus'.toUpperCase())),
              ],
              rows: _listaRegistros == null
                  ? []
                  : _listaRegistros
                      .map(
                        (registro) => DataRow(
                          selected: _seleccionRegistro[registro.folio],
                          onSelectChanged: (seleccion) {
                            if (seleccion) {
                              _seleccionRegistro[registro.folio] = seleccion;
                            } else {
                              _seleccionRegistro[registro.folio] = seleccion;
                            }
                            setState(() {});
                          },
                          cells: [
                            DataCell(Text(registro.proyecto.proyecto)),
                            DataCell(Text(registro.folio)),
                            DataCell(Text(registro.fechacreacion)),
                            DataCell(Text(registro.estatus != null
                                ? registro.estatus
                                : 'nada')),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _asignarProyectos() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Form(
          key: _formKeyProyecto,
          child: Container(
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                  child: Text(
                    'Asignacion de proyectos',
                    style: TextStyle(fontSize: 30.0),
                  ),
                ),
                Container(
                  width: constraints.maxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.0,
                        child: Text('Usuario'),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      _listaUsuarios.isEmpty ? _usuarios() : _listarUsuarios(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.0,
                        child: Text('Proyectos'),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      _listarProyectosAsignar(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKeyProyecto.currentState.validate()) {
                      PantallaDeCarga.loadingI(context, true);
                      print(
                          'id Proyecto: ${_proyectoSeleccionadoAsignar.idproyecto}');
                      print('id Usuario: ${_usuarioSeleccionado.idUsuario}');
                      await asignarProyecto(
                          ApiDefinition.ipServer,
                          _usuarioSeleccionado.idUsuario,
                          _proyectoSeleccionadoAsignar.idproyecto);
                      _proyectoSeleccionadoAsignar = null;
                      _cargarProyectosSinAsignar(_usuarioSeleccionado);
                      PantallaDeCarga.loadingI(context, false);
                    }
                  },
                  child: Text('Asignar proyecto'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _asignarRegistro() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                child: Text(
                  'Asignacion de registro',
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
              Container(
                width: constraints.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.0,
                      child: Text('Usuario'),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _listaUsuarioAsignar.isEmpty
                        ? _usuariosBuilder()
                        : _listarUsuariosAsignar(),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: constraints.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.0,
                      child: Text('Proyecto'),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _listarProyectos(),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: constraints.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.0,
                      child: Text('Buscar por'),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    _listarCampos(),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                width: constraints.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.0,
                      child: Text('Buscar'),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Container(
                      child: Row(
                        children: [
                          Form(
                            key: _formKeyRegistro,
                            child: _autoCompletarBusqueda(),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Container(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKeyRegistro.currentState
                                      .validate()) {
                                    PantallaDeCarga.loadingI(context, true);
                                    _listaRegistros =
                                        await obtenerRegistrosBusqueda(
                                            ApiDefinition.ipServer,
                                            _proyectoSeleccionado.idproyecto,
                                            _busquedaController.text);
                                    await _consultarRegistrosBusqueda();
                                    setState(() {});
                                    PantallaDeCarga.loadingI(context, false);
                                  }
                                },
                                child: Text('Buscar')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  onPressed: _habilitarBusqueda
                      ? () async {
                          PantallaDeCarga.loadingI(context, true);
                          _listaRegistros = await obtenerRegistros(
                              ApiDefinition.ipServer,
                              _proyectoSeleccionado.idproyecto);
                          for (Inventario item in _listaRegistros) {
                            _seleccionRegistro[item.folio] = false;
                          }
                          await _consultarRegistros();
                          PantallaDeCarga.loadingI(context, false);
                        }
                      : null,
                  child: Text('Mostrar todos')),
              SizedBox(
                height: 30.0,
              ),
              _tablaRegistros(),
              ElevatedButton(
                onPressed: () async {
                  PantallaDeCarga.loadingI(context, true);
                  List<String> registrosSeleccionados = [];
                  List<String> registrosId = [];
                  List<Inventario> registrosAsignados = [];
                  for (Inventario item in _listaRegistros) {
                    if (_seleccionRegistro[item.folio]) {
                      registrosSeleccionados.add(item.folio);
                      registrosId.add(item.idinventario.toString());
                      registrosAsignados.add(item);
                    }
                  }

                  Database db = database();
                  DatabaseReference ref = db.ref('TotalDatos');

                  await ref.child(_proyectoSeleccionado.proyecto).set({
                    'NUEVO': Random().nextInt(100),
                    'ASIGNADO': Random().nextInt(100),
                    'PENDIENTE': Random().nextInt(100),
                    'EN PROCESO': Random().nextInt(100),
                    'CERRADO': Random().nextInt(100),
                  });

                  // DatabaseSnapshot snap = await FirebaseDatabaseWeb.instance
                  //     .reference()
                  //     .child('TotalDatos')
                  //     .child(_proyectoSeleccionado.proyecto)
                  //     .once();
                  // TotalDatos datos = TotalDatos.fromJson(snap.value);

                  // int conteo = 0;
                  // for (Registro item in registrosAsignados) {
                  //   switch (item.estatus) {
                  //     case 'NUEVO':
                  //       datos.totalNuevos = datos.totalNuevos - 1;
                  //       break;
                  //     case 'ASIGNADO':
                  //       datos.totalAsignados = datos.totalAsignados - 1;
                  //       break;
                  //     case 'PENDIENTE':
                  //       datos.totalPendientes = datos.totalPendientes - 1;
                  //       break;
                  //     case 'EN PROCESO':
                  //       datos.totalEnProceso = datos.totalEnProceso - 1;
                  //       break;
                  //     case 'CERRADO':
                  //       datos.totalCerrados = datos.totalCerrados - 1;
                  //       break;
                  //   }
                  //   conteo++;
                  // }
                  // datos.totalAsignados = datos.totalAsignados + conteo;

                  // FirebaseDatabaseWeb.instance
                  //     .reference()
                  //     .child('TotalDatos')
                  //     .child(_proyectoSeleccionado.proyecto)
                  //     .update(datos.toJson());

                  await asignarRegistro(ApiDefinition.ipServer,
                      _usuarioSeleccionadoAsignar.idUsuario, registrosId);
                  _listaProyectosSinAsignar = [];
                  _listaRegistros = await obtenerRegistros(
                      ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto);
                  for (Inventario item in _listaRegistros) {
                    _seleccionRegistro[item.folio] = false;
                  }
                  await _consultarRegistros();
                  PantallaDeCarga.loadingI(context, false);
                },
                child: Text('Asignar registro'),
              ),
            ],
          ),
        );
      },
    );
  }

  _consultarRegistros() async {
    List<String> registrosAsignados = await obtenerRegistrosAsignados(
        ApiDefinition.ipServer, _usuarioSeleccionadoAsignar.idUsuario);
    _listaRegistros = _eliminarAsignados(registrosAsignados, _listaRegistros);
    setState(() {});
  }

  _consultarRegistrosBusqueda() async {
    List<String> registrosAsignados = await obtenerRegistrosAsignados(
        ApiDefinition.ipServer, _usuarioSeleccionadoAsignar.idUsuario);
    _listaRegistros =
        _eliminarAsignadosBusqueda(registrosAsignados, _listaRegistros);
    setState(() {});
  }

  Widget _usuarios() {
    return FutureBuilder(
      future: _obtenerUsuarios(),
      builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
        if (snapshot.hasData) {
          _listaUsuarios = snapshot.data;
          return _listarUsuarios();
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  void _cargarProyectosSinAsignar(Usuario usuario) async {
    PantallaDeCarga.loadingI(context, true);
    _usuarioSeleccionado = usuario;
    List<Proyecto> listaProyectos = await _obtenerProyectos();
    _listaProyectosAsignados = await obtenerProyectosAsignados(
        ApiDefinition.ipServer, _usuarioSeleccionado);
    _listaProyectosSinAsignar = [];
    if (_listaProyectosAsignados.isEmpty) {
      _listaProyectosSinAsignar = listaProyectos;
    } else {
      bool asignado = false;
      int ind = 0;
      for (int i = 0; i < listaProyectos.length; i++) {
        for (int j = 0; j < _listaProyectosAsignados.length; j++) {
          if (_listaProyectosAsignados.elementAt(j).proyecto ==
              listaProyectos.elementAt(i).proyecto) {
            asignado = true;
            break;
          } else {
            asignado = false;
            ind = i;
          }
        }
        if (!asignado) {
          _listaProyectosSinAsignar.add(listaProyectos.elementAt(ind));
        }
      }
    }
    PantallaDeCarga.loadingI(context, false);
    setState(() {});
  }

  Widget _listarUsuarios() {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Usuarios',
        ),
        value: _usuarioSeleccionado,
        onChanged: (valor) async {
          _proyectoSeleccionadoAsignar = null;
          _cargarProyectosSinAsignar(valor);
        },
        items: _listaUsuarios.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.usuario),
          );
        }).toList(),
        validator: (Usuario value) {
          if (value == null) {
            return 'Selecciona un usuario';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _listarProyectosAsignar() {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Proyectos',
        ),
        value: _proyectoSeleccionadoAsignar,
        onChanged: (valor) async {
          _proyectoSeleccionadoAsignar = valor;
          setState(() {});
        },
        items: _listaProyectosSinAsignar.map((item) {
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

  Widget _listarProyectos() {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Proyectos',
        ),
        value: _proyectoSeleccionado,
        onChanged: (valor) async {
          _campoSeleccionado = null;
          _campoSeleccionado = null;
          _busquedaController.text = '';
          _proyectoSeleccionado = valor;
          PantallaDeCarga.loadingI(context, true);
          _listaRegistros = await obtenerRegistros(
              ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto);
          for (Inventario item in _listaRegistros) {
            _seleccionRegistro[item.folio] = false;
          }
          await _consultarRegistros();
          _listaCampos = await obtenerCamposProyectoBusqueda(
              ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto);
          PantallaDeCarga.loadingI(context, false);
          setState(() {});
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

  List<Inventario> _eliminarAsignados(
      List<String> asignados, List<Inventario> registros) {
    List<Inventario> listaRegistrosSinAsignar = [];
    _listaRegistrosAsignados = [];
    if (asignados.isEmpty) {
      listaRegistrosSinAsignar = registros;
      print('No hay registros asignados');
    } else {
      bool asignado = false;
      int ind = 0;
      for (int i = 0; i < registros.length; i++) {
        for (int j = 0; j < asignados.length; j++) {
          if (registros.elementAt(i).folio == asignados.elementAt(j)) {
            asignado = true;
            break;
          } else {
            asignado = false;
            ind = i;
          }
        }
        if (!asignado) {
          listaRegistrosSinAsignar.add(registros.elementAt(ind));
        } else {
          _listaRegistrosAsignados.add(registros.elementAt(i));
        }
      }
    }
    return listaRegistrosSinAsignar;
  }

  List<Inventario> _eliminarAsignadosBusqueda(
      List<String> asignados, List<Inventario> registros) {
    List<Inventario> listaRegistrosSinAsignar = [];
    if (asignados.isEmpty) {
      listaRegistrosSinAsignar = registros;
      print('No hay registros asignados');
    } else {
      bool asignado = false;
      int ind = 0;
      for (int i = 0; i < registros.length; i++) {
        for (int j = 0; j < asignados.length; j++) {
          if (registros.elementAt(i).folio == asignados.elementAt(j)) {
            asignado = true;
            break;
          } else {
            asignado = false;
            ind = i;
          }
        }
        if (!asignado) {
          listaRegistrosSinAsignar.add(registros.elementAt(ind));
        }
      }
    }
    return listaRegistrosSinAsignar;
  }

  Widget _listarCampos() {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Campos',
        ),
        value: _campoSeleccionado,
        onChanged: (valor) async {
          _campoSeleccionado = valor;
          _busquedaController.text = '';
          PantallaDeCarga.loadingI(context, true);
          _listaBusqueda = await obtenerDatosProyectoBusqueda(
              ApiDefinition.ipServer, _proyectoSeleccionado.idproyecto, valor);
          PantallaDeCarga.loadingI(context, false);
          _habilitarBusqueda = true;
          setState(() {});
        },
        items: _listaCampos.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (String value) {
          if (value == null) {
            return 'Selecciona un campo';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _usuariosBuilder() {
    return FutureBuilder(
      future: _obtenerUsuarios(),
      builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
        if (snapshot.hasData) {
          _listaUsuarioAsignar = snapshot.data;
          return _listarUsuariosAsignar();
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _listarUsuariosAsignar() {
    return Container(
      width: 300.0,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Usuarios',
        ),
        value: _usuarioSeleccionadoAsignar,
        onChanged: (valor) async {
          _usuarioSeleccionadoAsignar = valor;
          _proyectoSeleccionado = null;
          _listaRegistrosAsignados = null;
          _listaRegistros = null;
          _listaCampos = [];
          _campoSeleccionado = null;
          _busquedaController.text = '';
          _habilitarBusqueda = false;
          PantallaDeCarga.loadingI(context, true);
          _listaProyectos =
              await obtenerProyectosAsignados(ApiDefinition.ipServer, valor);
          PantallaDeCarga.loadingI(context, false);
          setState(() {});
        },
        items: _listaUsuarioAsignar.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item.usuario),
          );
        }).toList(),
        validator: (Usuario value) {
          if (value == null) {
            return 'Selecciona un usuario';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Future<List<Usuario>> _obtenerUsuarios() async {
    return await obtenerUsuarios(ApiDefinition.ipServer);
  }

  Future<List<Proyecto>> _obtenerProyectos() async {
    return await obtenerProyectos(ApiDefinition.ipServer);
  }

  Widget _tarjeta(Size sizePantalla, Widget contenido) {
    return Container(
      width: sizePantalla.width * 0.8,
      padding: EdgeInsets.only(top: 20.0),
      margin: EdgeInsets.symmetric(horizontal: 25.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: contenido,
      ),
    );
  }

  Widget _tarjetaChica(Size sizePantalla, Widget contenido) {
    return Container(
      width: sizePantalla.width * 0.5,
      padding: EdgeInsets.only(top: 20.0),
      margin: EdgeInsets.symmetric(horizontal: 25.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: Center(child: contenido),
      ),
    );
  }

  Widget _tarjetaPersonalizada(double ancho, Widget contenido) {
    return Container(
      width: ancho,
      padding: EdgeInsets.only(top: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: Center(child: contenido),
      ),
    );
  }

  Widget _autoCompletarBusqueda() {
    return Autocomplete(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (_busquedaController.text.isNotEmpty) {
          textEditingController.text = _busquedaController.text;
        }
        _busquedaController = textEditingController;
        return Container(
          width: 200.0,
          child: TextFormField(
            enabled: _habilitarBusqueda,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una busqueda';
              } else {
                bool validacion = false;
                for (String busqueda in _listaBusqueda) {
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
            controller: _busquedaController,
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
          if (_listaBusqueda.isEmpty) {
            return ['Sin resultados'];
          } else {
            return _listaBusqueda.where((String opcion) {
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
          _busquedaController.text = '';
          setState(() {});
        } else {
          print('Se a seleccionado: $seleccion');
        }
      },
    );
  }
}
