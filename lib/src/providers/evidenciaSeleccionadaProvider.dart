import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:flutter/material.dart';

class EvidenciaSeleccionadaProvider extends ChangeNotifier {
  List<FotoEvidencia> _evidenciaSeleccionada = [];

  List<FotoEvidencia> get evidenciaSeleccionada => _evidenciaSeleccionada;

  set evidenciaSeleccionada(List<FotoEvidencia> evidencia) {
    print('Mandando informacion:');
    for (FotoEvidencia item in evidencia) {
      print('IdFoto: ${item.idfoto}');
    }
    _evidenciaSeleccionada = evidencia;

    notifyListeners();
  }

  void add(FotoEvidencia foto) {
    _evidenciaSeleccionada.add(foto);
    notifyListeners();
  }

  void remove(FotoEvidencia foto) {
    for (int i = 0; i < _evidenciaSeleccionada.length; i++) {
      if (_evidenciaSeleccionada[i].idfoto == foto.idfoto) {
        _evidenciaSeleccionada.removeAt(i);
        break;
      }
    }
    notifyListeners();
  }

  void removeAll() {
    _evidenciaSeleccionada = [];
    notifyListeners();
  }
}
