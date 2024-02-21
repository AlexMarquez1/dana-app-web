import 'package:app_isae_desarrollo/src/page/widgets/BotonInicio.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TarjetaInformacion.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({Key? key}) : super(key: key);

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
      child: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: 30.0,
                right: 30.0,
              ),
              child: Wrap(
                runSpacing: 150.0,
                spacing: 200.0,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children:
                    _ordenarInicio(VariablesGlobales.usuario.perfil!.perfil!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _ordenarInicio(String perfil) {
    final List<Widget> componentes = [];
    switch (perfil) {
      case 'Super Admin':
        componentes.addAll([
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.business_sharp, etiqueta: 'clientes'),
          BotonInicio(
              icono: Icons.add_business_rounded, etiqueta: 'localidades'),
          BotonInicio(icono: Icons.person_add, etiqueta: 'usuarios'),
          BotonInicio(icono: Icons.assignment, etiqueta: 'catalogo'),
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
          BotonInicio(icono: Icons.extension_off_sharp, etiqueta: 'dashborad'),
          BotonInicio(icono: Icons.data_usage_rounded, etiqueta: 'balance'),
          // BotonInicio(
          //     icono: Icons.notification_add_rounded,
          //     etiqueta: 'notificaciones'),
          BotonInicio(icono: Icons.rule, etiqueta: 'duplicados'),
        ]);
        break;
      case 'Administrador':
        componentes.addAll([
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.business_sharp, etiqueta: 'clientes'),
          BotonInicio(
              icono: Icons.add_business_rounded, etiqueta: 'localidades'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          BotonInicio(icono: Icons.person_add, etiqueta: 'usuarios'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
          BotonInicio(icono: Icons.assignment, etiqueta: 'catalogo'),
        ]);
        break;
      case 'Coordinador':
        componentes.addAll([
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
          BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        ]);
        // componentes.add(TableRow(children: [
        //   BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        //   BotonInicio(icono: Icons.data_usage_rounded, etiqueta: 'balance'),
        //   // BotonInicio(
        //   //     icono: Icons.notification_add_rounded,
        //   //     etiqueta: 'notificaciones'),
        //   BotonInicio(icono: Icons.rule, etiqueta: 'duplicados'),
        // ]));
        break;
      case 'Documentador':
        componentes.addAll([
          // BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
          BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
        ]);
        // componentes.add(TableRow(children: [
        //   BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        //   BotonInicio(
        //       icono: Icons.notification_add_rounded,
        //       etiqueta: 'notificaciones'),
        //   Container(),
        // ]));
        break;
      case 'RH':
        // componentes.add(TableRow(children: [
        //   BotonInicio(icono: Icons.inventory, etiqueta: 'proyectos'),
        //   Container(),
        //   BotonInicio(icono: Icons.folder, etiqueta: 'registros'),
        //   BotonInicio(icono: Icons.folder_shared, etiqueta: 'asignaciones'),
        //   Container(),
        // ]));
        componentes.addAll([
          BotonInicio(icono: Icons.person_add, etiqueta: 'usuarios'),
          BotonInicio(icono: Icons.person_pin, etiqueta: 'asistencia'),
        ]);
        break;
      case 'Cliente':
        break;
      case 'Tecnico':
        break;
    }

    return componentes;
  }
}
