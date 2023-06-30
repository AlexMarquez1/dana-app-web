import 'package:app_isae_desarrollo/src/page/widgets/BotonInicio.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({Key key}) : super(key: key);

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      body: _contenido(context),
      endDrawer: DrawerPrincipal(),
    );
  }

  Widget _contenido(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          left: 30.0,
          right: 30.0,
        ),
        child: Table(
          //border: TableBorder.all(),
          //columnWidths: {1: FractionColumnWidth(.2)},
          children: _ordenarInicio(VariablesGlobales.usuario.perfil.perfil),
        ),
      ),
    );
  }

  List<TableRow> _ordenarInicio(String perfil) {
    final List<TableRow> componentes = [];
    switch (perfil) {
      case 'Super Admin':
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.person_add, etiqueta: 'usuarios'),
          BotonInicio(icono: Icons.assignment, etiqueta: 'catalogo'),
        ]));
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        ]));
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.extension_off_sharp, etiqueta: 'dashborad'),
          BotonInicio(icono: Icons.data_usage_rounded, etiqueta: 'balance'),
          // BotonInicio(
          //     icono: Icons.notification_add_rounded,
          //     etiqueta: 'notificaciones'),
          BotonInicio(icono: Icons.rule, etiqueta: 'duplicados'),
        ]));
        break;
      case 'Administrador':
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.person_add, etiqueta: 'usuarios'),
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
        ]));
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
          BotonInicio(icono: Icons.data_usage_rounded, etiqueta: 'balance'),
          // BotonInicio(
          //     icono: Icons.notification_add_rounded,
          //     etiqueta: 'notificaciones'),
        ]));
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.rule, etiqueta: 'duplicados'),
          Container(),
          Container(),
        ]));
        break;
      case 'Coordinador':
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
        ]));
        componentes.add(TableRow(children: [
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
          BotonInicio(icono: Icons.data_usage_rounded, etiqueta: 'balance'),
          // BotonInicio(
          //     icono: Icons.notification_add_rounded,
          //     etiqueta: 'notificaciones'),
          BotonInicio(icono: Icons.rule, etiqueta: 'duplicados'),
        ]));
        break;
      case 'Usuario':
        componentes.add(TableRow(children: [
          // BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          Container(),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          // BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          Container(),
        ]));
        // componentes.add(TableRow(children: [
        //   BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        //   BotonInicio(
        //       icono: Icons.notification_add_rounded,
        //       etiqueta: 'notificaciones'),
        //   Container(),
        // ]));
        break;
      case 'Documentador':
        componentes.add(TableRow(children: [
          // BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          Container(),
        ]));
        // componentes.add(TableRow(children: [
        //   BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        //   BotonInicio(
        //       icono: Icons.notification_add_rounded,
        //       etiqueta: 'notificaciones'),
        //   Container(),
        // ]));
        break;
      case 'Cliente':
        break;
      case 'Tecnico':
        break;
    }

    return componentes;
  }
}
