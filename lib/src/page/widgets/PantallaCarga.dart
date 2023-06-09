import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class PantallaDeCarga {
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _FullScreenLoader(),
    );
  }

  static loadingI(BuildContext context, bool status) async {
    if (status == true) {
      show(context);
    } else {
      hide(context);
    }
  }

  PantallaDeCarga._create(context);
}

class _FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
        child: Center(
            child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
              child: LoadingBouncingGrid.square(
                size: 100,
                inverted: true,
                backgroundColor: Color.fromRGBO(0, 147, 202, 1),
              ),
            ),
            Material(
              color: Color.fromARGB(0, 0, 0, 1),
              child: Text(
                'Cargando',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
          ],
        )));
  }
}
