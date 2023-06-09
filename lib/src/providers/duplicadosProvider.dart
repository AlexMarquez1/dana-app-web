import 'package:flutter/material.dart';

import '../models/Agrupaciones.dart';
import '../models/Proyecto.dart';

class DuplicadosProvider extends ChangeNotifier {
  Map<String, List<String>> _camposDuplicados;

  List<List<Agrupaciones>> _listaAgrupaciones;
  List<String> _listaBusqueda = [];

  int _indDuplicadoSeleccionado = -1;

  String _duplicadoSeleccionado = '';

  DuplicadosProvider() {
    _camposDuplicados = {};
    _listaAgrupaciones = [];
  }

  String get duplicadoSeleccionado {
    return _duplicadoSeleccionado;
  }

  set duplicadoSeleccionado(String duplicadoSeleccionado) {
    _duplicadoSeleccionado = duplicadoSeleccionado;
    notifyListeners();
  }

  int get indDuplicadoSeleccionado {
    return _indDuplicadoSeleccionado;
  }

  set indDuplicadoSeleccionado(int indDuplicadoSeleccionado) {
    _indDuplicadoSeleccionado = indDuplicadoSeleccionado;
    notifyListeners();
  }

  Map<String, List<String>> get camposDuplicados {
    return _camposDuplicados;
  }

  set camposDuplicados(Map<String, List<String>> camposDuplicados) {
    _camposDuplicados = camposDuplicados;
    notifyListeners();
  }

  List<List<Agrupaciones>> get listaAgrupaciones {
    return _listaAgrupaciones;
  }

  set listaAgrupaciones(List<List<Agrupaciones>> listaAgrupaciones) {
    _listaAgrupaciones = listaAgrupaciones;
    notifyListeners();
  }

  List<String> get listaBusqueda {
    return _listaBusqueda;
  }

  set listaBusqueda(List<String> listaBusqueda) {
    _listaBusqueda = listaBusqueda;
    notifyListeners();
  }
}
