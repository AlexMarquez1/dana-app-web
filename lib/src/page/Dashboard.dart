import 'package:animate_do/animate_do.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/TotalDatos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:d_chart/d_chart.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollFiltro = ScrollController();
  ScrollController _scrollGeneral = ScrollController();
  AnimationController _animationController;
  static TotalDatos _totalDatos = TotalDatos();
  DatabaseReference _ref;

  Map<String, bool> _tipoSeleccionado = Map<String, bool>();
  Map<String, bool> _proyectoSeleccionado = Map<String, bool>();
  Map<dynamic, dynamic> _datos;
  List<String> _listaTipoProyectos = [];
  List<Proyecto> _listaProyectos = [];
  List<Inventario> _listaInventarios = [];
  bool _filtroEntrada = false;
  bool _cargando = false;

  @override
  void initState() {
    _obtenerProyectos().then((value) {
      _listaProyectos = value;
      for (Proyecto item in _listaProyectos) {
        _proyectoSeleccionado[item.proyecto] = true;
      }
      _proyectoSeleccionado['TODOS'] = true;
      _obtenerDatos();
    });
    _obtenerTipoProyecto().then((value) {
      _listaTipoProyectos = value;
      for (String item in _listaTipoProyectos) {
        _tipoSeleccionado[item] = true;
      }
      _tipoSeleccionado['TODOS'] = true;
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }

  @override
  void dispose() {
    _ref = database().ref('TotalDatos');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      body: _contenido(),
      endDrawer: DrawerPrincipal(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _filtroEntrada ? Colors.red : Colors.blue,
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          semanticLabel: 'Filtrar',
          progress: _animationController,
        ),
        onPressed: () {
          if (_filtroEntrada) {
            _filtroEntrada = false;
            _animationController.reverse();
          } else {
            _filtroEntrada = true;
            _animationController.forward();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _contenido() {
    Size sizePantalla = MediaQuery.of(context).size;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollGeneral,
          child: Column(
            children: [
              Container(
                width: sizePantalla.width,
                padding: EdgeInsets.only(top: 20.0),
                child: Center(
                  child: Text(
                    'Dashboard'.toUpperCase(),
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
              _totalConteo(sizePantalla),
              _graficas(),
            ],
          ),
        ),
        _filtroEntrada
            ? GestureDetector(
                onTap: () {
                  _filtroEntrada = false;
                  _animationController.reverse();
                  setState(() {});
                },
                child: Container(
                  width: sizePantalla.width,
                  height: sizePantalla.height,
                  color: Colors.black26,
                ),
              )
            : Container(),
        _filtroEntrada
            ? Positioned(
                top: sizePantalla.height * 0.45,
                left: sizePantalla.width * 0.7,
                child: SlideInUp(
                  animate: _filtroEntrada,
                  child: Container(
                    width: sizePantalla.width * 0.3,
                    height: sizePantalla.height * 0.5,
                    child: _filtoConteo(sizePantalla),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _graficas() {
    Size size = MediaQuery.of(context).size;
    return Tarjetas.tarjeta(
      size,
      Text('Graficas'),
    );
  }

  Widget _filtoConteo(Size sizePantalla) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          child: Card(
            borderOnForeground: true,
            color: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _listaTipoProyectos.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            width: (sizePantalla.width * 0.7) / 3,
                            child: _tiposDeProyecto(sizePantalla))
                        : _cargandoContenido(),
                    _listaProyectos.isNotEmpty
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0),
                            width: (sizePantalla.width * 0.7) / 3,
                            child: _proyectos(sizePantalla),
                          )
                        : _cargandoContenido(),
                  ],
                ),
              ),
            ),
          ),
        ),
        _cargando
            ? Center(
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(),
      ],
    );
  }

  List<charts.Series<String, String>> _obtenerDatosGrafica() {
    List<String> datos = [
      'Asignados',
      'Cerrados',
      'EnProceso',
      'Nuevos',
      'Pendientes',
    ];
    List<charts.Series<String, String>> series = [
      charts.Series(
          id: 'Totales',
          data: datos,
          displayName: 'Totales',
          colorFn: (String dato, _) {
            switch (dato) {
              case 'Asignados':
                return charts.ColorUtil.fromDartColor(Colors.blue);
                break;
              case 'Cerrados':
                return charts.ColorUtil.fromDartColor(Colors.green);
                break;
              case 'EnProceso':
                return charts.ColorUtil.fromDartColor(Colors.yellow);
                break;
              case 'Nuevos':
                return charts.ColorUtil.fromDartColor(Colors.grey[400]);
                break;
              case 'Pendientes':
                return charts.ColorUtil.fromDartColor(Colors.orange);
                break;
              default:
                return charts.ColorUtil.fromDartColor(Colors.black);
            }
          },
          labelAccessorFn: (String dato, _) {
            switch (dato) {
              case 'Asignados':
                return '$dato: ${_totalDatos.totalAsignados}';
                break;
              case 'Cerrados':
                return '$dato: ${_totalDatos.totalCerrados}';
                break;
              case 'EnProceso':
                return '$dato: ${_totalDatos.totalEnProceso}';
                break;
              case 'Nuevos':
                return '$dato: ${_totalDatos.totalNuevos}';
                break;
              case 'Pendientes':
                return '$dato: ${_totalDatos.totalPendientes}';
                break;
              default:
                return dato;
            }
          },
          domainFn: (String dato, _) => dato,
          measureFn: (String dato, _) {
            switch (dato) {
              case 'Asignados':
                return _totalDatos.totalAsignados != null
                    ? _totalDatos.totalAsignados != 0
                        ? _totalDatos.totalAsignados
                        : 1
                    : 1;
                break;
              case 'Cerrados':
                return _totalDatos.totalCerrados != null
                    ? _totalDatos.totalCerrados != 0
                        ? _totalDatos.totalCerrados
                        : 1
                    : 1;
                break;
              case 'EnProceso':
                return _totalDatos.totalEnProceso != null
                    ? _totalDatos.totalEnProceso != 0
                        ? _totalDatos.totalEnProceso
                        : 1
                    : 1;
                break;
              case 'Nuevos':
                return _totalDatos.totalNuevos != null
                    ? _totalDatos.totalNuevos != 0
                        ? _totalDatos.totalNuevos
                        : 1
                    : 1;
                break;
              case 'Pendientes':
                return _totalDatos.totalPendientes != null
                    ? _totalDatos.totalPendientes != 0
                        ? _totalDatos.totalPendientes
                        : 1
                    : 1;
                break;
              // case 'totalRegistro':
              //   int total = 1;
              //   if (_totalDatos.totalAsignados != null) {
              //     total = _totalDatos.totalAsignados +
              //         _totalDatos.totalCerrados +
              //         _totalDatos.totalEnProceso +
              //         _totalDatos.totalNuevos +
              //         _totalDatos.totalPendientes;
              //   }
              //   return total;
              //   break;
              default:
                return 1;
            }
          }),
    ];
    return series;
  }

  Widget _cargandoContenido() {
    return Container(
      margin: EdgeInsets.all(30.0),
      width: 150.0,
      height: 150.0,
      child: CircularProgressIndicator(),
    );
  }

  Future<List<String>> _obtenerTipoProyecto() async {
    return await obtenerTipoProyectos(ApiDefinition.ipServer);
  }

  Future<List<Proyecto>> _obtenerProyectos() async {
    return await obtenerProyectos(ApiDefinition.ipServer);
  }

  Widget _proyectos(Size sizePantalla) {
    return Column(
      children: [
        Text('Proyectos'),
        Container(
          height: 50.0,
          width: (sizePantalla.width * 0.7) / 3,
          child: CheckboxListTile(
              title: Text('TODOS'),
              value: _proyectoSeleccionado['TODOS'] == null
                  ? true
                  : _proyectoSeleccionado['TODOS'],
              onChanged: (valor) {
                _proyectoSeleccionado['TODOS'] = valor;
                if (valor) {
                  for (Proyecto item in _listaProyectos) {
                    _proyectoSeleccionado[item.proyecto] = true;
                  }
                } else {
                  for (Proyecto item in _listaProyectos) {
                    _proyectoSeleccionado[item.proyecto] = false;
                  }
                }
                _actualizarDatos().then((value) {
                  setState(() {
                    print('Carga Completa');
                  });
                });
              }),
        ),
        for (Proyecto item in _listaProyectos)
          Container(
            height: 50.0,
            width: (sizePantalla.width * 0.7) / 3,
            child: CheckboxListTile(
              title: Text(item.proyecto),
              value: _proyectoSeleccionado[item.proyecto],
              onChanged: (valor) {
                _proyectoSeleccionado[item.proyecto] = valor;
                if (_tipoSeleccionado['TODOS'] && !valor) {
                  _proyectoSeleccionado['TODOS'] = false;
                }

                bool todosSeleccionados = true;
                for (Proyecto opc in _listaProyectos) {
                  if (!_proyectoSeleccionado[opc.proyecto]) {
                    todosSeleccionados = false;
                    break;
                  }
                }

                if (todosSeleccionados) {
                  _proyectoSeleccionado['TODOS'] = true;
                }

                _actualizarDatos().then((value) {
                  setState(() {
                    print('Carga Completa');
                  });
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _tiposDeProyecto(Size sizePantalla) {
    return Column(
      children: [
        Text('Tipo proyecto'),
        Container(
          height: 50.0,
          width: (sizePantalla.width * 0.7) / 3,
          child: CheckboxListTile(
              title: Text('TODOS'),
              value: _tipoSeleccionado['TODOS'] == null
                  ? true
                  : _tipoSeleccionado['TODOS'],
              onChanged: (valor) {
                _tipoSeleccionado['TODOS'] = valor;
                if (valor) {
                  for (String item in _listaTipoProyectos) {
                    _tipoSeleccionado[item] = true;
                  }
                } else {
                  for (String item in _listaTipoProyectos) {
                    _tipoSeleccionado[item] = false;
                  }
                }
                _actualizarDatos().then((value) {
                  setState(() {
                    print('Carga Completa');
                  });
                });
              }),
        ),
        for (String item in _listaTipoProyectos)
          Container(
            height: 50.0,
            width: (sizePantalla.width * 0.7) / 3,
            child: CheckboxListTile(
              title: Text(item),
              value: _tipoSeleccionado[item],
              onChanged: (valor) {
                _tipoSeleccionado[item] = valor;
                if (_tipoSeleccionado['TODOS'] && !valor) {
                  _tipoSeleccionado['TODOS'] = false;
                }

                for (Proyecto proyecto in _listaProyectos) {
                  if (proyecto.descripcion == item) {
                    _proyectoSeleccionado[proyecto.proyecto] = valor;
                  }
                }

                bool todosSeleccionados = true;
                for (String opc in _listaTipoProyectos) {
                  if (!_tipoSeleccionado[opc]) {
                    todosSeleccionados = false;
                    break;
                  }
                }

                if (todosSeleccionados) {
                  _tipoSeleccionado['TODOS'] = true;
                }

                _actualizarDatos().then((value) {
                  setState(() {
                    print('Carga Completa');
                  });
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _totalConteo(Size sizePantalla) {
    double ancho = sizePantalla.width * 0.7;
    return Container(
      width: ancho,
      margin: EdgeInsets.all(25.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              bottom: 50.0, left: 20.0, top: 30.0, right: 20.0),
          child: Row(
            children: [
              Container(
                width: sizePantalla.width * 0.2,
                height: sizePantalla.height * 0.4,
                child: charts.PieChart(
                  _obtenerDatosGrafica(),
                  animate: true,
                  defaultRenderer: charts.ArcRendererConfig(
                      // arcWidth: 60,
                      arcRendererDecorators: [
                        charts.ArcLabelDecorator(),
                      ]),
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      _tarjetaConteo(
                          Colors.black,
                          'Total Registros',
                          _totalDatos.totalRegistros != null
                              ? '${_totalDatos.totalRegistros}'
                              : '0'),
                      SizedBox(
                        width: 100.0,
                      ),
                      _tarjetaConteo(
                          Colors.green,
                          'Total Cerrados',
                          _totalDatos.totalCerrados != null
                              ? '${_totalDatos.totalCerrados}'
                              : '0'),
                      SizedBox(
                        width: 100.0,
                      ),
                      _tarjetaConteo(
                          Colors.orange,
                          'Total Pendientes',
                          _totalDatos.totalPendientes != null
                              ? '${_totalDatos.totalPendientes}'
                              : '0'),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tarjetaConteo(
                          Colors.yellow,
                          'Total En Proceso',
                          _totalDatos.totalEnProceso != null
                              ? '${_totalDatos.totalEnProceso}'
                              : '0'),
                      SizedBox(
                        width: 100.0,
                      ),
                      _tarjetaConteo(
                          Colors.blue,
                          'Total Asignados',
                          _totalDatos.totalAsignados != null
                              ? '${_totalDatos.totalAsignados}'
                              : '0'),
                      SizedBox(
                        width: 100.0,
                      ),
                      _tarjetaConteo(
                          Colors.grey[400],
                          'Total Nuevos',
                          _totalDatos.totalNuevos != null
                              ? '${_totalDatos.totalNuevos}'
                              : '0'),
                    ],
                  ),
                ],
              ),
              // ElevatedButton(
              //     onPressed: () async {
              //       // FirebaseDatabaseWeb.instance
              //       //     .reference()
              //       //     .child('TotalDatos')
              //       //     .child('TIPOS DE CAMPOS')
              //       //     .update({
              //       //   "tipoProyecto": "INVENTARIOS",
              //       //   "totalAsignados": 1,
              //       //   "totalCerrados": 0,
              //       //   "totalEnProceso": 3,
              //       //   "totalNuevos": 4,
              //       //   "totalPendientes": 1,
              //       // });

              //       DatabaseSnapshot snap = await FirebaseDatabaseWeb.instance
              //           .reference()
              //           .child('TotalDatos')
              //           .child('B')
              //           .once();
              //       TotalDatos datos = TotalDatos.fromJson(snap.value);
              //       print(datos);
              //     },
              //     child: Text('Actualizar datos')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaConteo(Color color, String texto, String conteo) {
    return Container(
      width: 200.0,
      height: 200.0,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 5.0),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Center(
            child: AnimatedFlipCounter(
              duration: Duration(seconds: 2),
              value: int.parse(conteo),
              textStyle: TextStyle(fontSize: 50.0),
            ),
          ),
          Center(
              heightFactor: 200.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Text(
                  texto,
                  style: TextStyle(fontSize: 20.0),
                ),
              )),
        ],
      ),
    );
  }

  void _obtenerDatos() {
    _ref = database().ref('TotalDatos');
    _ref.onValue.listen((e) {
      DataSnapshot datasnapshot = e.snapshot;
      // Do something with datasnapshot
      _datos = datasnapshot.val();

      if (mounted) {
        _actualizarDatos().then((value) {
          setState(() {
            print('Carga de datos completa');
          });
        });
      }
    });
  }

  Future<void> _actualizarDatos() async {
    _totalDatos = TotalDatos();
    _totalDatos.totalAsignados = 0;
    _totalDatos.totalCerrados = 0;
    _totalDatos.totalEnProceso = 0;
    _totalDatos.totalNuevos = 0;
    _totalDatos.totalPendientes = 0;
    _totalDatos.totalRegistros = 0;
    List<String> proyectos = [];
    for (String proyecto in _proyectoSeleccionado.keys) {
      if (_proyectoSeleccionado[proyecto] && proyecto != 'TODOS') {
        proyectos.add(proyecto);
      }
    }

    if (_proyectoSeleccionado != null && _tipoSeleccionado != null) {
      if (_proyectoSeleccionado.isNotEmpty && _tipoSeleccionado.isNotEmpty) {
        if (_proyectoSeleccionado['TODOS'] && _tipoSeleccionado['TODOS']) {
          List<Inventario> lista = await obtenerRegistrosDashboard(
              ApiDefinition.ipServer, proyectos);
          for (Inventario inventario in lista) {
            switch (inventario.estatus) {
              case 'NUEVO':
                _totalDatos.totalNuevos += 1;
                break;
              case 'ASIGNADO':
                _totalDatos.totalAsignados += 1;
                break;
              case 'EN PROCESO':
                _totalDatos.totalEnProceso += 1;
                break;
              case 'PENDIENTE':
                _totalDatos.totalPendientes += 1;
                break;
              case 'CERRADO':
                _totalDatos.totalCerrados += 1;
                break;
            }
          }

          _totalDatos.totalRegistros = _totalDatos.totalNuevos +
              _totalDatos.totalAsignados +
              _totalDatos.totalEnProceso +
              _totalDatos.totalPendientes +
              _totalDatos.totalCerrados;
        } else {
          setState(() {
            _cargando = true;
          });
          List<Inventario> lista = await obtenerRegistrosDashboard(
              ApiDefinition.ipServer, proyectos);
          setState(() {
            _cargando = false;
          });
          for (Inventario inventario in lista) {
            switch (inventario.estatus) {
              case 'NUEVO':
                _totalDatos.totalNuevos += 1;
                break;
              case 'ASIGNADO':
                _totalDatos.totalAsignados += 1;
                break;
              case 'EN PROCESO':
                _totalDatos.totalEnProceso += 1;
                break;
              case 'PENDIENTE':
                _totalDatos.totalPendientes += 1;
                break;
              case 'CERRADO':
                _totalDatos.totalCerrados += 1;
                break;
            }
          }
          _totalDatos.totalRegistros = _totalDatos.totalNuevos +
              _totalDatos.totalAsignados +
              _totalDatos.totalEnProceso +
              _totalDatos.totalPendientes +
              _totalDatos.totalCerrados;
        }
      }
    } else {
      print(
          'Alguna seleccion es nula: ProyectoSeleccionado:  $_proyectoSeleccionado TipoSeleccionado: $_tipoSeleccionado');
    }
  }
}
