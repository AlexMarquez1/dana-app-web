import 'dart:convert';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/HistorialCambios.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/ValoresCampo.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TablaHistorico.dart';
import 'package:app_isae_desarrollo/src/page/widgets/tipoDeCampos.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import '../../models/Agrupaciones.dart';
import '../../models/Campos.dart';
import '../../models/CamposProyecto.dart';
import '../../models/Evidencia.dart';
import '../../models/Firma.dart';
import '../../models/Proyecto.dart';
import '../../models/Usuario.dart';
import '../../models/ValoresCampos.dart';
import '../../providers/registroProvider.dart';
import '../../services/APIWebService/ApiDefinitions.dart';
import '../../services/APIWebService/Consultas.dart';
import '../../utils/VariablesGlobales.dart';

class EditarRegistro extends StatelessWidget {
  Size size;
  Proyecto proyecto;
  GlobalKey<FormState> formKeyRegistro;
  Usuario usuarioSeleccionado;
  Inventario inventarioSeleccionado;
  RegistroProvider registroProvider;
  ScrollController _scrollController = ScrollController();
  StateSetter? actualizar;
  bool? nuevo = false;
  EditarRegistro({
    required this.size,
    required this.proyecto,
    required this.formKeyRegistro,
    required this.usuarioSeleccionado,
    required this.inventarioSeleccionado,
    required this.registroProvider,
    this.actualizar,
    this.nuevo,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: size.width > 700
              ? StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                  return _cargarCampos(context, 'columna', proyecto, setState);
                })
              : StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                  return _cargarCampos(context, 'fila', proyecto, setState);
                }),
        ),
        VariablesGlobales.usuario.perfil!.idperfil != "4"
            ? _condicionesPemexBorrado(context)
            : Container(),
      ],
    );
  }

  Widget _condicionesPemexBorrado(BuildContext context) {
    //Aldair 123
    //Mariana 128
    //PemexBorrado 151
    if (proyecto.idproyecto == 151) {
      // print(registroProvider.listaAgrupaciones
      //     .elementAt(1)
      //     .campos
      //     .elementAt(20)
      //     .valor);
      if (registroProvider.listaAgrupaciones
                      .elementAt(1)
                      .campos!
                      .elementAt(20)
                      .valor ==
                  'ENTREGADO A STE' &&
              VariablesGlobales.usuario.idUsuario == 123 ||
          VariablesGlobales.usuario.idUsuario == 128) {
        return _botones(context);
      } else {
        if (registroProvider.listaAgrupaciones
                .elementAt(1)
                .campos!
                .elementAt(20)
                .valor !=
            'ENTREGADO A STE') {
          return _botones(context);
        } else {
          return Container();
        }
      }
    } else {
      return _botones(context);
    }
  }

  Widget _botones(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            alignment: Alignment.centerRight,
            child: nuevo!
                ? ElevatedButton(
                    onPressed: () async {
                      String respuestaDuplicados =
                          await _validarDuplicidadProyecto(proyecto);
                      print('Respuesta duplicados: $respuestaDuplicados');
                      if (respuestaDuplicados == 'SIN DUPLICADOS') {
                        if (usuarioSeleccionado != null) {
                          if (formKeyRegistro.currentState!.validate()) {
                            formKeyRegistro.currentState!.save();
                            print('Todos los campos tienen informacion');
                            _mensaje(
                                context,
                                '¿Estas seguro de crear un registro?',
                                proyecto,
                                usuarioSeleccionado != null
                                    ? usuarioSeleccionado
                                    : VariablesGlobales.usuario);
                          } else {
                            print(
                                'Id Campo Folio: ${registroProvider.listaAgrupaciones.elementAt(0).campos!.elementAt(0).idCampo} ');
                            if (registroProvider.listaAgrupaciones
                                .elementAt(0)
                                .campos!
                                .elementAt(0)
                                .valorController!
                                .text
                                .isNotEmpty) {
                              print('Folio con informacion');
                              formKeyRegistro.currentState!.save();
                              _mensaje(
                                  context,
                                  '¿Estas seguro de crear un registro con uno o mas campos vacios?',
                                  proyecto,
                                  usuarioSeleccionado != null
                                      ? usuarioSeleccionado
                                      : VariablesGlobales.usuario);
                            } else {
                              Dialogos.error(context,
                                  'Existen uno o mas campos sin informacion, revisalo y vuelve a intentar');
                            }
                          }
                        } else {
                          Dialogos.mensaje(
                              context, 'Selecciona usuario para asignar');
                        }
                      } else {
                        Dialogos.mensaje(
                          context,
                          "Se encuentran algunos valores ${respuestaDuplicados.replaceAll('[', '\n [')}",
                        );
                      }
                    },
                    child: Text('Crear'))
                : ElevatedButton(
                    onPressed: () async {
                      PantallaDeCarga.loadingI(context, true);
                      formKeyRegistro.currentState!.save();
                      List<ValoresCampos> valores = [];
                      String respuestaDuplicados = '';

                      respuestaDuplicados = await _validarDuplicidad();

                      if (respuestaDuplicados == 'SIN DUPLICADOS') {
                        for (Agrupaciones agrupaciones
                            in registroProvider.listaAgrupaciones) {
                          for (Campos item in agrupaciones.campos!) {
                            try {
                              valores.add(ValoresCampos(
                                valor: item.valorController!.text,
                                idcampoproyecto: item.idCampo,
                                idinventario:
                                    inventarioSeleccionado.idinventario,
                              ));

                              if (item.tipoCampo == 'CATALOGO-INPUT') {
                                if (item.valorController!.text.isNotEmpty) {
                                  await nuevoCatalogoAutoCompleteUsuario(
                                      ApiDefinition.ipServer,
                                      item.nombreCampo!,
                                      proyecto.idproyecto!,
                                      usuarioSeleccionado.idUsuario!,
                                      item.valorController!.text);
                                }
                              }
                            } catch (e) {
                              print('Error en el ordenamiento de datos: $e');
                            }
                          }
                        }

                        PantallaDeCarga.loadingI(context, false);
                        Dialogos.advertencia(
                            context, 'Seguro que quieres guardar los cambios?',
                            () async {
                          Map<String, dynamic> mandarDatos = {};
                          mandarDatos['ind'] = 0;
                          mandarDatos['inventario'] = inventarioSeleccionado;
                          mandarDatos['usuario'] = VariablesGlobales.usuario;

                          mandarDatos['listaAgrupaciones'] =
                              registroProvider.listaAgrupaciones;

                          mandarDatos['firmas'] =
                              _guardarFirmas(inventarioSeleccionado);

                          mandarDatos['fotos'] = _guardarEvidencia(
                              inventarioSeleccionado.idinventario!);

                          mandarDatos['estatus'] =
                              inventarioSeleccionado.estatus;

                          mandarDatos['evidencias'] = _guardarEvidencias(
                              inventarioSeleccionado.idinventario!);

                          PantallaDeCarga.loadingI(context, true);

                          await actualizarValores(
                              ApiDefinition.ipServer, mandarDatos);

                          // await actualizarValoresCampos(
                          //     ApiDefinition.ipServer, valores);
                          // Inventario nuevoInventario = Inventario(
                          //   idinventario: inventarioSeleccionado.idinventario,
                          //   folio: valores.elementAt(0).valor,
                          //   proyecto: inventarioSeleccionado.proyecto,
                          //   estatus: inventarioSeleccionado.estatus,
                          //   fechacreacion: inventarioSeleccionado.fechacreacion,
                          // );
                          // await actualizarFolioRegsitro(
                          //     ApiDefinition.ipServer, nuevoInventario);

                          //TODO: Comprobar si es necesario eliminar las evidencias
                          // await eliminarEvidencia(ApiDefinition.ipServer,
                          //     inventarioSeleccionado.idinventario);
                          // await _guardarEvidencias(
                          //     inventarioSeleccionado.idinventario);
                          // await _guardarEvidencia(
                          //     inventarioSeleccionado.idinventario);
                          actualizar!(() {});
                          //Genera al documento tras una actualizacion de datos
                          await volverAGenerarDocumento(ApiDefinition.ipServer,
                              inventarioSeleccionado.idinventario!);
                          Future.delayed(Duration(seconds: 5), () {
                            PantallaDeCarga.loadingI(context, false);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          });
                        });
                      } else {
                        PantallaDeCarga.loadingI(context, false);
                        Dialogos.mensaje(
                          context,
                          "Se encuentran algunos valores ${respuestaDuplicados.replaceAll('[', '\n [')}",
                        );
                      }
                    },
                    child: Text('Aceptar'),
                  ),
          ),
          Container(
              padding: EdgeInsets.only(top: 10.0, right: 10.0),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              )),
          Expanded(child: Container()),
          VariablesGlobales.usuario.perfil!.idperfil == '1' ||
                  VariablesGlobales.usuario.perfil!.idperfil == '2'
              ? Container(
                  padding: EdgeInsets.only(top: 10.0, right: 10.0),
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: 'Historial de cambios',
                    child: ElevatedButton(
                      onPressed: () async {
                        await showGeneralDialog(
                          barrierLabel: "Label",
                          barrierDismissible: true,
                          barrierColor: Colors.black.withOpacity(0),
                          transitionDuration: Duration(milliseconds: 700),
                          context: context,
                          pageBuilder: (context, anim1, anim2) {
                            return SimpleDialog(
                              shape: RoundedRectangleBorder(
                                  side:
                                      BorderSide(color: Colors.white, width: 3),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              alignment: Alignment.bottomRight,
                              title: Container(
                                height: 50.0,
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    Expanded(child: Container()),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                              ),
                              contentPadding: EdgeInsets.all(10.0),
                              children: [
                                Container(
                                  width: 800.0,
                                  height: 700.0,
                                  color: Colors.grey[200],
                                  child: FutureBuilder(
                                    future: obtenerHistorialPorInventario(
                                        ApiDefinition.ipServer,
                                        inventarioSeleccionado),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        int currentSortColumn = 0;
                                        bool isAscending = true;
                                        List<HistorialCambios> historial;
                                        historial = snapshot.data;
                                        return StatefulBuilder(
                                            builder: (context, ordenar) {
                                          return Container(
                                            child: SingleChildScrollView(
                                              child: _construyendoTabla(
                                                  context,
                                                  historial,
                                                  ordenar,
                                                  currentSortColumn,
                                                  isAscending),
                                            ),
                                          );
                                        });
                                      } else {
                                        return LoadingBouncingGrid.circle();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                          transitionBuilder: (context, anim1, anim2, child) {
                            return SlideTransition(
                              position:
                                  Tween(begin: Offset(1, 0), end: Offset(0, 0))
                                      .animate(anim1),
                              child: child,
                            );
                          },
                        );
                      },
                      child: Icon(Icons.history),
                    ),
                  ))
              : Container(),
        ],
      ),
    );
  }

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
                                    registroProvider.listaAgrupaciones
                                        .elementAt(0)
                                        .campos!
                                        .elementAt(0)
                                        .valorController!
                                        .text,
                                    proyecto.idproyecto!);
                            if (idInventario.first != 'existe') {
                              if (idInventario.elementAt(0) != 'NULL') {
                                List<ValoresCampo> listaValores = [];
                                for (Agrupaciones agrupaciones
                                    in registroProvider.listaAgrupaciones) {
                                  for (Campos campo in agrupaciones.campos!) {
                                    listaValores.add(ValoresCampo(
                                        idCampo: campo.idCampo,
                                        idInventario:
                                            int.parse(idInventario.first),
                                        valor: campo.valorController!.text));

                                    if (campo.tipoCampo == 'CATALOGO-INPUT') {
                                      if (campo.valorController!.text
                                              .isNotEmpty &&
                                          campo.valorController!.text.length >
                                              2) {
                                        await nuevoCatalogoAutoCompleteUsuario(
                                            ApiDefinition.ipServer,
                                            campo.nombreCampo!,
                                            proyecto.idproyecto!,
                                            usuario.idUsuario!,
                                            campo.valorController!.text);
                                      }
                                    }
                                  }
                                }

                                await crearRegistro(
                                    ApiDefinition.ipServer, listaValores);
                                if (usuarioSeleccionado != null) {
                                  await asignarRegistro(
                                      ApiDefinition.ipServer,
                                      usuarioSeleccionado.idUsuario!,
                                      idInventario);
                                } else {
                                  await asignarRegistro(
                                      ApiDefinition.ipServer,
                                      VariablesGlobales.usuario.idUsuario!,
                                      idInventario);
                                }
                                List<Firma> listaFirmas = _guardarFirmas(
                                    Inventario(
                                        idinventario:
                                            int.parse(idInventario.first)));
                                List<Evidencia> listaEvidencia =
                                    _guardarEvidencia(
                                        int.parse(idInventario.first));
                                List<Evidencia> listaEvidencias =
                                    _guardarEvidencias(
                                        int.parse(idInventario.first));

                                listaFirmas.forEach((element) async {
                                  await actualizarFirmas(
                                      ApiDefinition.ipServer, element);
                                });

                                listaEvidencia.forEach((element) async {
                                  await actualizarEvidencia(
                                      ApiDefinition.ipServer,
                                      element,
                                      VariablesGlobales.usuario.idUsuario!);
                                });

                                listaEvidencias.forEach((element) async {
                                  await actualizarEvidencia(
                                      ApiDefinition.ipServer,
                                      element,
                                      VariablesGlobales.usuario.idUsuario!);
                                });
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

  Widget _construyendoTabla(
      BuildContext context,
      List<HistorialCambios> historial,
      StateSetter ordenar,
      int currentSortColumn,
      bool isAscending) {
    return PaginatedDataTable(
      sortColumnIndex: currentSortColumn,
      sortAscending: isAscending,
      source: TablaHistorico(
        context,
        historial,
        (String valor, Function descargar) async {
          await showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return SimpleDialog(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  title: Container(
                    height: 40.0,
                    width: 30.0,
                    child: Row(children: [
                      Expanded(child: Container()),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ]),
                  ),
                  children: <Widget>[
                    Container(
                      width: 45.0,
                      height: 45.0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[300],
                        child: IconButton(
                            onPressed: () async {
                              await descargar();
                            },
                            icon: Icon(Icons.download, color: Colors.white)),
                      ),
                    ),
                    Center(
                      child: Container(
                        //color: Colors.grey[300],
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 500.0,
                        child: LimitedBox(
                          maxHeight: 200.0,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/img/loadingImage.gif',
                            image: valor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              });
        },
        registroProvider,
      ),
      columns: [
        DataColumn(label: Text('Campo')),
        DataColumn(label: Text('Usuario')),
        DataColumn(label: Text('Anterior')),
        DataColumn(label: Text('Nuevo')),
        DataColumn(
          label: Text('Fecha'),
          onSort: (columnIndex, ascending) {
            ordenar(() {
              currentSortColumn = columnIndex;
              if (isAscending == true) {
                isAscending = false;
                // sort the product list in Ascending, order by Price
                historial.sort((historialA, historialB) =>
                    historialB.fechacambio!.compareTo(historialA.fechacambio!));
              } else {
                isAscending = true;
                // sort the product list in Descending, order by Price
                historial.sort((historialA, historialB) =>
                    historialA.fechacambio!.compareTo(historialB.fechacambio!));
              }
            });
          },
        ),
        DataColumn(label: Text('Hora')),
        DataColumn(label: Text('Restablecer')),
      ],
      header: Center(
        child: Text('Historial de cambios'),
      ),
      columnSpacing: 100.0,
      horizontalMargin: 60.0,
    );
  }

  Future<String> _validarDuplicidad() async {
    String respuesta = '';
    List<Campos> datosABuscar = [];
    for (Campos campo in registroProvider.camposAValidar) {
      print('Campo a comprobar: ${campo.nombreCampo}');
      Campos aux = campo;
      campo.valor = registroProvider.obtenerValorPorCampo(CamposProyecto(
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
          ApiDefinition.ipServer,
          datosABuscar,
          registroProvider.inventario.proyecto!.idproyecto!,
          registroProvider.inventario.idinventario!);
    } else {
      respuesta = 'SIN DUPLICADOS';
    }
    return respuesta;
  }

  Future<String> _validarDuplicidadProyecto(Proyecto proyecto) async {
    String respuesta = '';
    List<Campos> datosABuscar = [];
    for (Campos campo in registroProvider.camposAValidar) {
      print('Campo a comprobar: ${campo.nombreCampo}');
      Campos aux = campo;
      campo.valor = registroProvider.obtenerValorPorCampo(CamposProyecto(
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
          ApiDefinition.ipServer, datosABuscar, proyecto.idproyecto!, 0);
    } else {
      respuesta = 'SIN DUPLICADOS';
    }
    return respuesta;
  }

  Widget _cargarCampos(BuildContext context, String orientacion,
      Proyecto proyecto, StateSetter actualizar) {
    return Form(
      key: formKeyRegistro,
      child: Container(
        width: orientacion == 'columna'
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: registroProvider.listaAgrupaciones.length,
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
                    '${registroProvider.listaAgrupaciones.elementAt(index).agrupacion}'),
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

  List<Firma> _guardarFirmas(Inventario registro) {
    List<Firma> lista = [];
    for (String firma in registroProvider.firmas.keys) {
      if (registroProvider.comprobarFirmas[firma]!) {
        List<int> firmaInt = [];
        Uint8List byte = registroProvider.firmas[firma]!.buffer.asUint8List(
            registroProvider.firmas[firma]!.offsetInBytes,
            registroProvider.firmas[firma]!.lengthInBytes);
        firmaInt = byte.cast<int>();

        Firma datosFirma = Firma(
          idFirma: 0,
          nombreFirma: firma,
          firma: firmaInt,
          idInventario: registro.idinventario,
          idCampo: _obtenerIdCampo(firma),
        );
        lista.add(datosFirma);
        // await actualizarFirmas(ApiDefinition.ipServer, datosFirma);
      }
    }
    return lista;
  }

  List<Evidencia> _guardarEvidencias(int idRegistro) {
    List<Evidencia> lista = [];
    if (registroProvider.evidenciaCheckList.isNotEmpty) {
      registroProvider.evidenciaCheckList.forEach((key, value) {
        value.forEach((nombre, valor) async {
          List<int> evidenciaArray = valor.cast<int>();

          Evidencia fotoEvidencia = Evidencia(
            idEvidencia: 0,
            evidencia: evidenciaArray,
            idCampo: _obtenerIdCampo(key),
            idInventario: idRegistro,
            nombreEvidencia: nombre,
          );

          // await actualizarEvidencia(ApiDefinition.ipServer, fotoEvidencia,
          //     VariablesGlobales.usuario.idUsuario);
          lista.add(fotoEvidencia);
        });
      });
    }
    return lista;
  }

  List<Evidencia> _guardarEvidencia(int idRegistro) {
    List<Evidencia> lista = [];
    for (String evidencia in registroProvider.evidencia.keys) {
      if (registroProvider.comprobarFotos[evidencia]!) {
        List<int> evidenciaInt = [];
        Uint8List byte = registroProvider.evidencia[evidencia]!;
        evidenciaInt = byte.cast<int>();

        Evidencia fotoEvidencia = Evidencia(
          idEvidencia: 0,
          evidencia: evidenciaInt,
          idCampo: _obtenerIdCampo(evidencia),
          idInventario: idRegistro,
          nombreEvidencia: evidencia,
        );
        lista.add(fotoEvidencia);
        // await actualizarEvidencia(
        //     ApiDefinition.ipServer, fotoEvidencia, usuarioSeleccionado.idUsuario);
      }
    }
    return lista;
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

  int _obtenerIdCampo(String campoARecuperar) {
    int respuesta = 0;
    for (Agrupaciones agrupacion in registroProvider.listaAgrupaciones) {
      for (Campos campo in agrupacion.campos!) {
        if (campoARecuperar == campo.nombreCampo) {
          respuesta = campo.idCampo!;
          break;
        }
      }
    }

    return respuesta;
  }

  Widget _contruirCamposFila(
      int indAgrupacion, Proyecto proyecto, StateSetter actualizar) {
    return Column(
      children: [
        for (int i = 0;
            i <
                registroProvider.listaAgrupaciones
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
                    '${registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos!.elementAt(i).nombreCampo}'),
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

  Widget _contruirCamposColumna(
      int indAgrupacion, Proyecto proyecto, StateSetter actualizar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0;
            i <
                registroProvider.listaAgrupaciones
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
                    '${registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos!.elementAt(i).nombreCampo}'),
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
