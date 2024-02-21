import 'package:flutter/material.dart';

import '../../models/Agrupaciones.dart';
import '../../models/Campos.dart';

class DatosInventario extends StatelessWidget {
  List<Agrupaciones>? agrupaciones;
  int? indRegistro;
  Function()? editar;
  Function()? eliminar;

  DatosInventario(
      {Key? key,
      this.agrupaciones,
      this.indRegistro,
      this.editar,
      this.eliminar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _datosRegistro(context, agrupaciones, indRegistro);
  }

  Widget _datosRegistro(BuildContext context, List<Agrupaciones>? agrupaciones,
      int? indRegistro) {
    return Container(
      padding: EdgeInsets.all(10.0),
      // width: 500.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            const Radius.circular(20.0),
          ),
        ),
        margin: EdgeInsets.all(10.0),
        child: Stack(
          children: [
            Positioned(
              top: 0.0,
              child: indRegistro == -1
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(36, 90, 149, 1),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                      ),
                      width: 420.0,
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tooltip(
                            message: 'Editar',
                            child: IconButton(
                                onPressed: editar,
                                icon: Icon(
                                  Icons.edit_note_sharp,
                                  color: Colors.white,
                                )),
                          ),
                          Tooltip(
                            message: 'Eliminar',
                            child: IconButton(
                                onPressed: eliminar,
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                )),
                          ),
                        ],
                      ),
                    ),
            ),
            Container(
              margin: indRegistro == -1
                  ? EdgeInsets.only(top: 10.0)
                  : EdgeInsets.only(top: 50.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    for (Agrupaciones agrupacion in agrupaciones!)
                      for (Campos campo in agrupacion.campos!)
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Row(
                            children: [
                              Container(
                                width: 200.0,
                                height: campo.nombreCampo!.length > 23
                                    ? 55.0
                                    : 40.0,
                                child: Center(
                                  child: Text(campo.nombreCampo!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(36, 90, 149, 1),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3),
                                ),
                              ),
                              campo.valor == "TRUE"
                                  ? Container(
                                      width: 200.0,
                                      height: campo.valor!.length > 23
                                          ? 55.0
                                          : 40.0,
                                      child: Icon(
                                        Icons.check_circle_outline_outlined,
                                        color: Colors.green,
                                      ),
                                    )
                                  : campo.valor == "FALSE"
                                      ? Container(
                                          width: 200.0,
                                          height: campo.valor!.length > 23
                                              ? 55.0
                                              : 40.0,
                                          child: Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.red,
                                          ),
                                        )
                                      : Container(
                                          width: 200.0,
                                          height: campo.valor!.length > 23
                                              ? 55.0
                                              : 40.0,
                                          child: Center(
                                            child: Text(campo.valor!,
                                                style: TextStyle(
                                                  overflow: TextOverflow.clip,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 3),
                                          ),
                                        ),
                            ],
                          ),
                        )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
