import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BotonInicio extends StatefulWidget {
  IconData icono;
  String etiqueta;
  BotonInicio({Key key, @required this.icono, @required this.etiqueta})
      : super(key: key);

  @override
  State<BotonInicio> createState() => _BotonInicioState();
}

class _BotonInicioState extends State<BotonInicio> {
  double escala = 0.9;

  @override
  Widget build(BuildContext context) {
    return _boton(widget.icono, widget.etiqueta);
  }

  Widget _boton(IconData icono, String etiqueta) {
    return Transform.scale(
      scale: escala,
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          children: [
            InkWell(
              child: MouseRegion(
                onHover: (_) {
                  setState(() {
                    escala = 1.3;
                  });
                },
                onExit: (_) {
                  setState(() {
                    escala = 0.9;
                  });
                },
                child: CircleAvatar(
                  maxRadius: 70.0,
                  backgroundColor: Color.fromRGBO(36, 90, 149, 1),
                  child: Icon(
                    icono,
                    color: Colors.white,
                    size: 70.0,
                  ),
                ),
              ),
              onTap: () async {
                switch (etiqueta) {
                  case 'proyectos':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'clientes':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'localidades':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'usuarios':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'catalogo':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'asignaciones':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'registros':
                    PantallaDeCarga.loadingI(context, true);
                    RegistroProvider registroProvider =
                        Provider.of<RegistroProvider>(context, listen: false);
                    // print(
                    //     'Cliente: ${VariablesGlobales.usuario.clienteAplicacion.cliente}');
                    // List<Cliente> listaClientes =
                    //     await obtenerClientesPorUsuario(
                    //         ApiDefinition.ipServer,
                    //         VariablesGlobales
                    //             .usuario.clienteAplicacion.idcliente);

                    // PantallaDeCarga.loadingI(context, false);

                    // Navigator.of(context).pushNamed('/clientes',
                    //     arguments: registroProvider.listaClientes);
                    PantallaDeCarga.loadingI(context, true);
                    List<Proyecto> listaProyectosPorCliente =
                        await obtenerProyecrtosPorCliente(
                            ApiDefinition.ipServer,
                            registroProvider.usuario.vistacliente);
                    print(
                        'Cantidad de proyectos: ${listaProyectosPorCliente.length}');
                    PantallaDeCarga.loadingI(context, false);
                    Navigator.pushNamed(context, '/registros',
                        arguments: listaProyectosPorCliente);
                    break;
                  case 'asistencia':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'dashborad':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'notificaciones':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'duplicados':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                  case 'balance':
                    Navigator.of(context).pushNamed('/$etiqueta');
                    break;
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: Text(etiqueta.toUpperCase(),
                  style: TextStyle(
                      color: Color.fromRGBO(36, 90, 149, 1),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
