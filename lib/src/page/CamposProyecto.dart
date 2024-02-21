import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TarjetaNuevoCampo.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TipoCampo.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
// import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CamposProyecto extends StatefulWidget {
  CamposProyecto({Key? key}) : super(key: key);

  @override
  State<CamposProyecto> createState() => _CamposProyectoState();
}

class _CamposProyectoState extends State<CamposProyecto> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollCampo = ScrollController();

  List<DragAndDropListExpansion> _campos = [];
  List<Agrupaciones> _listaAgrupaciones = [];
  List<String> _nuevosCampos = [];

  Map<String, dynamic> _argumentos = {};
  Map<String, bool> _expanded = Map<String, bool>();

  Map<String, AnimationController> _animateController =
      new Map<String, AnimationController>();

  String _nombreProyecto = '';
  String? _tipoProyectoSeleccionado;

  @override
  Widget build(BuildContext context) {
    _argumentos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _listaAgrupaciones = _argumentos['listaAgrupaciones'];
    _nombreProyecto = _argumentos['nombreProyecto'];
    _tipoProyectoSeleccionado = _argumentos['tipoProyecto'];
    if (_expanded.isEmpty) {
      for (Agrupaciones agrupacion in _listaAgrupaciones) {
        for (Campos campo in agrupacion.campos!) {
          _expanded[campo.nombreCampo!] = false;
        }
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      endDrawer: DrawerPrincipal(),
      body: _contenido(),
      floatingActionButton: _botones(),
    );
  }

  Widget _botones() {
    return Container(
      margin: EdgeInsets.only(left: 50.0, right: 20.0),
      height: 100.0,
      child: Row(
        children: [
          Tooltip(
            message: 'Volver',
            textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            child: FloatingActionButton(
              heroTag: 'cancelar',
              backgroundColor: Colors.red,
              child: Icon(Icons.arrow_back),
              onPressed: () {
                Dialogos.advertencia(
                    context, 'Estas seguro que quieres volver?', () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'CANCELADO');
                });
              },
            ),
          ),
          Expanded(child: Container()),
          Tooltip(
            message: 'Guardar',
            textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
            child: FloatingActionButton(
              heroTag: 'guardar',
              child: Icon(Icons.save),
              onPressed: () {
                if (_nombreProyecto.isEmpty) {
                  Dialogos.error(context, 'Ingresa el nombre del proyecto');
                } else if (_tipoProyectoSeleccionado == 'Tipo de proyecto') {
                  Dialogos.error(context, 'Selecciona el tipo de proyecto');
                } else {
                  Dialogos.advertencia(
                      context, 'Guardar los campos agregados', _crearProyecto);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    Size sizePantalla = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: sizePantalla.width,
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                Text(
                  'Campos Proyecto: $_nombreProyecto'.toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ],
            ),
          ),
          _lista(),
        ],
      ),
    );
  }

  Widget _lista() {
    _campos = _construirLista();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200.0,
      margin: EdgeInsets.all(20.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 230.0,
              margin: EdgeInsets.only(
                left: 20.0,
              ),
              child: DragAndDropLists(
                listGhost: Container(
                  color: Colors.blue[400],
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  child: Center(child: Text('Agrupacion')),
                ),
                children: _campos,
                onItemReorder: _onItemReorder,
                onListReorder: _onListReorder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DragAndDropListExpansion> _construirLista() {
    List<DragAndDropListExpansion> campos = [];
    for (int i = 0; i < _listaAgrupaciones.length; i++) {
      campos.add(DragAndDropListExpansion(
        onExpansionChanged: (valor) {
          // if (valor) {
          //   _agregarCampoOcultar = false;
          // } else {
          //   _agregarCampoOcultar = true;
          // }
          // setState(() {});
        },
        contentsWhenEmpty: Text('Vacio'),
        canDrag: _listaAgrupaciones.elementAt(i).campos!.isEmpty
            ? true
            : _listaAgrupaciones
                        .elementAt(i)
                        .campos!
                        .elementAt(0)
                        .nombreCampo ==
                    'FOLIO'
                ? false
                : true,
        initiallyExpanded: false,
        listKey: new Key(_listaAgrupaciones.elementAt(i).agrupacion!),
        backgroundColor: Colors.white,
        title: Container(
          child: Row(
            children: [
              Icon(Icons.menu),
              Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Text(_listaAgrupaciones
                        .elementAt(i)
                        .agrupacion!
                        .toUpperCase()),
                    SizedBox(
                      width: 20.0,
                    ),
                    GestureDetector(
                        onTap: () {
                          Dialogos.advertencia(context,
                              'Quieres agregar un nuevo campo a ${_listaAgrupaciones.elementAt(i).agrupacion!.toUpperCase()}',
                              () {
                            TextEditingController controllerCampoNombre =
                                new TextEditingController();
                            TextEditingController controladorRestriccion =
                                new TextEditingController();
                            TextEditingController controladorLongitud =
                                new TextEditingController();

                            controllerCampoNombre.text = 'NUEVO CAMPO';
                            controladorRestriccion.text = 'N/A';
                            controladorLongitud.text = '100';

                            _listaAgrupaciones.elementAt(i).campos!.add(Campos(
                                idCampo: 0,
                                agrupacion: _listaAgrupaciones
                                    .elementAt(i)
                                    .agrupacion!
                                    .toUpperCase(),
                                nombreCampo:
                                    'NUEVO CAMPO ${_nuevosCampos.length}',
                                tipoCampo: 'ALFANUMERICO',
                                restriccion: '[N/A]',
                                longitud: 100,
                                controladorNombreCampo: controllerCampoNombre,
                                valorTipoCampo: '',
                                controladorRestriccion: controladorRestriccion,
                                controladorLongitud: controladorLongitud,
                                valorController: new TextEditingController()));
                            _expanded['NUEVO CAMPO ${_nuevosCampos.length}'] =
                                false;
                            _nuevosCampos
                                .add('NUEVO CAMPO ${_nuevosCampos.length}');
                            setState(() {});
                            Navigator.pop(context);
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            Text('Nuevo Campo'),
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        children: <DragAndDropItem>[
          for (int j = 0;
              j < _listaAgrupaciones.elementAt(i).campos!.length;
              j++)
            DragAndDropItem(
                canDrag: _listaAgrupaciones
                            .elementAt(i)
                            .campos!
                            .elementAt(j)
                            .nombreCampo ==
                        'FOLIO'
                    ? false
                    : true,
                child: Container(
                  child: _crearCampo(
                      _listaAgrupaciones.elementAt(i).campos!.elementAt(j),
                      _listaAgrupaciones.elementAt(i).agrupacion!),
                )),
        ],
      ));
    }
    return campos;
  }

  Widget _crearCampo(Campos campo, String agrupacion) {
    return _tarjetaCampos(campo, agrupacion);
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      Campos campoMovido =
          _listaAgrupaciones[oldListIndex].campos!.removeAt(oldItemIndex);
      _listaAgrupaciones[newListIndex]
          .campos!
          .insert(newItemIndex, campoMovido);
      var movedItem = _campos[oldListIndex].children!.removeAt(oldItemIndex);
      _campos[newListIndex].children!.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      Agrupaciones agrupacionMovida = _listaAgrupaciones.removeAt(oldListIndex);
      _listaAgrupaciones.insert(newListIndex, agrupacionMovida);
      var movedList = _campos.removeAt(oldListIndex);
      _campos.insert(newListIndex, movedList);
    });
  }

  Widget _camposVertical(Campos campo) {
    return Container(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    _etiquetaCampo('CAMPO:'),
                    _txtCampo(campo.controladorNombreCampo!),
                  ],
                ),
                Column(
                  children: [
                    _etiquetaCampo('tipo campo:'),
                    // _tipoCampo(campo),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          campo.tipoCampo == 'FIRMA' || campo.tipoCampo == 'CATALOGO'
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _etiquetaCampo('restriccion:'),
                        _txtCampo(campo.controladorRestriccion!),
                      ],
                    ),
                    Column(
                      children: [
                        _etiquetaCampo('tamaño:'),
                        _numCampo(campo.controladorLongitud!),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _camposHorizontal(Campos campo) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollCampo,
          child: Row(
            children: [
              _etiquetaCampo('tipo campo:'),
              // _tipoCampo(campo),
              // SizedBox(
              //   width: 20.0,
              // ),
              _etiquetaCampo('CAMPO:'),
              _txtCampo(campo.controladorNombreCampo!),
              SizedBox(
                width: 20.0,
              ),
              campo.tipoCampo == 'FIRMA' ||
                      campo.tipoCampo == 'CATALOGO' ||
                      campo.tipoCampo == 'CHECKBOX' ||
                      campo.tipoCampo == 'CALENDARIO'
                  ? Container()
                  : _etiquetaCampo('restriccion:'),
              campo.tipoCampo == 'FIRMA' ||
                      campo.tipoCampo == 'CATALOGO' ||
                      campo.tipoCampo == 'CHECKBOX' ||
                      campo.tipoCampo == 'CALENDARIO'
                  ? Container()
                  : _txtCampo(campo.controladorRestriccion!),
              SizedBox(
                width: 30.0,
              ),
              campo.tipoCampo == 'FIRMA' ||
                      campo.tipoCampo == 'CATALOGO' ||
                      campo.tipoCampo == 'CHECKBOX' ||
                      campo.tipoCampo == 'CALENDARIO'
                  ? Container()
                  : _etiquetaCampo('tamaño:'),
              campo.tipoCampo == 'FIRMA' ||
                      campo.tipoCampo == 'CATALOGO' ||
                      campo.tipoCampo == 'CHECKBOX' ||
                      campo.tipoCampo == 'CALENDARIO'
                  ? Container()
                  : _numCampo(campo.controladorLongitud!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _etiquetaCampo(String etiqueta) {
    return Container(
      width: 100.0,
      height: 50.0,
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 5.0, bottom: 20.0),
      child: Text(etiqueta.toUpperCase()),
    );
  }

  Widget _txtCampo(TextEditingController controlador) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      width: 250.0,
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            hintText: controlador.text),
        inputFormatters: <TextInputFormatter>[
          UpperCaseTextFormatter(),
        ],
        maxLength: 100,
        onChanged: (String valor) {
          Future.delayed(Duration(seconds: 5), () {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _numCampo(TextEditingController controlador) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      width: 100.0,
      child: TextField(
        controller: controlador,
        decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            hintText: controlador.text),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: 3,
      ),
    );
  }

  Widget _tarjetaCampos(Campos campo, String agrupacion) {
    return FadeOutLeft(
      controller: (controller) =>
          _animateController[campo.nombreCampo!] = controller,
      animate: false,
      child: TarjetaNuevoCampo(
        campo: campo,
        agrupacion: agrupacion,
        listaAgrupaciones: _listaAgrupaciones,
        eliminar: () async {
          print('Campo a eliminar: ${campo.nombreCampo}');
          for (Agrupaciones agrupaciones in _listaAgrupaciones) {
            if (agrupaciones.agrupacion == agrupacion) {
              for (int i = 0; i < agrupaciones.campos!.length; i++) {
                if (campo.nombreCampo ==
                    agrupaciones.campos!.elementAt(i).nombreCampo) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        title: Container(
                            child: Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text("Confirmar"),
                          ],
                        )),
                        children: <Widget>[
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Text(
                                  'Estas seguro de eliminar el campo: ${campo.nombreCampo!.toUpperCase()}'),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 10.0, right: 10.0),
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _animateController[campo.nombreCampo]!
                                        .forward();
                                    agrupaciones.campos!.removeAt(i);
                                    setState(() {});
                                  },
                                  child: Text('Si'),
                                ),
                              ),
                              Expanded(child: Container()),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 10.0, right: 10.0),
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            }
          }
        },
        scrollCampo: _scrollCampo,
      ),
    );
  }

  //TODO: EN DADO CASO QUE NO SE ALMACENE EL TIPO DE CAMPO COMPROBAR ESTE METODO
  // Widget _tipoCampo(Campos campo) {
  //   List<String> tipos = [
  //     'NUMERICO',
  //     'ALFANUMERICO',
  //     'CORREO',
  //     'ALFABETICO',
  //     'CATALOGO',
  //     'FIRMA',
  //     'FOTO',
  //     'CALENDARIO',
  //     'CHECKBOX',
  //   ];
  //   String seleccion = 'ALFANUMERICO';

  //   switch (campo.tipoCampo!.toUpperCase()) {
  //     case 'NUMERICO':
  //       seleccion = tipos.elementAt(0);
  //       break;
  //     case 'ALFANUMERICO':
  //       seleccion = tipos.elementAt(1);
  //       break;
  //     case 'CORREO':
  //       seleccion = tipos.elementAt(2);
  //       break;
  //     case 'ALFABETICO':
  //       seleccion = tipos.elementAt(3);
  //       break;
  //     case 'CATALOGO':
  //       seleccion = tipos.elementAt(4);
  //       break;
  //     case 'FIRMA':
  //       seleccion = tipos.elementAt(5);
  //       break;
  //     case 'FOTO':
  //       seleccion = tipos.elementAt(6);
  //       break;
  //     case 'CALENDARIO':
  //       seleccion = tipos.elementAt(7);
  //       break;
  //     case 'CHECKBOX':
  //       seleccion = tipos.elementAt(8);
  //       break;
  //     default:
  //       seleccion = 'ALFANUMERICO';
  //       break;
  //   }
  //   return TipoCampo(
  //     tipoSeleccionado: seleccion,
  //     accion: (String valor) {
  //       setState(() {
  //         for (int i = 0; i < _listaAgrupaciones.length; i++) {
  //           for (int j = 0;
  //               j < _listaAgrupaciones.elementAt(i).campos!.length;
  //               j++) {
  //             if (_listaAgrupaciones
  //                     .elementAt(i)
  //                     .campos!
  //                     .elementAt(j)
  //                     .nombreCampo ==
  //                 campo.nombreCampo) {
  //               _listaAgrupaciones.elementAt(i).campos!.elementAt(j).tipoCampo =
  //                   valor;
  //               if (_listaAgrupaciones
  //                           .elementAt(i)
  //                           .campos!
  //                           .elementAt(j)
  //                           .tipoCampo ==
  //                       'FIRMA' ||
  //                   _listaAgrupaciones
  //                           .elementAt(i)
  //                           .campos!
  //                           .elementAt(j)
  //                           .tipoCampo ==
  //                       'CATALOGO') {
  //                 _listaAgrupaciones
  //                     .elementAt(i)
  //                     .campos!
  //                     .elementAt(j)
  //                     .controladorRestriccion = new TextEditingController();
  //                 _listaAgrupaciones
  //                     .elementAt(i)
  //                     .campos!
  //                     .elementAt(j)
  //                     .controladorLongitud = new TextEditingController();
  //               } else {
  //                 TextEditingController controladorRestriccion =
  //                     new TextEditingController();
  //                 TextEditingController controladorLongitud =
  //                     new TextEditingController();
  //                 controladorRestriccion.text = 'N/A';
  //                 controladorLongitud.text = '100';
  //                 _listaAgrupaciones
  //                     .elementAt(i)
  //                     .campos!
  //                     .elementAt(j)
  //                     .controladorRestriccion = controladorRestriccion;
  //                 _listaAgrupaciones
  //                     .elementAt(i)
  //                     .campos!
  //                     .elementAt(j)
  //                     .controladorLongitud = controladorLongitud;
  //               }
  //             }
  //           }
  //         }
  //       });
  //     },
  //   );
  // }

  void _crearProyecto() async {
    Navigator.of(context).pop();
    PantallaDeCarga.loadingI(context, true);
    List<Agrupaciones> nuevaLista = _actualizarDatos(_listaAgrupaciones);
    await crearProyecto(ApiDefinition.ipServer, nuevaLista, _nombreProyecto,
        _tipoProyectoSeleccionado!);

    // Database db = database();
    // DatabaseReference ref = db.ref('TotalDatos');

    // await ref.child(_nombreProyecto).set({
    //   'NUEVO': Random().nextInt(100),
    //   'ASIGNADO': Random().nextInt(100),
    //   'PENDIENTE': Random().nextInt(100),
    //   'EN PROCESO': Random().nextInt(100),
    //   'CERRADO': Random().nextInt(100),
    // });

    // FirebaseDatabaseWeb.instance
    //     .reference()
    //     .child('TotalDatos')
    //     .child(_nombreProyecto)
    //     .update({
    //   "tipoProyecto": _tipoProyectoSeleccionado,
    //   "totalAsignados": 0,
    //   "totalCerrados": 0,
    //   "totalEnProceso": 0,
    //   "totalNuevos": 0,
    //   "totalPendientes": 0,
    // });

    PantallaDeCarga.loadingI(context, false);
    _listaAgrupaciones = [];
    _tipoProyectoSeleccionado = null;
    setState(() {});
    Navigator.pop(context, 'NUEVO');
  }

  List<Agrupaciones> _actualizarDatos(List<Agrupaciones> agrupaciones) {
    List<Agrupaciones> lista = [];
    List<Agrupaciones> respuesta = [];
    for (Agrupaciones item in agrupaciones) {
      lista.add(Agrupaciones(agrupacion: item.agrupacion, campos: []));
      respuesta.add(Agrupaciones(agrupacion: item.agrupacion, campos: []));
      for (Campos campo in item.campos!) {
        lista.last.campos!.add(Campos(
          idCampo: campo.idCampo,
          agrupacion: campo.agrupacion,
          nombreCampo: campo.controladorNombreCampo!.text,
          tipoCampo: campo.tipoCampo,
          restriccion:
              campo.tipoCampo == 'FIRMA' || campo.tipoCampo == 'CATALOGO'
                  ? 'N/A'
                  : campo.controladorRestriccion!.text,
          longitud: campo.tipoCampo == 'FIRMA' || campo.tipoCampo == 'CATALOGO'
              ? 100
              : int.parse(campo.controladorLongitud!.text),
          controladorNombreCampo: campo.controladorNombreCampo,
          valorTipoCampo: campo.valorTipoCampo,
          controladorRestriccion: campo.controladorRestriccion,
          controladorLongitud: campo.controladorLongitud,
          valor: campo.valorController!.text,
        ));
        respuesta.last.campos!.add(Campos(
          idCampo: campo.idCampo,
          agrupacion: campo.agrupacion,
          nombreCampo: campo.controladorNombreCampo!.text,
          tipoCampo: campo.tipoCampo,
          restriccion:
              campo.tipoCampo == 'FIRMA' || campo.tipoCampo == 'CATALOGO'
                  ? 'N/A'
                  : campo.controladorRestriccion!.text,
          longitud: campo.tipoCampo == 'FIRMA' || campo.tipoCampo == 'CATALOGO'
              ? 100
              : int.parse(campo.controladorLongitud!.text),
          controladorNombreCampo: campo.controladorNombreCampo,
          valorTipoCampo: campo.valorTipoCampo,
          controladorRestriccion: campo.controladorRestriccion,
          controladorLongitud: campo.controladorLongitud,
          valor: campo.valorController!.text,
        ));
      }
    }
    for (int i = 0; i < lista.length; i++) {
      if (lista.elementAt(i).campos!.isEmpty) {
        respuesta.removeAt(i);
      }
    }

    return respuesta;
  }
}
