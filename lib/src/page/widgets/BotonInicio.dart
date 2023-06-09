import 'package:flutter/material.dart';

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
              onTap: () {
                switch (etiqueta) {
                  case 'proyectos':
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
                    Navigator.of(context).pushNamed('/$etiqueta');
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
