import 'dart:ui';

import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

RegistroProvider _registroProvider;

PreferredSizeWidget appBarPrincipal(
    BuildContext context, GlobalKey<ScaffoldState> scaffold,
    {RegistroProvider registroProvider}) {
  _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
  return PreferredSize(
    preferredSize: Size.fromHeight(100.0),
    child: AppBar(
      elevation: 50,
      toolbarHeight: 100,
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromRGBO(36, 90, 149, 1),
      title: InkWell(
        onTap: () {
          if (registroProvider != null) {
            registroProvider.mostrarMasOpciones = false;
          }
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false);
        },
        onLongPress: () async {
          // await _cambiarCliente(context);
        },
        child: Container(
          width: 200.0,
          height: 100.0,
          child: VariablesGlobales.usuario.clienteAplicacion.urllogo == null
              ? Image(
                  image: AssetImage('assets/img/AppIcon.png'),
                  fit: BoxFit.contain,
                )
              : Image.network(
                  VariablesGlobales.usuario.clienteAplicacion.urllogo,
                  // width: 200.0,
                  fit: BoxFit.contain,
                ),
        ),
      ),
      centerTitle: false,
      // title: Container(
      //   width: double.infinity,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text(
      //         VariablesGlobales.usuario.perfil.perfil ?? '',
      //         style: TextStyle(color: Colors.white),
      //       ),
      //       VariablesGlobales.usuario.clienteAplicacion == null
      //           ? Image(
      //               image: AssetImage('assets/img/AppIcon.png'),
      //               width: 50.0,
      //             )
      //           : Image.network(
      //             VariablesGlobales.usuario.clienteAplicacion.urllogo,
      //             width: 100.0,
      //             fit: BoxFit.fitHeight,
      //           ),
      //       Container(),
      //     ],
      //   ),
      // ),
      actions: [
        _registroProvider.listaClientes != null
            ? _clientes(context)
            : Container(),
        SizedBox(
          width: 20.0,
        ),
        Container(
          padding: EdgeInsets.only(right: 20.0),
          child: IconButton(
              onPressed: () {
                scaffold.currentState.openEndDrawer();
              },
              icon: Icon(Icons.menu)),
        ),
      ],
    ),
  );
}

Widget _clientes(BuildContext context) {
  return PopupMenuButton<Cliente>(
    color: Colors.white,
    offset: Offset(0, 100),
    tooltip:
        '${_registroProvider.usuario.vistacliente == null ? _registroProvider.listaClientes.elementAt(0).cliente : _registroProvider.usuario.vistacliente.cliente}',
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
      Radius.circular(20.0),
    )),
    initialValue: _registroProvider.usuario.vistacliente == null
        ? _registroProvider.listaClientes.elementAt(0)
        : _registroProvider.usuario.vistacliente,
    itemBuilder: (context) => <PopupMenuItem<Cliente>>[
      for (Cliente cliente in _registroProvider.listaClientes)
        PopupMenuItem<Cliente>(
          value: cliente,
          child: _designCliente(cliente),
        ),
    ],
    child: _designCliente(_registroProvider.usuario.vistacliente == null
        ? _registroProvider.listaClientes.elementAt(0)
        : _registroProvider.usuario.vistacliente),
    onSelected: (Cliente value) {
      Usuario usuario = _registroProvider.usuario;
      usuario.vistacliente = value;

      _registroProvider.usuario = usuario;
      Navigator.pushNamed(context, '/inicio');
    },
  );
}

Widget _designCliente(Cliente cliente) {
  return Center(
    child: Container(
      width: 90.0,
      height: 60.0,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: cliente.urllogo.isNotEmpty
          ? Image.network(
              cliente.urllogo,
              fit: BoxFit.contain,
            )
          : Text(
              cliente.cliente,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ),
    ),
  );
}

_cambiarCliente(BuildContext context) async {
  TextEditingController pass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: SimpleDialog(
            insetPadding: EdgeInsets.all(20.0),
            contentPadding: EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(
                color: Color.fromARGB(255, 255, 255, 255),
                width: 5.0,
              ),
            ),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Clientes aplicación'),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            children: [
              Container(
                height: 35.0,
                child: Text('Cambiar cliente'),
              ),
            ],
          ),
        );
      });
}

// PreferredSizeWidget appBarPrincipal(
//     BuildContext context, GlobalKey<ScaffoldState> scaffold,
//     {RegistroProvider registroProvider}) {
//   return AppBar(
//     elevation: 50,
//     backgroundColor: Color.fromRGBO(36, 90, 149, 1),
//     leading: Row(
//       children: [
//         IconButton(
//             onPressed: () {
//               if (registroProvider != null) {
//                 registroProvider.mostrarMasOpciones = false;
//               }
//               Navigator.of(context).pushNamedAndRemoveUntil(
//                   '/inicio', (Route<dynamic> route) => false);
//             },
//             icon: Icon(Icons.home)),
//       ],
//     ),
//     title: Container(
//       width: double.infinity,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             VariablesGlobales.usuario.perfil.perfil ?? '',
//             style: TextStyle(color: Colors.white),
//           ),
//           VariablesGlobales.usuario.clienteAplicacion == null
//               ? Image(
//                   image: AssetImage('assets/img/AppIcon.png'),
//                   width: 50.0,
//                 )
//               : Image.network(
//                 VariablesGlobales.usuario.clienteAplicacion.urllogo,
//                 width: 100.0,
//                 fit: BoxFit.fitHeight,
//               ),
//           Container(),
//         ],
//       ),
//     ),
//     actions: [
//       Container(
//         padding: EdgeInsets.only(right: 20.0),
//         child: IconButton(
//             onPressed: () {
//               scaffold.currentState.openEndDrawer();
//             },
//             icon: Icon(Icons.menu)),
//       ),
//     ],
//   );
// }

PreferredSizeWidget appBarRegistro(
    BuildContext context, GlobalKey<ScaffoldState> scaffold, TabBar tabBar) {
  return AppBar(
    elevation: 50,
    backgroundColor: Color.fromRGBO(36, 90, 149, 1),
    leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false);
        },
        icon: Icon(Icons.home)),
    title: Center(
      child: Image(
        image: AssetImage('assets/img/AppIcon.png'),
        width: 50.0,
      ),
    ),
    actions: [
      Container(
        padding: EdgeInsets.only(right: 20.0),
        child: IconButton(
            onPressed: () {
              scaffold.currentState.openEndDrawer();
            },
            icon: Icon(Icons.menu)),
      ),
    ],
    bottom: tabBar,
  );
}
