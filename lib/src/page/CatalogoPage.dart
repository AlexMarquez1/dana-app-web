import 'package:app_isae_desarrollo/src/models/Catalogo.dart';
import 'package:app_isae_desarrollo/src/models/CatalogoRelacionado.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CatalogoPage extends StatefulWidget {
  @override
  _CatalogoPageState createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKeyFila = GlobalKey<FormState>();
  final _formKeyColumna = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  FocusNode focus = FocusNode();

  List<Proyecto> _listaProyectos = [];
  List<String> _listaCatalogosProyecto = [];
  List<String> _listaCatalogoPadre = [];
  List<String> _listaCatalogoHijo = [];
  List<String> _listaContenido = [];
  List<String> _listaContenidoCatalogoPadre = [];
  List<String> _listaContenidoCatalogoHijo = [];

  Map<String, bool> _contenidoSeleccionadoPadre = new Map<String, bool>();
  Map<String, bool> _contenidoSeleccionadoHijo = new Map<String, bool>();

  TextEditingController _contenidoController = new TextEditingController();
  ScrollController _scrollCatalogo1 = ScrollController();
  ScrollController _scrollCatalogo2 = ScrollController();

  String? _catalogoProyectoSeleccionado;
  String? _catalogoPadreSeleccionado;
  String? _catalogoHijoSeleccionado;
  Proyecto _proyectoSeleccionado = Proyecto();

  bool _bloquearCheckBox = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: appBarPrincipal(context, _scaffoldKey),
        endDrawer: DrawerPrincipal(),
        body: _contenedor(context));
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
                'Catalogo'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _tarjeta(sizePantalla, _seleccionarProyecto()),
          sizePantalla.width > 800
              ? _tarjeta(sizePantalla, _registrarCatalogoFila())
              : _tarjeta(sizePantalla, _registrarCatalogoColumna()),
          _tarjeta(sizePantalla, _registrarCatalogoRelacionado())
        ],
      ),
    );
  }

  Widget _registrarCatalogoRelacionado() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                child: Text(
                  'Catalogo relacionado del proyecto ${_proyectoSeleccionado.proyecto}',
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Catalogo 1'),
                    SizedBox(
                      width: 20.0,
                    ),
                    _seleccionCatalogo(constraints.maxWidth * 0.2, 'padre'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('Catalogo 2'),
                    SizedBox(
                      width: 20.0,
                    ),
                    _seleccionCatalogo(constraints.maxWidth * 0.2, 'hijo'),
                  ],
                ),
              ),
              Container(
                width: constraints.maxWidth * 0.5,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SingleChildScrollView(
                        controller: _scrollCatalogo1,
                        child: Column(
                          children: [
                            for (String item in _listaContenidoCatalogoPadre)
                              _datosCheck(item, 'padre'),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        controller: _scrollCatalogo2,
                        child: Column(
                          children: [
                            for (String item in _listaContenidoCatalogoHijo)
                              _datosCheck(item, 'hijo'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_contenidoSeleccionadoPadre.containsValue(true)) {
                      if (_contenidoSeleccionadoHijo.containsValue(true)) {
                        String? catalogoPadre;
                        List<String> catalogoHijo = [];
                        for (String item in _listaContenidoCatalogoPadre) {
                          if (_contenidoSeleccionadoPadre[item]!) {
                            catalogoPadre = item;
                          }
                        }
                        for (String item in _listaContenidoCatalogoHijo) {
                          if (_contenidoSeleccionadoHijo[item]!) {
                            catalogoHijo.add(item);
                          }
                        }

                        Dialogos.advertencia(
                            context, 'Estas seguro de guardar los cambios',
                            () async {
                          PantallaDeCarga.loadingI(context, true);
                          CatalogoRelacionado catalogoRelacionado =
                              CatalogoRelacionado(
                                  tipoCatalogoPadre: _catalogoPadreSeleccionado,
                                  catalogoPadre: catalogoPadre,
                                  catalogoHijo: catalogoHijo,
                                  tipoCatalogoHijo: _catalogoHijoSeleccionado);
                          await crearCatalogoRelacionado(
                              ApiDefinition.ipServer,
                              catalogoRelacionado,
                              _proyectoSeleccionado.idproyecto!);
                          PantallaDeCarga.loadingI(context, false);
                          Navigator.pop(context);
                        });
                      } else {
                        print(
                            'No se a seleccionado ningun campo del catalogo hijo');
                      }
                    } else {
                      print(
                          'No se a seleccionada ningun campo dentro del catalogo Padre');
                    }
                  },
                  child: Text('Guardar')),
            ],
          ),
        );
      },
    );
  }

  Widget _datosCheck(String etiqueta, String tipo) {
    return Container(
      width: 200.0,
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('$etiqueta'),
        value: tipo == 'padre'
            ? _contenidoSeleccionadoPadre[etiqueta]
            : _contenidoSeleccionadoHijo[etiqueta],
        onChanged: _bloquearCheckBox
            ? null
            : (value) async {
                switch (tipo) {
                  case 'padre':
                    PantallaDeCarga.loadingI(context, true);
                    CatalogoRelacionado? catalogo;
                    for (String item in _listaContenidoCatalogoPadre) {
                      if (item == etiqueta) {
                        _contenidoSeleccionadoPadre[item] = value!;
                        catalogo = await obtenerCatalogoRelacionado(
                            ApiDefinition.ipServer,
                            CatalogoRelacionado(
                                tipoCatalogoPadre: _catalogoPadreSeleccionado,
                                catalogoPadre: item,
                                catalogoHijo: []),
                            _proyectoSeleccionado.idproyecto!);
                      } else {
                        _contenidoSeleccionadoPadre[item] = false;
                      }
                    }
                    for (String item in _listaContenidoCatalogoHijo) {
                      _contenidoSeleccionadoHijo[item] = false;
                    }

                    for (String item in catalogo!.catalogoHijo!) {
                      _contenidoSeleccionadoHijo[item] = true;
                    }
                    PantallaDeCarga.loadingI(context, false);
                    break;
                  case 'hijo':
                    _contenidoSeleccionadoHijo[etiqueta] = value!;
                    break;
                }
                setState(() {});
              },
      ),
    );
  }

  Widget _registrarCatalogoFila() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Form(
          key: _formKeyFila,
          child: Center(
            child: Container(
              margin: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
                    child: Text(
                      'Catalogo individual del proyecto ${_proyectoSeleccionado.proyecto}',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  Row(
                    children: [
                      Text('Catalogo'),
                      SizedBox(
                        width: 20.0,
                      ),
                      _seleccionCampoProyecto(constraints.maxWidth * 0.2),
                      SizedBox(
                        width: 20.0,
                      ),
                      Text('Contenido'),
                      SizedBox(
                        width: 20.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: constraints.maxWidth / 5,
                        child: TextFormField(
                          autofocus: true,
                          focusNode: focus,
                          onFieldSubmitted: (value) {
                            _accionAgregar(_formKeyFila);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa el contenido del catalogo';
                            }
                            return null;
                          },
                          controller: _contenidoController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Contenido del catalogo'),
                          inputFormatters: <TextInputFormatter>[
                            UpperCaseTextFormatter(),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Container(
                          child: ElevatedButton(
                              onPressed: () {
                                _accionAgregar(_formKeyFila);
                              },
                              child: Text('Agregar'))),
                      SizedBox(
                        width: 20.0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                        ),
                        width: 300.0,
                        height: 200.0,
                        child: _contenido(),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      _btnGuardar(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _accionAgregar(GlobalKey<FormState> form) {
    if (form.currentState!.validate()) {
      bool coincidencia = false;
      if (_listaContenido == null) {
        _listaContenido = [];
      }
      for (String item in _listaContenido) {
        if (item == _contenidoController.text) {
          coincidencia = true;
          Dialogos.error(context, 'Este elemento ya se encuentra agregado');
          break;
        }
      }
      if (!coincidencia) {
        _listaContenido.add(_contenidoController.text);
        _contenidoController.text = '';
      }
      focus.requestFocus();
      setState(() {});
    }
  }

  Widget _registrarCatalogoColumna() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Form(
          key: _formKeyColumna,
          child: Container(
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Catalogo'),
                    SizedBox(
                      width: 20.0,
                    ),
                    _seleccionCampoProyecto(constraints.maxWidth * 0.2),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('Contenido'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: constraints.maxWidth / 5,
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          _accionAgregar(_formKeyColumna);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el contenido del catalogo';
                          }
                          return null;
                        },
                        controller: _contenidoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Contenido del catalogo'),
                        inputFormatters: <TextInputFormatter>[
                          UpperCaseTextFormatter(),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Container(
                        child: ElevatedButton(
                            onPressed: () {
                              _accionAgregar(_formKeyColumna);
                            },
                            child: Text('Agregar'))),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(),
                  ),
                  width: 200.0,
                  height: 200.0,
                  child: _contenido(),
                ),
                SizedBox(
                  height: 20.0,
                ),
                _btnGuardar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btnGuardar() {
    return ElevatedButton(
      onPressed: () async {
        print('Catalogo a ingresar: $_listaContenido');
        PantallaDeCarga.loadingI(context, true);
        await eliminarCatalogos(ApiDefinition.ipServer, _proyectoSeleccionado,
            _catalogoProyectoSeleccionado!);
        if (_listaContenido.isNotEmpty) {
          await crearCatalogo(ApiDefinition.ipServer, _proyectoSeleccionado,
              _listaContenido, _catalogoProyectoSeleccionado!);
        }
        PantallaDeCarga.loadingI(context, false);
        _listaContenido = [];
        _catalogoProyectoSeleccionado = null;
        _contenidoController.text;
        setState(() {});
      },
      child: Text('Guardar'),
    );
  }

  Widget _contenido() {
    return Scrollbar(
      //controller: _scrollController,
      //isAlwaysShown: true,
      child: ListView.separated(
        //padding: EdgeInsets.all(8),
        itemCount: _listaContenido == null ? 0 : _listaContenido.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              children: [
                Container(
                  height: 50.0,
                  width: 200.0,
                  child: Text(
                    _listaContenido.elementAt(index),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                  ),
                  alignment: Alignment.center,
                ),
                Expanded(
                  child: Container(),
                ),
                IconButton(
                  onPressed: () {
                    _listaContenido.removeAt(index);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.highlight_remove_sharp,
                    color: Colors.red[100],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
      ),
    );
  }

  Widget _seleccionarProyecto() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          margin: EdgeInsets.all(20.0),
          child: Row(
            children: [
              Text('Proyecto'),
              SizedBox(
                width: 20.0,
              ),
              _listaProyectos.isEmpty
                  ? _listarProyectos(constraints.maxWidth * 0.2)
                  : _seleccionProyecto(constraints.maxWidth * 0.2),
            ],
          ),
        );
      },
    );
  }

  Future<List<Proyecto>> _obtenerProyectos() {
    return obtenerProyectos(ApiDefinition.ipServer);
  }

  Widget _listarProyectos(double ancho) {
    return FutureBuilder(
      future: _obtenerProyectos(),
      builder: (BuildContext context, AsyncSnapshot<List<Proyecto>> snapshot) {
        if (snapshot.hasData) {
          _listaProyectos = snapshot.data!;
          return _seleccionProyecto(ancho);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _seleccionProyecto(double ancho) {
    return Container(
      width: ancho,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Proyectos',
        ),
        value: _proyectoSeleccionado.proyecto,
        onChanged: (valor) async {
          for (int i = 0; i < _listaProyectos.length; i++) {
            if (_listaProyectos.elementAt(i).proyecto == valor) {
              _proyectoSeleccionado = _listaProyectos.elementAt(i);
              _listaCatalogosProyecto = await obtenerCatalogoCamposProyecto(
                  ApiDefinition.ipServer, _proyectoSeleccionado);
              _listaCatalogoPadre = _listaCatalogosProyecto;
              if (_listaCatalogosProyecto.isEmpty) {
                Dialogos.error(context,
                    'Este proyecto no cuenta con ningun campo configurado como catalogo');
              } else {
                // _catalogoProyectoSeleccionado =
                //     _listaCatalogosProyecto.elementAt(0);
              }
              setState(() {});
            }
          }
          _catalogoProyectoSeleccionado = null;
          _catalogoHijoSeleccionado = null;
          _catalogoPadreSeleccionado = null;
          _listaContenido = [];
          _listaContenidoCatalogoPadre = [];
          _listaContenidoCatalogoHijo = [];
        },
        items: _listaProyectos.map((item) {
          return DropdownMenuItem(
            value: item.proyecto,
            child: Text(item.proyecto!),
          );
        }).toList(),
      ),
    );
  }

  Widget _seleccionCampoProyecto(double ancho) {
    return Container(
      width: ancho,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Catalogos',
        ),
        value: _catalogoProyectoSeleccionado,
        onChanged: (String? valor) async {
          _catalogoProyectoSeleccionado = valor;
          PantallaDeCarga.loadingI(context, true);
          Catalogo catalogo = await obtenerDatosCatalogoCamposProyecto(
              ApiDefinition.ipServer, _proyectoSeleccionado, valor!);
          _listaContenido = catalogo.catalogo!;
          PantallaDeCarga.loadingI(context, false);
          setState(() {});
        },
        items: _listaCatalogosProyecto.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (String? validar) {
          if (_catalogoProyectoSeleccionado != null) {
            if (validar!.isEmpty) {
              return 'Seleccione un catalogo';
            } else {
              return null;
            }
          } else {
            return 'Selecceione un catalogo';
          }
        },
      ),
    );
  }

  Widget _seleccionCatalogo(double ancho, String catalogo) {
    return Container(
      width: ancho,
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: catalogo == 'padre' ? 'Catalogo1' : 'Catalogo 2',
        ),
        value: catalogo == 'padre'
            ? _catalogoPadreSeleccionado
            : _catalogoHijoSeleccionado,
        onChanged: (String? valor) async {
          switch (catalogo) {
            case 'padre':
              _catalogoPadreSeleccionado = valor;
              _listaCatalogoHijo = [];
              for (String item in _listaCatalogoPadre) {
                if (item != valor) {
                  _listaCatalogoHijo.add(item);
                }
              }
              Catalogo catalogo = await obtenerDatosCatalogoCamposProyecto(
                  ApiDefinition.ipServer, _proyectoSeleccionado, valor!);
              _listaContenidoCatalogoPadre = catalogo.catalogo!;
              _listaContenidoCatalogoHijo = [];
              _catalogoHijoSeleccionado = null;
              for (String item in _listaContenidoCatalogoPadre) {
                _contenidoSeleccionadoPadre[item] = false;
              }
              _bloquearCheckBox = true;
              break;
            case 'hijo':
              _catalogoHijoSeleccionado = valor;
              Catalogo catalogo = await obtenerDatosCatalogoCamposProyecto(
                  ApiDefinition.ipServer, _proyectoSeleccionado, valor!);
              _listaContenidoCatalogoHijo = catalogo.catalogo!;
              for (String item in _listaContenidoCatalogoHijo) {
                _contenidoSeleccionadoHijo[item] = false;
              }
              _bloquearCheckBox = false;
              break;
          }
          setState(() {});
        },
        items: (catalogo == 'padre' ? _listaCatalogoPadre : _listaCatalogoHijo)
            .map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (String? validar) {
          if (validar!.isEmpty) {
            return 'Seleccione un catalogo';
          } else {
            return null;
          }
        },
      ),
    );
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
}
