import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Campos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TipoCampo.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TarjetaNuevoCampo extends StatefulWidget {
  Campos campo;
  String agrupacion;
  Function eliminar;
  ScrollController scrollCampo;
  List<Agrupaciones> listaAgrupaciones;
  TarjetaNuevoCampo({
    Key key,
    @required this.campo,
    @required this.agrupacion,
    @required this.eliminar,
    @required this.scrollCampo,
    @required this.listaAgrupaciones,
  }) : super(key: key);

  @override
  State<TarjetaNuevoCampo> createState() => _TarjetaNuevoCampoState();
}

class _TarjetaNuevoCampoState extends State<TarjetaNuevoCampo> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20.0),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0, left: 10.0),
        child: _panel(),
      ),
    );
  }

  Widget _panel() {
    return Container(
      child: ExpansionPanelList(
        children: [
          ExpansionPanel(
            backgroundColor: Colors.grey[350],
            headerBuilder: (context, isExpanded) {
              return ListTile(
                leading: Container(
                  width: 100.0,
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      widget.campo.nombreCampo == 'FOLIO'
                          ? Container()
                          : IconButton(
                              icon: Icon(
                                Icons.delete_sharp,
                                color: Colors.red,
                              ),
                              tooltip: 'Eliminar',
                              hoverColor: Colors.white,
                              onPressed: widget.eliminar,
                            ),
                    ],
                  ),
                ),
                title: Text(
                  widget.campo.controladorNombreCampo.text,
                  style: TextStyle(color: Colors.black),
                ),
              );
            },
            body: Container(
              // color: Colors.blue.withOpacity(0.7),
              padding: EdgeInsets.only(bottom: 20.0),
              child: MediaQuery.of(context).size.width < 1450
                  ? _camposVertical(widget.campo)
                  : _camposHorizontal(widget.campo),
            ),
            isExpanded: _expanded,
            canTapOnHeader: true,
          ),
        ],
        dividerColor: Colors.grey,
        expansionCallback: (panelIndex, isExpanded) {
          _expanded = !_expanded;
          setState(() {});
        },
      ),
    );
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
                    _txtCampo(campo.controladorNombreCampo),
                  ],
                ),
                Column(
                  children: [
                    _etiquetaCampo('tipo campo:'),
                    _tipoCampo(campo),
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
                        _txtCampo(campo.controladorRestriccion),
                      ],
                    ),
                    Column(
                      children: [
                        _etiquetaCampo('tamaño:'),
                        _numCampo(campo.controladorLongitud),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _camposHorizontal(Campos campo) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.scrollCampo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _etiquetaCampo('tipo campo:'),
                _tipoCampo(campo),
                // SizedBox(
                //   width: 20.0,
                // ),
                _etiquetaCampo('CAMPO:'),
                _txtCampo(campo.controladorNombreCampo),
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
                    : _txtCampo(campo.controladorRestriccion),
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
                    : _numCampo(campo.controladorLongitud),
              ],
            ),
          ),
        ],
      ),
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
          setState(() {});
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

  //TODO: EN DADO CASO QUE NO SE ALMACENE EL TIPO DE CAMPO COMPROBAR ESTE METODO
  Widget _tipoCampo(Campos campo) {
    List<String> tipos = [
      'NUMERICO',
      'ALFANUMERICO',
      'CORREO',
      'ALFABETICO',
      'CATALOGO',
      'FIRMA',
      'FOTO',
      'CALENDARIO',
      'CHECKBOX',
    ];
    String seleccion = 'ALFANUMERICO';

    switch (campo.tipoCampo.toUpperCase()) {
      case 'NUMERICO':
        seleccion = tipos.elementAt(0);
        break;
      case 'ALFANUMERICO':
        seleccion = tipos.elementAt(1);
        break;
      case 'CORREO':
        seleccion = tipos.elementAt(2);
        break;
      case 'ALFABETICO':
        seleccion = tipos.elementAt(3);
        break;
      case 'CATALOGO':
        seleccion = tipos.elementAt(4);
        break;
      case 'FIRMA':
        seleccion = tipos.elementAt(5);
        break;
      case 'FOTO':
        seleccion = tipos.elementAt(6);
        break;
      case 'CALENDARIO':
        seleccion = tipos.elementAt(7);
        break;
      case 'CHECKBOX':
        seleccion = tipos.elementAt(8);
        break;
      default:
        seleccion = 'ALFANUMERICO';
        break;
    }
    return TipoCampo(
      tipoSeleccionado: seleccion,
      listaAgrupaciones: widget.listaAgrupaciones,
      nombreCampo: campo.nombreCampo,
      actualizar: () {
        setState(() {});
      },
    );
  }
}
