import 'package:flutter/material.dart';

class NotificacionProvider with ChangeNotifier {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _contenidoController = TextEditingController();

  NotificacionProvider() {
    _tituloController.addListener(() {
      notifyListeners();
    });
    _contenidoController.addListener(() {
      notifyListeners();
    });
  }

  TextEditingController get tituloController {
    return _tituloController;
  }

  TextEditingController get contenidoController {
    return _contenidoController;
  }
}
