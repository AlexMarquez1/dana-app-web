import 'package:app_isae_desarrollo/src/models/DatosAValidar.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DatosInventario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import '../models/Agrupaciones.dart';

class BalancePage extends StatelessWidget {
  BalancePage({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _opcionSeleccionada;
  String _totalDatosAValidar = '';
  List<String> _listaOpciones = [];
  List<DatosAValidar> _listaSinRegistrar = [];
  List<DatosAValidar> _listaRegistrada = [];

  ScrollController _scrollControllerSinRegistrar = ScrollController();
  ScrollController _scrollControllerRegistrada = ScrollController();
  ScrollController _scrollControllerPrincipal = ScrollController();
  ScrollController _scrollControllerContenido = ScrollController();

  @override
  Widget build(BuildContext context) {
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
      controller: _scrollControllerPrincipal,
      child: Center(
        child: Column(
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter actualizar) {
              return SizedBox(
                height: size.height * 0.93,
                child: Tarjetas.tarjeta(
                    size,
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SingleChildScrollView(
                        controller: _scrollControllerContenido,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    _texto(context, 'Tipo de dato:'),
                                    _listaOpciones.isEmpty
                                        ? FutureBuilder(
                                            future: obtenerTiposDeDatosAValidar(
                                                ApiDefinition.ipServer),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                _listaOpciones = snapshot.data;
                                                return _tiposDeDatos(
                                                    context, actualizar);
                                              } else {
                                                return LoadingBouncingGrid
                                                    .circle();
                                              }
                                            })
                                        : _tiposDeDatos(context, actualizar),
                                  ],
                                ),
                                _opcionSeleccionada == null
                                    ? Container()
                                    : _totalDatosAValidar.isEmpty
                                        ? FutureBuilder(
                                            future: obtenerTotalValoresAValidar(
                                                ApiDefinition.ipServer,
                                                _opcionSeleccionada == null
                                                    ? _listaOpciones.first
                                                    : _opcionSeleccionada!),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                _totalDatosAValidar =
                                                    snapshot.data;
                                                return _texto(context,
                                                    'Total de datos: ${snapshot.data}');
                                              } else {
                                                return LoadingDoubleFlipping
                                                    .circle();
                                              }
                                            })
                                        : _texto(context,
                                            'Total de datos: $_totalDatosAValidar'),
                              ],
                            ),
                            _opcionSeleccionada == null
                                ? Container()
                                : _datos(context)
                          ],
                        ),
                      ),
                    )),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tiposDeDatos(BuildContext context, StateSetter actualizar) {
    return Container(
      padding: EdgeInsets.only(left: 20.0),
      width: 300.0,
      child: DropdownButtonFormField(
          decoration: InputDecoration(
            hintText: 'Tipo de dato',
            border: OutlineInputBorder(),
          ),
          value: _opcionSeleccionada == null
              ? _listaOpciones.first
              : _opcionSeleccionada,
          onChanged: (String? value) {
            _opcionSeleccionada = value;
            _totalDatosAValidar = '';
            actualizar(() {});
          },
          items: _listaOpciones.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Container(
                alignment: Alignment.centerLeft,
                width: 200.0,
                height: 50.0,
                child: Text(
                  item,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList()),
    );
  }

  Widget _datos(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _listaSinRegistrar.isEmpty
              ? _obtenerDatos(obtenerDatosAValidarPendientes, 'Sin registrar',
                  _scrollControllerSinRegistrar)
              : _contenedor(context, _listaSinRegistrar,
                  _scrollControllerSinRegistrar, 'Sin registrar'),
          _listaRegistrada.isEmpty
              ? _obtenerDatos(obtenerDatosAValidarAsignados, 'Registrada',
                  _scrollControllerRegistrada)
              : _contenedor(context, _listaRegistrada,
                  _scrollControllerRegistrada, 'Registrada'),
        ],
      ),
    );
  }

  Widget _obtenerDatos(Future<List<DatosAValidar>> Function(String) future,
      String tipoLista, ScrollController scrollController) {
    return FutureBuilder(
        future: future(ApiDefinition.ipServer),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (tipoLista == 'Registrada') {
              _listaRegistrada = snapshot.data;
            } else {
              _listaSinRegistrar = snapshot.data;
            }

            return _contenedor(
                context, snapshot.data, scrollController, tipoLista);
          } else {
            return Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.7,
                child: LoadingFadingLine.circle(
                  size: 150,
                  backgroundColor: Color.fromRGBO(36, 90, 149, 1),
                ));
          }
        });
  }

  Widget _contenedor(BuildContext context, List<DatosAValidar> lista,
      ScrollController scrollController, String tipo) {
    Size size = MediaQuery.of(context).size;
    List<DatosAValidar> listaSinRepetidos = [];
    for (DatosAValidar item in lista) {
      if (listaSinRepetidos.contains(item.dato)) {
        print('DatoEncontrado: ${item.dato}');
      }
    }
    return Column(
      children: [
        _texto(context, '$tipo: ${lista.length}'),
        Container(
          width: size.width * 0.3,
          height: size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white,
              width: 5.0,
            ),
          ),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount: lista.length,
            padding: EdgeInsets.all(10.0),
            itemBuilder: (BuildContext context, int ind) {
              return Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(36, 90, 149, 1),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0)),
                height: 40.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      Text(
                        '${lista.elementAt(ind).tipodedato}: ',
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        '${lista.elementAt(ind).dato}',
                        style: TextStyle(
                            color: Color.fromRGBO(36, 90, 149, 1),
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Container()),
                      lista.elementAt(ind).inventario!.idinventario != null
                          ? IconButton(
                              onPressed: () async {
                                PantallaDeCarga.loadingI(context, true);
                                List<Agrupaciones> respuesta =
                                    await obtenerDatosCamposRegistro(
                                        ApiDefinition.ipServer,
                                        lista
                                                    .elementAt(ind)
                                                    .inventario!
                                                    .proyecto ==
                                                null
                                            ? 0
                                            : lista
                                                .elementAt(ind)
                                                .inventario!
                                                .proyecto!
                                                .idproyecto!,
                                        lista
                                            .elementAt(ind)
                                            .inventario!
                                            .idinventario!);
                                PantallaDeCarga.loadingI(context, false);
                                await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      Size size = MediaQuery.of(context).size;
                                      return SimpleDialog(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.white,
                                                  width: 3),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          title: Container(
                                            height: 50.0,
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
                                          children: [
                                            DatosInventario(
                                              agrupaciones: respuesta,
                                              indRegistro: -1,
                                            )
                                          ]);
                                    });
                              },
                              icon: Icon(Icons.open_in_new_outlined))
                          : Container()
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //5140 6500 6188 4310

  Widget _texto(BuildContext context, String texto) {
    return Text(
      texto.toUpperCase(),
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
    );
  }
}
