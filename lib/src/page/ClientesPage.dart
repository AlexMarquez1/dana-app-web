import 'dart:ui';

import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TarjetaInformacion.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/utils/UpperCaseTextFormatterCustom.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/APIWebService/Consultas.dart';
import 'widgets/DrawerWidget.dart';

class ClientesPage extends StatelessWidget {
  ClientesPage({key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollNuevoCliente = ScrollController();
  RegistroProvider _registroProvider;
  TextEditingController _nombreCliente = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _direccion = TextEditingController();

  Uint8List _nuevoLogo = Uint8List(0);

  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      body: _contenedor(context),
      endDrawer: DrawerPrincipal(),
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
                'Clientes'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _registroProvider.listaClientes != null
              ? _tarjeta(sizePantalla, _listaClientes(context))
              : Container(),
        ],
      ),
    );
  }

  Widget _listaClientes(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Wrap(
      children: [
        TarjetaInformacion(
          click: () async {
            _nuevoLogo = Uint8List(0);
            _nombreCliente.text = '';
            _telefono.text = '';
            _direccion.text = '';
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: AlertDialog(
                      title: Row(
                        children: [
                          Expanded(child: Container()),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                      content: StatefulBuilder(builder:
                          (BuildContext context, StateSetter actualizar) {
                        return _nuevoCliente(size, actualizar, null);
                      }),
                      actions: [
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: EdgeInsets.only(
                            right: 100.0,
                          ),
                          margin: EdgeInsets.only(
                            bottom: 30.0,
                          ),
                          width: size.width,
                          child: ElevatedButton(
                            onPressed: () async {
                              Cliente cliente = Cliente(
                                idcliente: 0,
                                cliente: _nombreCliente.text,
                                telefono: _telefono.text,
                                direccion: _direccion.text,
                                estatus: 'Activo',
                                urllogo: '',
                                clienteAplicacion:
                                    VariablesGlobales.usuario.clienteAplicacion,
                              );
                              await nuevoCliente(
                                  ApiDefinition.ipServer, cliente);
                            },
                            child: Text(
                              'Guardar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
          width: 200.0,
          titulo: 'Nuevo Cliente',
          contenido: Container(
            width: 100.0,
            height: 100.0,
            child: Icon(
              Icons.add,
              size: 50.0,
            ),
          ),
        ),
        for (Cliente cliente in _registroProvider.listaClientes)
          TarjetaInformacion(
            click: () async {
              _nuevoLogo = Uint8List(0);
              _nombreCliente.text = cliente.cliente;
              _telefono.text = cliente.telefono;
              _direccion.text = cliente.direccion;
              if (cliente.urllogo.isNotEmpty) {
                http.Response response =
                    await http.get(Uri.parse(cliente.urllogo));
                _nuevoLogo = response.bodyBytes;
              }
              await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: AlertDialog(
                        title: Row(
                          children: [
                            Expanded(child: Container()),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close),
                            ),
                          ],
                        ),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter actualizar) {
                          return _nuevoCliente(size, actualizar, cliente);
                        }),
                        actions: [
                          Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(
                              right: 100.0,
                            ),
                            margin: EdgeInsets.only(
                              bottom: 30.0,
                            ),
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                cliente.cliente = _nombreCliente.text;
                                cliente.telefono = _telefono.text;
                                cliente.direccion = _direccion.text;

                                await nuevoCliente(
                                    ApiDefinition.ipServer, cliente);
                              },
                              child: Text(
                                'Actualizar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            },
            width: 200.0,
            titulo: cliente.cliente,
            contenido: Container(
              width: 100.0,
              height: 100.0,
              child: cliente.urllogo.isNotEmpty
                  ? Image.network(
                      cliente.urllogo,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Sin logo',
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
            ),
          )
      ],
    );
  }

  Widget _nuevoCliente(Size size, StateSetter actualizar, Cliente cliente) {
    return Container(
      width: size.width * 0.7,
      height: size.height * 0.6,
      color: Colors.grey[350],
      child: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            controller: _scrollNuevoCliente,
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre del cliente',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: size.width / 3,
                        child: TextFormField(
                          controller: _nombreCliente,
                          inputFormatters: <TextInputFormatter>[
                            UpperCaseTextFormatter(),
                          ],
                          onChanged: (value) {
                            actualizar(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa el nombre';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Nombre del cliente'),
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
                          controller: _telefono,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa el telefono';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Telefono de contacto'),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        'Dirección',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: size.width / 3,
                        child: TextFormField(
                          controller: _direccion,
                          inputFormatters: <TextInputFormatter>[
                            UpperCaseTextFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa la direccion';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Dirección'),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _nombreCliente.text.isEmpty
                            ? 'Nombre del cliente'
                            : _nombreCliente.text,
                        style: TextStyle(fontSize: 25),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: size.width * 0.3,
                        height: 400.0,
                        decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: _nuevoLogo.isEmpty
                            ? Text(
                                'Logo del cliente',
                                style: TextStyle(fontSize: 20.0),
                              )
                            : Image.memory(_nuevoLogo),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        width: size.width * 0.2,
                        child: ElevatedButton(
                          onPressed: () async {
                            FilePickerResult result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['jpg', 'png'],
                                    allowMultiple: false);
                            if (result != null) {
                              _nuevoLogo = result.files.first.bytes;
                            }
                            actualizar(() {});
                          },
                          child: Text('Cargar logo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

// class ClientesPage extends StatelessWidget {
//   List<Cliente> _clientes;
//   ClientesPage({key});
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     _clientes =
//         ModalRoute.of(context).settings.arguments as List<Cliente> ?? [];
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: appBarPrincipal(context, _scaffoldKey),
//       body: _contenido(context),
//       endDrawer: DrawerPrincipal(),
//     );
//   }

//   Widget _contenido(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       margin: EdgeInsets.all(20.0),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20.0),
//               child: Text(
//                 'Clientes'.toUpperCase(),
//                 style: TextStyle(fontSize: 40.0),
//               ),
//             ),
//             Wrap(
//               crossAxisAlignment: WrapCrossAlignment.center,
//               runAlignment: WrapAlignment.start,
//               runSpacing: 50.0,
//               spacing: 50.0,
//               children: [
//                 for (Cliente cliente in _clientes)
//                   _tarjetaCliente(context, cliente),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _tarjetaCliente(BuildContext context, Cliente cliente) {
//     Size size = MediaQuery.of(context).size;
//     return InkWell(
//       onTap: () async {
//         PantallaDeCarga.loadingI(context, true);
//         List<Proyecto> listaProyectosPorCliente =
//             await obtenerProyecrtosPorCliente(ApiDefinition.ipServer, cliente);
//         print('Cantidad de proyectos: ${listaProyectosPorCliente.length}');
//         PantallaDeCarga.loadingI(context, false);
//         Navigator.pushNamed(context, '/registros',
//             arguments: listaProyectosPorCliente);
//       },
//       child: Ink(
//         width: size.width * 0.25,
//         height: 250.0,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20.0),
//           border: Border.all(
//             color: Color.fromRGBO(36, 90, 149, 1),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, offset: Offset(0, 5), blurRadius: 2.0)
//           ],
//           color: Colors.grey[350],
//         ),
//         child: Center(
//           child: _tipoContenido(context, size, cliente),
//         ),
//       ),
//     );
//   }

//   Widget _tipoContenido(BuildContext context, Size size, Cliente cliente) {
//     if (cliente.urllogo.contains('https:')) {
//       print('Con foto');
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
//             decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 5,
//                   color: Color.fromRGBO(36, 90, 149, 1),
//                 ),
//                 borderRadius: BorderRadius.circular(100),
//                 color: Colors.white),
//             width: size.width * 0.2,
//             height: 200,
//             child: Image.network(
//               cliente.urllogo,
//               fit: BoxFit.contain,
//             ),
//           ),
//           Text(
//             cliente.cliente.toUpperCase(),
//             style: TextStyle(fontSize: 40.0, color: Colors.black),
//           )
//         ],
//       );
//     } else {
//       print('Sin foto');
//       return Text(
//         cliente.cliente.toUpperCase(),
//         style: TextStyle(fontSize: 40.0, color: Colors.black),
//       );
//     }
//   }
// }
