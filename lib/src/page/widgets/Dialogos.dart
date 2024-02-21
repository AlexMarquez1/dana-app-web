import 'package:flutter/material.dart';

class Dialogos {
  static error(BuildContext context, String mensaje) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Container(child: Text("Error")),
            children: <Widget>[
              Center(
                child: Text(mensaje.toUpperCase()),
              ),
              Container(
                  padding: EdgeInsets.only(top: 10.0, right: 10.0),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Aceptar'),
                  )),
            ],
          );
        });
  }

  static mensaje(BuildContext context, String mensaje) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Container(child: Text('Mensaje')),
            children: <Widget>[
              Center(
                child: Text(mensaje.toUpperCase()),
              ),
              Container(
                  padding: EdgeInsets.only(top: 10.0, right: 10.0),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Aceptar'),
                  )),
            ],
          );
        });
  }

  static advertencia(
      BuildContext context, String mensaje, Function() btnAceptar) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Row(
              children: [
                Icon(Icons.warning),
                SizedBox(
                  width: 20.0,
                ),
                Container(child: Text("Mensaje")),
              ],
            ),
            children: <Widget>[
              Center(
                child: Container(
                    margin: EdgeInsets.all(30.0),
                    child: Text(mensaje.toUpperCase())),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.only(top: 10.0, right: 10.0),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: btnAceptar,
                          child: Text('Aceptar'),
                        )),
                    Container(
                        padding: EdgeInsets.only(top: 10.0, right: 10.0),
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancelar'),
                        )),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
