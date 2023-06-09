import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class MensajeWidget extends StatelessWidget {
  Function(AnimationController) entrada;
  Function(AnimationController) salida;
  Function fnSalida;
  String titulo;
  String contenido;
  Color color;
  IconData icono;
  MensajeWidget({
    Key key,
    @required this.entrada,
    @required this.salida,
    @required this.fnSalida,
    @required this.titulo,
    @required this.contenido,
    @required this.color,
    @required this.icono,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeOutRight(
      animate: false,
      controller: salida,
      child: FadeInRight(
        animate: false,
        controller: entrada,
        child: _tarjeta(titulo, contenido),
      ),
    );
  }

  Widget _tarjeta(String titulo, String descripcion) {
    return SizedBox(
      width: 400.0,
      height: 150.0,
      child: Stack(children: [
        Card(
          shape:
              Border(bottom: BorderSide(color: Colors.grey[300], width: 10.0)),
          elevation: 10.0,
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Roulette(
                  animate: true,
                  infinite: true,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: Icon(
                      icono,
                      color: color,
                      size: 50.0,
                    ),
                    radius: 40.0,
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 30.0,
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: 200.0,
                      height: 60.0,
                      child: Text(
                        descripcion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: IconButton(
                onPressed: fnSalida,
                icon: Icon(Icons.close, color: Colors.white))),
      ]),
    );
  }
}
