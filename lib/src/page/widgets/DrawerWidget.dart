import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerPrincipal extends StatelessWidget {
  DrawerPrincipal({Key key}) : super(key: key);
  final ScrollController scrollController = ScrollController();
  RegistroProvider _registroProvider;

  @override
  Widget build(BuildContext context) {
    _registroProvider = Provider.of<RegistroProvider>(context, listen: true);
    return Drawer(
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Color.fromRGBO(36, 90, 149, 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  height: 100.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          for (Widget widget in _listaOpciones(context)) widget,
          _opciones(context, Icons.power_settings_new, 'Cerrar Sesion'),
        ],
      ),
    );
  }

  List<Widget> _listaOpciones(BuildContext context) {
    List<Widget> lista = [];

    switch (VariablesGlobales.usuario.perfil.perfil) {
      case 'Super Admin':
        lista.add(
          _opciones(context, Icons.inventory, 'proyectos'),
        );
        lista.add(
          _opciones(context, Icons.person_add, 'usuarios'),
        );
        lista.add(
          _opciones(context, Icons.assignment, 'catalogo'),
        );
        lista.add(
          _opciones(context, Icons.folder_shared, 'asignaciones'),
        );
        lista.add(
          _opciones(context, Icons.folder, 'registros'),
        );
        lista.add(
          _opciones(context, Icons.person_pin, 'asistencia'),
        );
        lista.add(
          _opciones(context, Icons.notification_add_rounded, 'notificaciones'),
        );
        break;
      case 'Administrador':
        lista.add(
          _opciones(context, Icons.inventory, 'proyectos'),
        );
        lista.add(
          _opciones(context, Icons.person_add, 'usuarios'),
        );
        lista.add(
          _opciones(context, Icons.assignment, 'catalogo'),
        );
        lista.add(
          _opciones(context, Icons.folder_shared, 'asignaciones'),
        );
        lista.add(
          _opciones(context, Icons.folder, 'registros'),
        );
        lista.add(
          _opciones(context, Icons.person_pin, 'asistencia'),
        );
        lista.add(
          _opciones(context, Icons.notification_add_rounded, 'notificaciones'),
        );
        break;
      case 'Coordinador':
        lista.add(
          _opciones(context, Icons.inventory, 'proyectos'),
        );
        lista.add(
          _opciones(context, Icons.folder, 'registros'),
        );
        lista.add(
          _opciones(context, Icons.folder_shared, 'asignaciones'),
        );
        // lista.add(
        //   _opciones(context, Icons.person_pin, 'asistencia'),
        // );
        // lista.add(
        //   _opciones(context, Icons.notification_add_rounded, 'notificaciones'),
        // );
        break;
      case 'Documentador':
        lista.add(
          _opciones(context, Icons.inventory, 'proyectos'),
        );
        lista.add(
          _opciones(context, Icons.folder, 'registros'),
        );
        break;
      case 'RH':
        lista.add(
          _opciones(context, Icons.person_add, 'usuarios'),
        );
        lista.add(
          _opciones(context, Icons.folder_shared, 'asignaciones'),
        );
        break;
      case 'Cliente':
        break;
      case 'Tecnico':
        break;
    }
    return lista;
  }

  Widget _opciones(BuildContext context, IconData icono, String etiqueta) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: ListTile(
        leading: Icon(icono),
        title: Text(etiqueta.toUpperCase()),
        onTap: () async {
          switch (etiqueta) {
            case 'proyectos':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/clientes');
              break;
            case 'usuarios':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/$etiqueta');
              break;
            case 'catalogo':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/$etiqueta');
              break;
            case 'asignaciones':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/$etiqueta');
              break;
            case 'registros':
              // PantallaDeCarga.loadingI(context, true);
              // print(
              //     'Cliente: ${VariablesGlobales.usuario.clienteAplicacion.cliente}');
              // List<Cliente> listaClientes = await obtenerClientesPorUsuario(
              //     ApiDefinition.ipServer,
              //     VariablesGlobales.usuario.clienteAplicacion.idcliente);

              // PantallaDeCarga.loadingI(context, false);

              // Navigator.of(context).pushNamed('/clientes',
              //     arguments: _registroProvider.listaClientes);
              PantallaDeCarga.loadingI(context, true);
              List<Proyecto> listaProyectosPorCliente =
                  await obtenerProyecrtosPorCliente(ApiDefinition.ipServer,
                      _registroProvider.usuario.vistacliente);
              print(
                  'Cantidad de proyectos: ${listaProyectosPorCliente.length}');
              PantallaDeCarga.loadingI(context, false);
              Navigator.pushNamed(context, '/registros',
                  arguments: listaProyectosPorCliente);
              break;
            case 'asistencia':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/$etiqueta');
              break;
            case 'notificaciones':
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/$etiqueta');
              break;
            case 'Cerrar Sesion':
              Navigator.pop(context);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
              break;
          }
        },
      ),
    );
  }
}
