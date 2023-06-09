import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';

import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/models/Catalogo.dart';
import 'package:app_isae_desarrollo/src/models/Evidencia.dart';
import 'package:app_isae_desarrollo/src/models/Firma.dart';
import 'package:app_isae_desarrollo/src/models/FirmaDocumento.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/Registro.dart';
import 'package:app_isae_desarrollo/src/models/TotalDatos.dart';
import 'package:app_isae_desarrollo/src/models/ValoresCampo.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/ListaUsuarios.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/page/widgets/tipoDeCampos.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/LeerExcel.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:checkbox_formfield/checkbox_list_tile_formfield.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase/firebase.dart';
// import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
// import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/CamposProyecto.dart';
import '../models/Usuario.dart';

class ProyectosPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeyRegistro = GlobalKey<FormState>();
  final _formKeyEliminarProyecto = GlobalKey<FormState>();
  RegistroProvider _registroProvider;

  List<Agrupaciones> _listaAgrupaciones = [];
  TextEditingController _nombreProyectoController = TextEditingController();
  TextEditingController _passwordEliminarProyectoController =
      new TextEditingController();
  TextEditingController _controllerUsuarios = TextEditingController();
  String _tipoProyectoSeleccionado;
  List<String> _listaTipoProyectos = [];
  List<Proyecto> _listaProyectos = [];
  List<Usuario> _listaUsuario = [];
  bool _camposRegistroOcultar = false;

  Map<String, int> _idCampofirma = new Map<String, int>();
  Map<String, int> _idCampoEvidencia = new Map<String, int>();

  Usuario _usuarioSeleccionado;

  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: false);
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
      child: Column(
        children: [
          Container(
            width: sizePantalla.width,
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                'Proyectos'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          // VariablesGlobales.usuario.perfil.perfil == 'Super Admin'
          //     ? sizePantalla.width > 800
          //         ? _obtenerFila(sizePantalla)
          //         : _obtenerColumna(sizePantalla)
          //     : _obtenerColumna(sizePantalla),
          _obtenerColumna(context, sizePantalla),
        ],
      ),
    );
  }

  Widget _obtenerFila(BuildContext context, Size sizePantalla) {
    return Row(
      children: [
        Container(
          width: sizePantalla.width / 2,
          margin: EdgeInsets.all(25.0),
          child: Card(
            borderOnForeground: true,
            color: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey, width: 3),
            ),
            child: _registroProyecto(context),
          ),
        ),
        Container(
          width: sizePantalla.width / 3,
          height: 300.0,
          margin: EdgeInsets.all(25.0),
          child: Card(
            borderOnForeground: true,
            color: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey, width: 3),
            ),
            child: SingleChildScrollView(
                child: _listaProyectos.isEmpty
                    ? _tablaProyectosBuilder(context)
                    : _tablaProyectos(context)),
          ),
        ),
      ],
    );
  }

  Widget _obtenerColumna(BuildContext context, Size sizePantalla) {
    return Column(
      children: [
        VariablesGlobales.usuario.perfil.perfil == 'Super Admin'
            ? Container(
                width: sizePantalla.width * 0.7,
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: Card(
                  borderOnForeground: true,
                  color: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey, width: 3),
                  ),
                  child: _registroProyecto(context),
                ),
              )
            : Container(),
        Container(
          width: sizePantalla.width * 0.7,
          height: sizePantalla.height * 0.6,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: Card(
            borderOnForeground: true,
            color: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey, width: 3),
            ),
            child: _listaProyectos.isEmpty
                ? _tablaProyectosBuilder(context)
                : _tablaProyectos(context),
          ),
        ),
      ],
    );
  }

  Widget _registroProyecto(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.0, left: 10.0),
          child: Text('Registrar proyecto'.toUpperCase()),
        ),
        Row(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Tooltip(
              message: 'Descargar Plantilla',
              textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
              child: IconButton(
                onPressed: () async {
                  //Generar un archivo excel con los campos disponibles para hacer
                  //un llenado de informacion mas rapido
                  String csv;
                  List<List<dynamic>> csvList = [];
                  csvList.add([
                    'campo',
                    'tipocampo',
                    'agrupacion',
                    'restriccion',
                    'longitud'
                  ]);

                  csvList.add([
                    '(NOMBRE DEL CAMPO)',
                    '(TIPO DEL CAMPO (NUMERICO,ALFANUMERICO,CORREO,ALFABETICO,CATALOGO,FIRMA,FOTO,CALENDARIO,CHECKBOX))',
                    '(NOMBRE DE LA AGRUPACION DE LOS CAMPOS)',
                    '(CARACTERES A UTILIZAR)',
                    '(10)'
                  ]);

                  csv = ListToCsvConverter().convert(csvList);
                  final content = base64Encode(csv.codeUnits);
                  final anchor = html.AnchorElement(
                      href:
                          "data:application/octet-stream;charset=utf-16le;base64,$content")
                    ..setAttribute('download', 'PantillaCamposProyecto.csv')
                    ..click();
                },
                icon: Icon(
                  Icons.description,
                  color: Colors.blue,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 10.0, top: 10.0, bottom: 15.0, right: 15.0),
              width: 250.0,
              child: TextField(
                controller: _nombreProyectoController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nombre del proyecto'),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp('[a-z A-Z 0-9]')),
                  UpperCaseTextFormatter(),
                ],
              ),
            ),
            _listaTipoProyectos.isEmpty
                ? _tipoProyectosBuildder()
                : _tipoProyectos(_listaTipoProyectos),
            ElevatedButton(
              onPressed: () {
                _obtenerCampos(context);
              },
              child: Text('Cargar campos'),
            )
          ],
        )
      ],
    );
  }

  Future<List<String>> _obtenerTipoProyecto() async {
    return await obtenerTipoProyectos(ApiDefinition.ipServer);
  }

  Widget _tipoProyectos(List<String> lista) {
    return StatefulBuilder(builder: (context, StateSetter actualizar) {
      return Container(
        width: 200.0,
        margin: EdgeInsets.only(left: 20.0, right: 30.0),
        child: DropdownButtonFormField(
          decoration: InputDecoration(
            hintText: 'Tipo de proyecto',
            border: OutlineInputBorder(),
          ),
          value: _tipoProyectoSeleccionado,
          onChanged: (valor) {
            _tipoProyectoSeleccionado = valor;
            actualizar(() {});
          },
          items: lista.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _tipoProyectosBuildder() {
    return FutureBuilder(
      future: _obtenerTipoProyecto(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapShot) {
        if (snapShot.hasData) {
          List<String> lista = [];
          for (String tipo in snapShot.data) {
            lista.add(tipo);
          }
          _listaTipoProyectos = lista;
          return _tipoProyectos(lista);
        } else {
          return Container(
            margin: EdgeInsets.only(left: 20.0, right: 30.0),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _obtenerCampos(BuildContext context) async {
    if (_nombreProyectoController.text.isEmpty) {
      Dialogos.error(context, 'Ingresa el nombre del proyecto');
    } else if (_tipoProyectoSeleccionado == null) {
      Dialogos.error(context, 'Selecciona el tipo de proyecto');
    } else {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        PlatformFile lectura = result.files.first;
        Uint8List fileBytes;
        String fileName;
        List<String> listaObtenida = [];
        if (result.files.first.bytes == null) {
          File archivo = new File(lectura.path);
          fileBytes = await archivo.readAsBytes();
          fileName = lectura.name;
          // listaObtenida = LeerExcel.leerArchivoCSV(fileBytes);
          listaObtenida = LeerExcel.leerCamposExcel(fileBytes);
        } else {
          fileBytes = lectura.bytes;
          fileName = lectura.name;
          // listaObtenida = LeerExcel.leerArchivoCSV(fileBytes);
          listaObtenida = LeerExcel.leerCamposExcel(fileBytes);
        }

        print('Ultimo registro: ${listaObtenida.last}');

        if (listaObtenida.last.contains('Error')) {
          print(listaObtenida.last);
          Dialogos.error(context, listaObtenida.last.split(':')[1]);
        } else {
          if (listaObtenida.isNotEmpty) {
            List<String> agrupaciones = _obtenerAgrupaciones(listaObtenida);
            Map<String, List<Campos>> campos = new Map<String, List<Campos>>();
            TextEditingController controllerCampoNombreFolio =
                TextEditingController();
            TextEditingController controladorRestriccionFolio =
                TextEditingController();
            TextEditingController controladorLongitudFolio =
                TextEditingController();
            controllerCampoNombreFolio.text = 'FOLIO';
            controladorRestriccionFolio.text = 'N/A';
            controladorLongitudFolio.text = '100';
            _listaAgrupaciones = [];
            _listaAgrupaciones
                .add(Agrupaciones(agrupacion: 'DATOS DEL REGISTRO', campos: [
              Campos(
                  idCampo: 0,
                  agrupacion: 'DATOS DEL REGISTRO',
                  nombreCampo: 'FOLIO',
                  tipoCampo: 'ALFANUMERICO',
                  restriccion: '[N/A]',
                  longitud: 100,
                  controladorNombreCampo: controllerCampoNombreFolio,
                  valorTipoCampo: '',
                  controladorRestriccion: controladorRestriccionFolio,
                  controladorLongitud: controladorLongitudFolio,
                  valorController: new TextEditingController()),
            ]));
            for (int i = 0; i < agrupaciones.length; i++) {
              _listaAgrupaciones.add(Agrupaciones(
                  agrupacion: agrupaciones.elementAt(i), campos: []));
              campos[agrupaciones.elementAt(i)] = [];
            }

            for (int i = 0; i < listaObtenida.length; i++) {
              if (i != 0 && listaObtenida.elementAt(i) != 'correcto') {
                if (listaObtenida.elementAt(i).length > 0) {
                  TextEditingController controllerCampo =
                      new TextEditingController();
                  TextEditingController controllerRestriccion =
                      new TextEditingController();
                  TextEditingController controllerLongitud =
                      new TextEditingController();
                  controllerCampo.text =
                      listaObtenida.elementAt(i).split(',')[0].toUpperCase();
                  controllerRestriccion.text =
                      listaObtenida.elementAt(i).split(',')[3].toUpperCase();
                  controllerLongitud.text =
                      listaObtenida.elementAt(i).split(',')[4];
                  campos[listaObtenida.elementAt(i).split(',')[2]].add(Campos(
                      idCampo: 0,
                      agrupacion: listaObtenida
                          .elementAt(i)
                          .split(',')[2]
                          .toUpperCase(),
                      nombreCampo: listaObtenida
                          .elementAt(i)
                          .split(',')[0]
                          .toUpperCase(),
                      tipoCampo: listaObtenida
                          .elementAt(i)
                          .split(',')[1]
                          .toUpperCase(),
                      restriccion: listaObtenida
                          .elementAt(i)
                          .split(',')[3]
                          .toUpperCase(),
                      longitud:
                          int.parse(listaObtenida.elementAt(i).split(',')[4]),
                      controladorNombreCampo: controllerCampo,
                      valorTipoCampo:
                          '${listaObtenida.elementAt(i).split(',')[1]}',
                      controladorRestriccion: controllerRestriccion,
                      controladorLongitud: controllerLongitud,
                      valorController: new TextEditingController()));
                }
              }
            }
            for (int i = 1; i < _listaAgrupaciones.length; i++) {
              _listaAgrupaciones.elementAt(i).campos =
                  campos[_listaAgrupaciones.elementAt(i).agrupacion];
            }
            TextEditingController controllerCampoNombreFirma =
                TextEditingController();
            TextEditingController controladorRestriccionFirma =
                TextEditingController();
            TextEditingController controladorLongitudFirma =
                TextEditingController();
            controllerCampoNombreFirma.text = 'TITULO FIRMA';
            controladorRestriccionFirma.text = 'N/A';
            controladorLongitudFolio.text = '100';
            _listaAgrupaciones.add(Agrupaciones(agrupacion: 'FIRMAS', campos: [
              Campos(
                  idCampo: 0,
                  agrupacion: 'FIRMAS',
                  nombreCampo: 'FIRMA',
                  tipoCampo: 'FIRMA',
                  restriccion: '[N/A]',
                  longitud: 100,
                  controladorNombreCampo: controllerCampoNombreFirma,
                  valorTipoCampo: '',
                  controladorRestriccion: controladorRestriccionFirma,
                  controladorLongitud: controladorLongitudFolio,
                  valorController: new TextEditingController()),
            ]));
            Map<String, dynamic> argumentos = {
              'listaAgrupaciones': _listaAgrupaciones,
              'nombreProyecto': _nombreProyectoController.text,
              'tipoProyecto': _tipoProyectoSeleccionado,
            };
            Navigator.pushNamed(context, '/camposproyecto',
                arguments: argumentos);
            _listaProyectos = [];
            // setState(() {});
          } else {
            print('Lista vacia');
          }
        }
        print('Nombre del archivo: $fileName');
        _camposRegistroOcultar = true;
      } else {
        print('Carga de archivos cancelada');
      }
    }
  }

  List<String> _obtenerAgrupaciones(List<String> lista) {
    List<String> agrupaciones = [];
    int comprobacion = 0;
    for (int i = 0; i < lista.length; i++) {
      if (i != 0) {
        if (agrupaciones.isEmpty) {
          agrupaciones.add(lista.elementAt(i).split(',')[2]);
        } else {
          if (lista.elementAt(i).length != 0) {
            if (lista.elementAt(i) != 'correcto') {
              comprobacion = agrupaciones.indexWhere(
                  (element) => element == lista.elementAt(i).split(',')[2]);
              if (comprobacion >= 0) {
              } else {
                agrupaciones.add(lista.elementAt(i).split(',')[2]);
              }
            }
          }
        }
      }
    }
    return agrupaciones;
  }

  Future<List<Proyecto>> _obtenerProyectos() async {
    if (VariablesGlobales.usuario.idUsuario == '1' ||
        VariablesGlobales.usuario.idUsuario == '2') {
      return await obtenerProyectos(ApiDefinition.ipServer);
    } else {
      return await obtenerProyectosAsignados(
          ApiDefinition.ipServer, VariablesGlobales.usuario);
    }
  }

  Widget _tablaProyectos(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: StatefulBuilder(builder: (context, StateSetter actualizar) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Text('Lista de Proyectos'.toUpperCase()),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, left: 10.0),
              child: DataTable(
                showCheckboxColumn: false,
                columns: [
                  DataColumn(label: Text('Proyecto'.toUpperCase())),
                  DataColumn(label: Text('Descripcion'.toUpperCase())),
                  DataColumn(label: Text('Fecha'.toUpperCase())),
                  VariablesGlobales.usuario.perfil.perfil == 'Super Admin'
                      ? DataColumn(label: Text('Eliminar'.toUpperCase()))
                      : DataColumn(label: Text('')),
                ],
                rows: _listaProyectos
                    .map((proyecto) => DataRow(
                            onSelectChanged: (seleccion) async {
                              PantallaDeCarga.loadingI(context, true);
                              _usuarioSeleccionado = null;
                              _listaUsuario = await _obtenerUsuarios();
                              await _registroProvider.nuevoRegistro(
                                proyecto,
                              );
                              PantallaDeCarga.loadingI(context, false);
                              _mostrarCampos(context, proyecto);
                            },
                            cells: [
                              DataCell(Text(proyecto.proyecto)),
                              DataCell(Text(proyecto.descripcion)),
                              DataCell(Text(proyecto.fechacreacion)),
                              VariablesGlobales.usuario.perfil.perfil ==
                                      'Super Admin'
                                  ? DataCell(IconButton(
                                      onPressed: () async {
                                        await _confirmarEliminarProyecto(
                                            context, proyecto, actualizar);
                                      },
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      )))
                                  : DataCell(Text('')),
                            ]))
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  _confirmarEliminarProyecto(
      BuildContext context, Proyecto proyecto, StateSetter actualizar) async {
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
                  Text('Eliminar Proyecto: ${proyecto.proyecto}'),
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
                        'Estas seguro de eliminar este proyecto, toda la informacion que contenga sera eliminada permanentemente (Registros, Evidencias, Fotografias, Documentos generados (PDF))'),
                    SizedBox(
                      height: 20.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contraseña para poder eliminar el proyecto'),
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
                                        'eliminarproyecto170313') {
                                      _passwordEliminarProyectoController.text =
                                          '';
                                      actualizar(() {});
                                      Dialogos.advertencia(context,
                                          'Estas seguro de eliminar el proyecto?',
                                          () async {
                                        PantallaDeCarga.loadingI(context, true);
                                        String respuesta =
                                            await eliminarProyecto(
                                                ApiDefinition.ipServer,
                                                proyecto);
                                        PantallaDeCarga.loadingI(
                                            context, false);
                                        if (respuesta == 'Correcto') {
                                          _listaProyectos = [];
                                          actualizar(() {});
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } else {
                                          Dialogos.error(context,
                                              'Ocurrio un problema al intentar eliminar el proyecto');
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

  _mostrarCampos(BuildContext context, Proyecto proyecto) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          Size size = MediaQuery.of(context).size;
          return StatefulBuilder(builder: (BuildContext context, state) {
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
                    SizedBox(
                      width: 20.0,
                    ),
                    VariablesGlobales.usuario.perfil.idperfil == '1' ||
                            VariablesGlobales.usuario.perfil.idperfil == '2' ||
                            VariablesGlobales.usuario.perfil.idperfil == '3'
                        ? Row(
                            children: [
                              Text('SELECCIONA USUARIO:'),
                              SizedBox(
                                width: 5.0,
                              ),
                              _comboUsuario(state, proyecto),
                            ],
                          )
                        : Row(children: [
                            Text('USUARIO:'),
                            _usuario(),
                          ]),
                    Expanded(child: Container()),
                    Tooltip(
                      message: 'Descargar Plantilla',
                      textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
                      child: IconButton(
                        onPressed: () async {
                          //Generar un archivo excel con los campos disponibles para hacer
                          //un llenado de informacion mas rapido
                          String csv;
                          List<String> campos = [];
                          List<List<dynamic>> csvList = [];

                          for (Agrupaciones item
                              in _registroProvider.listaAgrupaciones) {
                            for (Campos campo in item.campos) {
                              campos.add(campo.nombreCampo);
                            }
                          }
                          csvList.add(campos);

                          csv = ListToCsvConverter().convert(csvList);
                          final content = base64Encode(csv.codeUnits);
                          final anchor = html.AnchorElement(
                              href:
                                  "data:application/octet-stream;charset=utf-16le;base64,$content")
                            ..setAttribute('download',
                                'PantillaDatosProyecto${proyecto.proyecto}.csv')
                            ..click();
                        },
                        icon: Icon(
                          Icons.description,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Cargar Datos',
                      textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
                      child: IconButton(
                        onPressed: () async {
                          if (_usuarioSeleccionado != null) {
                            FilePickerResult result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['xlsx', 'xls'],
                            );
                            if (result != null) {
                              PantallaDeCarga.loadingI(context, true);
                              PlatformFile lectura = result.files.first;
                              Uint8List fileBytes;
                              String fileName;
                              List<String> listaObtenida = [];
                              Map<String, dynamic> respuestaDocumento =
                                  <String, dynamic>{};
                              String respuesta;
                              List<int> listaBytes;
                              if (result.files.first.bytes == null) {
                                File archivo = new File(lectura.path);
                                fileBytes = await archivo.readAsBytes();
                                fileName = lectura.name;
                                // listaObtenida =
                                //     LeerExcel.leerPlantillaDatosProyecto(
                                //         fileBytes, campos);
                                // respuestaDocumento = LeerExcel.leerDatosExcel(
                                //     fileBytes, campos, idCampos);
                                listaBytes = new List.from(fileBytes);
                                respuesta = await leerPantillaExcel(
                                  ApiDefinition.ipServer,
                                  listaBytes,
                                  _usuarioSeleccionado.idUsuario,
                                  proyecto.idproyecto,
                                );
                              } else {
                                fileBytes = lectura.bytes;
                                fileName = lectura.name;
                                // listaObtenida =
                                //     LeerExcel.leerPlantillaDatosProyecto(
                                //         fileBytes, campos);
                                // respuestaDocumento = LeerExcel.leerDatosExcel(
                                //     fileBytes, campos, idCampos);
                                listaBytes = new List.from(fileBytes);
                                respuesta = await leerPantillaExcel(
                                  ApiDefinition.ipServer,
                                  listaBytes,
                                  _usuarioSeleccionado.idUsuario,
                                  proyecto.idproyecto,
                                );
                              }
                              List<String> res = respuesta.split('>');

                              print(respuesta);
                              print(respuesta.contains('Error'));
                              if (res.elementAt(0) == 'correcto') {
                                await Dialogos.mensaje(context,
                                    'Se subieron los registros satisfactoriamente');
                              }

                              if (res.elementAt(0) == 'Folios Repetidos') {
                                String mensaje =
                                    'Los siguientes folios se encuentran repetidos eliminalos para poder subir los registros: ';
                                for (String item in res) {
                                  mensaje += '\n' + item;
                                }
                                await Dialogos.mensaje(context, mensaje);
                              }
                              if (respuesta.contains('Error')) {
                                //TODO: Comprobar porque este if no esta funcionando :/
                                await Dialogos.mensaje(
                                    context, res.elementAt(0));
                              }
                              // else {
                              //   Dialogos.mensaje(context,
                              //       'Error al subir los registros, consulta al administrador');
                              // }

                              PantallaDeCarga.loadingI(context, false);

                              // PantallaDeCarga.loadingI(context, true);
                              // List<String> campos = [];
                              // List<int> idCampos = [];

                              // for (Agrupaciones item
                              //     in _registroProvider.listaAgrupaciones) {
                              //   for (Campos campo in item.campos) {
                              //     campos.add(campo.nombreCampo);
                              //   }
                              // }

                              // for (Agrupaciones agrupaciones
                              //     in _registroProvider.listaAgrupaciones) {
                              //   for (Campos campo in agrupaciones.campos) {
                              //     idCampos.add(campo.idCampo);
                              //   }
                              // }
                              // FilePickerResult result =
                              //     await FilePicker.platform.pickFiles(
                              //   type: FileType.custom,
                              //   allowedExtensions: ['xlsx', 'xls'],
                              // );

                              // if (result != null) {
                              //   PlatformFile lectura = result.files.first;
                              //   Uint8List fileBytes;
                              //   String fileName;
                              //   List<String> listaObtenida = [];
                              //   Map<String, dynamic> respuestaDocumento =
                              //       <String, dynamic>{};
                              //   if (result.files.first.bytes == null) {
                              //     File archivo = new File(lectura.path);
                              //     fileBytes = await archivo.readAsBytes();
                              //     fileName = lectura.name;
                              //     // listaObtenida =
                              //     //     LeerExcel.leerPlantillaDatosProyecto(
                              //     //         fileBytes, campos);
                              //     respuestaDocumento = LeerExcel.leerDatosExcel(
                              //         fileBytes, campos, idCampos);
                              //   } else {
                              //     fileBytes = lectura.bytes;
                              //     fileName = lectura.name;
                              //     // listaObtenida =
                              //     //     LeerExcel.leerPlantillaDatosProyecto(
                              //     //         fileBytes, campos);
                              //     respuestaDocumento = LeerExcel.leerDatosExcel(
                              //         fileBytes, campos, idCampos);
                              //   }

                              //   print(
                              //       'Respuesta: ${respuestaDocumento['respuesta']}');

                              //   print('Nombre del archivo: $fileName');
                              //   if (respuestaDocumento['respuesta'] ==
                              //       'correcto') {
                              //     List<List<ValoresCampo>> listaValores =
                              //         respuestaDocumento['listaValores'];
                              //     List<String> folios =
                              //         respuestaDocumento['folios'];

                              //     List<String> respuesta =
                              //         await obtenerFoliosRegistrados(
                              //             ApiDefinition.ipServer,
                              //             folios,
                              //             proyecto.idproyecto);

                              //     print(respuesta);

                              //     if (respuesta.first == 'vacio') {
                              //       List<Registro> nuevosRegistros = [];

                              //       for (String folio in folios) {
                              //         nuevosRegistros.add(Registro(
                              //             folio: folio, proyecto: proyecto));
                              //       }

                              //       List<String> idRegistrosIngresados =
                              //           await crearInventarioPlantilla(
                              //               ApiDefinition.ipServer,
                              //               nuevosRegistros,
                              //               proyecto.idproyecto);

                              //       int idRegistro =
                              //           int.parse(idRegistrosIngresados.first);

                              //       int indAux = 0;
                              //       for (int i = 0;
                              //           i < listaValores.length;
                              //           i++) {
                              //         for (int j = 0;
                              //             j < listaValores.elementAt(i).length;
                              //             j++) {
                              //           listaValores
                              //               .elementAt(i)
                              //               .elementAt(j)
                              //               .idInventario = idRegistro;
                              //         }
                              //         // nuevosRegistros.elementAt(indAux).idRegistro =
                              //         //     idRegistro;
                              //         // indAux++;
                              //         idRegistro++;
                              //       }

                              //       await crearRegistroPlantilla(
                              //           ApiDefinition.ipServer, listaValores);
                              //       await asignarRegistro(
                              //           ApiDefinition.ipServer,
                              //           _usuarioSeleccionado.idUsuario,
                              //           idRegistrosIngresados);
                              //       PantallaDeCarga.loadingI(context, false);
                              //     } else {
                              //       PantallaDeCarga.loadingI(context, false);
                              //       Dialogos.error(context,
                              //           'Existen folios que ya se encuentran registrados \n $respuesta \n No se ingreso ningun registro.');
                              //     }

                              //     _camposRegistroOcultar = true;
                              //     PantallaDeCarga.loadingI(context, false);
                              //     Dialogos.mensaje(context,
                              //         'Se guardaron los registros con exito.');
                              //   } else {
                              //     PantallaDeCarga.loadingI(context, false);
                              //     Dialogos.mensaje(
                              //         context, respuestaDocumento['respuesta']);
                              //   }
                              // } else {
                              //   print('Carga de archivos cancelada');
                              //   PantallaDeCarga.loadingI(context, false);
                              // }
                            } else {
                              Dialogos.mensaje(context,
                                  'No se ha seleccionado ningun documento');
                            }
                          } else {
                            Dialogos.mensaje(context,
                                'Necesitas seleccionar un usuario para asignar los registros que se van a subir');
                          }
                        },
                        icon: Icon(
                          Icons.note_add,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _usuarioSeleccionado = null;
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
              ),
              children: <Widget>[
                Center(
                  child: size.width > 700
                      ? _cargarCampos(context, 'columna', proyecto, state)
                      : _cargarCampos(context, 'fila', proyecto, state),
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
                              String respuestaDuplicados =
                                  await _validarDuplicidad(proyecto);
                              print(
                                  'Respuesta duplicados: $respuestaDuplicados');
                              if (respuestaDuplicados == 'SIN DUPLICADOS') {
                                if (_usuarioSeleccionado != null) {
                                  if (_formKeyRegistro.currentState
                                      .validate()) {
                                    _formKeyRegistro.currentState.save();
                                    print(
                                        'Todos los campos tienen informacion');
                                    _mensaje(
                                        context,
                                        '¿Estas seguro de crear un registro?',
                                        proyecto,
                                        _usuarioSeleccionado);
                                  } else {
                                    print(
                                        'Id Campo Folio: ${_registroProvider.listaAgrupaciones.elementAt(0).campos.elementAt(0).idCampo} ');
                                    if (_registroProvider.listaAgrupaciones
                                        .elementAt(0)
                                        .campos
                                        .elementAt(0)
                                        .valorController
                                        .text
                                        .isNotEmpty) {
                                      print('Folio con informacion');
                                      _formKeyRegistro.currentState.save();
                                      _mensaje(
                                          context,
                                          '¿Estas seguro de crear un registro con uno o mas campos vacios?',
                                          proyecto,
                                          _usuarioSeleccionado);
                                    } else {
                                      Dialogos.error(context,
                                          'Existen uno o mas campos sin informacion, revisalo y vuelve a intentar');
                                    }
                                  }
                                } else {
                                  Dialogos.mensaje(context,
                                      'Selecciona usuario para asignar');
                                }
                              } else {
                                Dialogos.mensaje(
                                  context,
                                  "Se encuentran algunos valores ${respuestaDuplicados.replaceAll('[', '\n [')}",
                                );
                              }
                            },
                            child: Text('Aceptar'),
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 10.0, right: 10.0),
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              _usuarioSeleccionado = null;
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
        });
  }

  Future<String> _validarDuplicidad(Proyecto proyecto) async {
    String respuesta = '';
    List<Campos> datosABuscar = [];
    for (Campos campo in _registroProvider.camposAValidar) {
      print('Campo a comprobar: ${campo.nombreCampo}');
      Campos aux = campo;
      campo.valor = _registroProvider.obtenerValorPorCampo(CamposProyecto(
          idcamposproyecto: campo.idCampo,
          alerta: '',
          campo: '',
          validadDuplicidad: '',
          editable: '',
          longitud: 0,
          pattern: '',
          tipocampo: '',
          idAgrupacion: 0));

      datosABuscar.add(aux);
    }
    if (datosABuscar.isNotEmpty) {
      respuesta = await comprobarValoresDuplicado(
          ApiDefinition.ipServer, datosABuscar, proyecto.idproyecto, 0);
    } else {
      respuesta = 'SIN DUPLICADOS';
    }
    return respuesta;
  }

  Widget _usuario() {
    _usuarioSeleccionado = VariablesGlobales.usuario;
    return Text(_usuarioSeleccionado.usuario);
  }

  Widget _comboUsuario(StateSetter state, Proyecto proyecto) {
    return ListaUsuarios(
      controllerUsuarios: _controllerUsuarios,
      listaUsuarios: _listaUsuario,
      usuarioSeleccionado: _usuarioSeleccionado,
      actualizar: state,
      usuarioSeleccionadoAccion: (BuildContext context,
          Usuario usuarioSeleccionado, StateSetter actualizar) async {
        _usuarioSeleccionado = usuarioSeleccionado;
        Map<String, Catalogo> catalogos = await obtenerCatalogosProyectoUsuario(
            ApiDefinition.ipServer, proyecto, usuarioSeleccionado.idUsuario);
        catalogos.forEach((key, value) {
          if (value.catalogo != null) {
            _registroProvider.actualizarCatalogos(key, value);
          }
        });
        // _registroProvider.catalogos = catalogos;
      },
      usuariosSeleccionado: [],
      tipoBusqueda: 'SIMPLE',
    );
    // return Container(
    //   width: 250.0,
    //   child: DropdownButtonFormField(
    //     isExpanded: true,
    //     decoration: InputDecoration(
    //       border: OutlineInputBorder(),
    //       hintText: 'Usuarios',
    //     ),
    //     value: _usuarioSeleccionado,
    //     onChanged: ,
    //     items: _listaUsuario.map((item) {
    //       return DropdownMenuItem(
    //         value: item,
    //         child: Text(item.usuario),
    //       );
    //     }).toList(),
    //     validator: (Usuario value) {
    //       if (value == null) {
    //         return 'Selecciona un usuario';
    //       } else {
    //         return null;
    //       }
    //     },
    //   ),
    // );
  }

  Future<List<Usuario>> _obtenerUsuarios() async {
    return await obtenerUsuarios(ApiDefinition.ipServer);
  }

  // StateSetter _setState;

  _mensaje(BuildContext context, String mensaje, Proyecto proyecto,
      Usuario usuario) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Row(
              children: [
                Icon(Icons.warning),
                SizedBox(
                  width: 20.0,
                ),
                Container(child: Text("Mensaje")),
              ],
            ),
            children: <Widget>[
              Center(
                child: Container(
                    margin: EdgeInsets.all(30.0),
                    child: Text(mensaje.toUpperCase())),
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
                            PantallaDeCarga.loadingI(context, true);

                            List<String> idInventario =
                                await registrarInventario(
                                    ApiDefinition.ipServer,
                                    _registroProvider.listaAgrupaciones
                                        .elementAt(0)
                                        .campos
                                        .elementAt(0)
                                        .valorController
                                        .text,
                                    proyecto.idproyecto);
                            if (idInventario.first != 'existe') {
                              if (idInventario.elementAt(0) != 'NULL') {
                                List<ValoresCampo> listaValores = [];
                                for (Agrupaciones agrupaciones
                                    in _registroProvider.listaAgrupaciones) {
                                  for (Campos campo in agrupaciones.campos) {
                                    listaValores.add(ValoresCampo(
                                        idCampo: campo.idCampo,
                                        idInventario:
                                            int.parse(idInventario.first),
                                        valor: campo.valorController.text));

                                    if (campo.tipoCampo == 'CATALOGO-INPUT') {
                                      if (campo.valorController.text
                                              .isNotEmpty &&
                                          campo.valorController.text.length >
                                              2) {
                                        await nuevoCatalogoAutoCompleteUsuario(
                                            ApiDefinition.ipServer,
                                            campo.nombreCampo,
                                            proyecto.idproyecto,
                                            usuario.idUsuario,
                                            campo.valorController.text);
                                      }
                                    }
                                  }
                                }

                                await crearRegistro(
                                    ApiDefinition.ipServer, listaValores);
                                await asignarRegistro(
                                    ApiDefinition.ipServer,
                                    _usuarioSeleccionado.idUsuario,
                                    idInventario);
                                await _guardarFirmas(
                                    int.parse(idInventario.first));
                                await _guardarEvidencia(
                                    int.parse(idInventario.first));
                                await _guardarEvidencias(
                                    int.parse(idInventario.first));

                                Database db = database();
                                DatabaseReference ref = db.ref('TotalDatos');

                                await ref.child(proyecto.proyecto).set({
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
                                //         .child(proyecto.proyecto)
                                //         .once();
                                // TotalDatos datos =
                                //     TotalDatos.fromJson(snap.value);
                                // datos.totalNuevos = datos.totalNuevos + 1;

                                // FirebaseDatabaseWeb.instance
                                //     .reference()
                                //     .child('TotalDatos')
                                //     .child(proyecto.proyecto)
                                //     .update(datos.toJson());

                              } else {
                                print('Error al obtener el id del inventario');
                              }
                              Navigator.pop(context);

                              PantallaDeCarga.loadingI(context, false);
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context);

                              PantallaDeCarga.loadingI(context, false);
                              Dialogos.error(context,
                                  'El folio que intentas ingresar ya se encunetra registrado');
                            }
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

  _guardarFirmas(int idRegistro) async {
    for (String firma in _registroProvider.comprobarFirmas.keys) {
      if (_registroProvider.comprobarFirmas[firma]) {
        List<int> firmaInt = [];
        Uint8List byte = _registroProvider.firmas[firma].buffer.asUint8List(
            _registroProvider.firmas[firma].offsetInBytes,
            _registroProvider.firmas[firma].lengthInBytes);
        firmaInt = byte.cast<int>();

        Firma datosFirma = Firma(
          firma: firmaInt,
          idCampo: _obtenerIdCampo(firma),
          idInventario: idRegistro,
          nombreFirma: firma,
        );
        await actualizarFirmas(ApiDefinition.ipServer, datosFirma);
      }
    }
  }

  _guardarEvidencia(int idRegistro) async {
    for (String evidencia in _registroProvider.comprobarFotos.keys) {
      if (_registroProvider.comprobarFotos[evidencia]) {
        List<int> evidenciaInt = [];
        Uint8List byte = _registroProvider.evidencia[evidencia];
        evidenciaInt = byte.cast<int>();

        Evidencia datosFirma = Evidencia(
          evidencia: evidenciaInt,
          idCampo: _obtenerIdCampo(evidencia),
          idInventario: idRegistro,
          nombreEvidencia: evidencia,
        );
        await actualizarEvidencia(ApiDefinition.ipServer, datosFirma,
            VariablesGlobales.usuario.idUsuario);
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
              VariablesGlobales.usuario.idUsuario);
        });
      });
    }
  }

  int _obtenerIdCampo(String campoARecuperar) {
    int respuesta = 0;
    for (Agrupaciones agrupacion in _registroProvider.listaAgrupaciones) {
      for (Campos campo in agrupacion.campos) {
        if (campoARecuperar == campo.nombreCampo) {
          respuesta = campo.idCampo;
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
                          child: _contruirCamposFila(
                              context, index, proyecto, actualizar),
                        )
                      : _contruirCamposColumna(
                          context, index, proyecto, actualizar)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(String titulo) {
    return Container(
        width: 250.0,
        child: Row(
          children: <Widget>[
            Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              maxLines: 50,
              softWrap: false,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
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

  Widget _contruirCamposColumna(BuildContext context, int indAgrupacion,
      Proyecto proyecto, StateSetter actualizar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0;
            i <
                _registroProvider.listaAgrupaciones
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
                _nombreCampo(
                    '${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
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

  Widget _contruirCamposFila(BuildContext context, int indAgrupacion,
      Proyecto proyecto, StateSetter actualizar) {
    return Column(
      children: [
        for (int i = 0;
            i <
                _registroProvider.listaAgrupaciones
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
                _nombreCampo(
                    '${_registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
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

  Widget _tablaProyectosBuilder(BuildContext context) {
    return FutureBuilder(
      future: _obtenerProyectos(),
      builder: (BuildContext context, AsyncSnapshot<List<Proyecto>> snapShot) {
        if (snapShot.hasData) {
          _listaProyectos = snapShot.data;
          return _tablaProyectos(context);
        } else {
          return Container(
            child: LinearProgressIndicator(),
          );
        }
      },
    );
  }
}
