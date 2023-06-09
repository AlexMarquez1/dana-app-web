import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget appBarPrincipal(
    BuildContext context, GlobalKey<ScaffoldState> scaffold,
    {RegistroProvider registroProvider}) {
  return AppBar(
    elevation: 50,
    backgroundColor: Color.fromRGBO(36, 90, 149, 1),
    leading: IconButton(
        onPressed: () {
          if (registroProvider != null) {
            registroProvider.mostrarMasOpciones = false;
          }
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
  );
}

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
