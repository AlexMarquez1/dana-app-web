import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalidadesPage extends StatelessWidget {
  LocalidadesPage({key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _nombreLocalidad = TextEditingController();
  TextEditingController _ubicacion = TextEditingController();
  TextEditingController _nombreEncargado = TextEditingController();
  TextEditingController _telefonoContacto = TextEditingController();

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
                'Localidades'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Row(
            children: [
              _tarjeta(sizePantalla, _nuevaLocalidad(sizePantalla)),
              _tarjeta(sizePantalla, _listaLocalidades()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nuevaLocalidad(
    Size size,
  ) {
    return Container(
      width: size.width * 0.7,
      height: size.height * 0.6,
      color: Colors.grey[350],
      child: Form(
        // key: _formKey,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Text(
                  'Nueva localidad',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Wrap(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre de la localidad',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          width: size.width / 3,
                          child: TextFormField(
                            controller: _nombreLocalidad,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (value) {},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el nombre';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Nombre de la localidad'),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Ubicación',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          width: size.width / 3,
                          child: TextFormField(
                            controller: _ubicacion,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9]')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa la ubicación';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Ubicación'),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Nombre del encargado',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          width: size.width / 3,
                          child: TextFormField(
                            controller: _nombreEncargado,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el nombre del encargado';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Nombre del encargado'),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Telefono de contacto',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          width: size.width / 3,
                          child: TextFormField(
                            controller: _telefonoContacto,
                            inputFormatters: <TextInputFormatter>[
                              UpperCaseTextFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el teledono de contacto';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Telefono de contacto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaLocalidades() {
    return Container();
  }

  Widget _tarjeta(Size sizePantalla, Widget contenido) {
    return Container(
      width: sizePantalla.width * 0.4,
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
