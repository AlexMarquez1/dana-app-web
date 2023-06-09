import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/tipoDeCampos.dart';
import 'package:flutter/material.dart';

import '../../models/Agrupaciones.dart';
import '../../models/Campos.dart';
import '../../models/CamposProyecto.dart';
import '../../models/Evidencia.dart';
import '../../models/Firma.dart';
import '../../models/Proyecto.dart';
import '../../models/Registro.dart';
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
  Registro registroSeleccionado;
  RegistroProvider registroProvider;
  ScrollController _scrollController = ScrollController();
  StateSetter actualizar;
  EditarRegistro({
    @required this.size,
    @required this.proyecto,
    @required this.formKeyRegistro,
    @required this.usuarioSeleccionado,
    @required this.registroSeleccionado,
    @required this.registroProvider,
    @required this.actualizar,
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
        VariablesGlobales.usuario.perfil.idperfil != "4"
            ? _condicionesPemexBorrado(context)
            : Container(),
      ],
    );
  }

  Widget _condicionesPemexBorrado(BuildContext context) {
    //Aldair 123
    //Mariana 128
    //PemexBorrado 151
    if (registroSeleccionado.proyecto.idproyecto == 151) {
      print(registroProvider.listaAgrupaciones
          .elementAt(1)
          .campos
          .elementAt(20)
          .valor);
      if (registroProvider.listaAgrupaciones
                      .elementAt(1)
                      .campos
                      .elementAt(20)
                      .valor ==
                  'ENTREGADO A STE' &&
              VariablesGlobales.usuario.idUsuario == 123 ||
          VariablesGlobales.usuario.idUsuario == 128) {
        return _botones(context);
      } else {
        if (registroProvider.listaAgrupaciones
                .elementAt(1)
                .campos
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
              child: ElevatedButton(
                onPressed: () async {
                  PantallaDeCarga.loadingI(context, true);
                  formKeyRegistro.currentState.save();
                  List<ValoresCampos> valores = [];
                  String respuestaDuplicados = '';

                  respuestaDuplicados = await _validarDuplicidad();

                  if (respuestaDuplicados == 'SIN DUPLICADOS') {
                    for (Agrupaciones agrupaciones
                        in registroProvider.listaAgrupaciones) {
                      for (Campos item in agrupaciones.campos) {
                        try {
                          valores.add(ValoresCampos(
                            valor: item.valorController.text,
                            idcampoproyecto: item.idCampo,
                            idinventario: registroSeleccionado.idRegistro,
                          ));

                          if (item.tipoCampo == 'CATALOGO-INPUT') {
                            if (item.valorController.text.isNotEmpty) {
                              await nuevoCatalogoAutoCompleteUsuario(
                                  ApiDefinition.ipServer,
                                  item.nombreCampo,
                                  proyecto.idproyecto,
                                  usuarioSeleccionado.idUsuario,
                                  item.valorController.text);
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
                      PantallaDeCarga.loadingI(context, true);

                      await actualizarValoresCampos(
                          ApiDefinition.ipServer, valores);
                      Inventario nuevoInventario = Inventario(
                        idinventario: registroSeleccionado.idRegistro,
                        folio: valores.elementAt(0).valor,
                        proyecto: registroSeleccionado.proyecto,
                        estatus: registroSeleccionado.estatus,
                        fechacreacion: registroSeleccionado.fechaCreacion,
                      );
                      await actualizarFolioRegsitro(
                          ApiDefinition.ipServer, nuevoInventario);
                      await _guardarFirmas(registroSeleccionado);
                      await eliminarEvidencia(ApiDefinition.ipServer,
                          registroSeleccionado.idRegistro);
                      await _guardarEvidencias(registroSeleccionado.idRegistro);
                      await _guardarEvidencia(registroSeleccionado.idRegistro);
                      actualizar(() {});
                      //Genera al documento tras una actualizacion de datos
                      await volverAGenerarDocumento(ApiDefinition.ipServer,
                          registroSeleccionado.idRegistro);
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
          registroProvider.inventario.proyecto.idproyecto,
          registroProvider.inventario.idinventario);
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
            print(
                registroProvider.listaAgrupaciones.elementAt(index).agrupacion);
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

  _guardarFirmas(Registro registro) async {
    for (String firma in registroProvider.firmas.keys) {
      if (registroProvider.comprobarFirmas[firma]) {
        List<int> firmaInt = [];
        Uint8List byte = registroProvider.firmas[firma].buffer.asUint8List(
            registroProvider.firmas[firma].offsetInBytes,
            registroProvider.firmas[firma].lengthInBytes);
        firmaInt = byte.cast<int>();

        Firma datosFirma = Firma(
          firma: firmaInt,
          idCampo: _obtenerIdCampo(firma),
          idInventario: registro.idRegistro,
          nombreFirma: firma,
        );
        await actualizarFirmas(ApiDefinition.ipServer, datosFirma);
      }
    }
  }

  Future<void> _guardarEvidencias(int idRegistro) async {
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

          await actualizarEvidencia(ApiDefinition.ipServer, fotoEvidencia,
              VariablesGlobales.usuario.idUsuario);
        });
      });
    }
  }

  _guardarEvidencia(int idRegistro) async {
    for (String evidencia in registroProvider.evidencia.keys) {
      if (registroProvider.comprobarFotos[evidencia]) {
        List<int> evidenciaInt = [];
        Uint8List byte = registroProvider.evidencia[evidencia];
        evidenciaInt = byte.cast<int>();

        Evidencia datosFirma = Evidencia(
          evidencia: evidenciaInt,
          idCampo: _obtenerIdCampo(evidencia),
          idInventario: idRegistro,
          nombreEvidencia: evidencia,
        );
        await actualizarEvidencia(
            ApiDefinition.ipServer, datosFirma, usuarioSeleccionado.idUsuario);
      }
    }
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
      for (Campos campo in agrupacion.campos) {
        if (campoARecuperar == campo.nombreCampo) {
          respuesta = campo.idCampo;
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
                    '${registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
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
                    '${registroProvider.listaAgrupaciones.elementAt(indAgrupacion).campos.elementAt(i).nombreCampo}'),
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
