import 'package:flutter/material.dart';

class TarjetaInformacion extends StatelessWidget {
  double width;
  String titulo;
  Widget contenido;
  Function click;
  TarjetaInformacion(
      {key,
      @required this.width,
      this.titulo = '',
      this.contenido,
      this.click});
  final colorPrincipal = Colors.white38;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: click,
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: width,
        decoration: BoxDecoration(
          color: colorPrincipal,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Column(
            children: [
              _texto(
                titulo,
                TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              contenido,
            ],
          ),
        ),
      ),
    );
  }

  Widget _texto(String texto, TextStyle estilo) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Text(
        texto,
        style: estilo,
        textAlign: TextAlign.left,
      ),
    );
  }
}
