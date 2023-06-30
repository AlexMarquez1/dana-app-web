import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:http/http.dart' as http;

import '../models/Agrupaciones.dart';
import '../models/Campos.dart';
import '../models/CamposProyecto.dart';
import '../models/Catalogo.dart';
import '../models/FirmaDocumento.dart';
import '../models/FotoEvidencia.dart';
import '../models/Inventario.dart';
import '../models/Proyecto.dart';
import '../services/APIWebService/ApiDefinitions.dart';
import '../services/APIWebService/Consultas.dart';
import '../utils/VariablesGlobales.dart';

class RegistroProvider extends ChangeNotifier {
  Inventario _inventario;
  List<Agrupaciones> _listaAgrupaciones;
  int _ind = 0;
  Map<String, Catalogo> _catalogos;
  Map<String, ByteData> _firmas;
  Map<String, Uint8List> _evidencia;
  Map<String, bool> _comprobarFirmas;
  Map<String, bool> _comprobarFotos;
  Map<String, DateTime> _camposCalendario;
  Map<String, TimeOfDay> _camposHora = {};
  List<Campos> _camposAValidar = [];
  Map<String, bool> _checkBox;
  Map<String, bool> _checkBoxEvidencia;
  Map<String, bool> _comprobarEvidenciaCheck;
  Map<String, Map<String, Uint8List>> _evidenciaCheckList;
  Map<String, GlobalKey<SignatureState>> _keyFirma =
      new Map<String, GlobalKey<SignatureState>>();

  bool _mostrarMasOpciones = false;

  Inventario get inventario {
    return _inventario;
  }

  set mostrarMasOpciones(bool mostrarMasOpciones) {
    _mostrarMasOpciones = mostrarMasOpciones;
    notifyListeners();
  }

  bool get mostrarMasOpciones {
    return _mostrarMasOpciones;
  }

  List<Campos> get camposAValidar {
    return _camposAValidar;
  }

  List<Agrupaciones> get listaAgrupaciones {
    return _listaAgrupaciones;
  }

  set listaAgrupaciones(List<Agrupaciones> lista) {
    _listaAgrupaciones = lista;
    notifyListeners();
  }

  Map<String, GlobalKey<SignatureState>> get keyFirma => _keyFirma;

  void actualizarValor(int indAgrupacion, int indCampo, String nuevoValor) {
    _listaAgrupaciones
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .valor = nuevoValor.toUpperCase();
    _listaAgrupaciones
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .valorController
        .text = nuevoValor.toUpperCase();
    notifyListeners();
  }

  void actualizarControlador(
      int indAgrupacion, int indCampo, TextEditingController controlador) {
    _listaAgrupaciones
        .elementAt(indAgrupacion)
        .campos
        .elementAt(indCampo)
        .valorController = controlador;
    notifyListeners();
  }

  void actualizarValorPorCampo(CamposProyecto campo, String valor) {
    for (int i = 0; i < _listaAgrupaciones.length; i++) {
      for (int j = 0; j < _listaAgrupaciones.elementAt(i).campos.length; j++) {
        if (_listaAgrupaciones.elementAt(i).campos.elementAt(j).idCampo ==
            campo.idcamposproyecto) {
          _listaAgrupaciones
              .elementAt(i)
              .campos
              .elementAt(j)
              .valorController
              .text = valor;
          _listaAgrupaciones.elementAt(i).campos.elementAt(j).valor = valor;
          break;
        }
      }
    }
    notifyListeners();
  }

  String obtenerValorPorCampo(CamposProyecto campo) {
    String respuesta = '';
    for (int i = 0; i < _listaAgrupaciones.length; i++) {
      for (int j = 0; j < _listaAgrupaciones.elementAt(i).campos.length; j++) {
        if (_listaAgrupaciones.elementAt(i).campos.elementAt(j).idCampo ==
            campo.idcamposproyecto) {
          respuesta = _listaAgrupaciones
              .elementAt(i)
              .campos
              .elementAt(j)
              .valorController
              .text;
          break;
        }
      }
    }
    return respuesta;
  }

  List<int> obtenerAgrupacionInd(CamposProyecto campo) {
    List<int> respuesta = [];
    for (int i = 0; i < _listaAgrupaciones.length; i++) {
      for (int j = 0; j < _listaAgrupaciones.elementAt(i).campos.length; j++) {
        if (_listaAgrupaciones.elementAt(i).campos.elementAt(j).idCampo ==
            campo.idcamposproyecto) {
          respuesta.add(i);
          respuesta.add(j);
          break;
        }
      }
    }
    return respuesta;
  }

  set ind(int i) {
    _ind = i;
    notifyListeners();
  }

  int get ind {
    return _ind;
  }

  Map<String, Catalogo> get catalogos {
    return _catalogos;
  }

  set catalogos(Map<String, Catalogo> catalogos) {
    _catalogos = catalogos;
  }

  void actualizarCatalogos(String key, Catalogo catalogo) {
    _catalogos[key] = catalogo;
    notifyListeners();
  }

  void agregarCatalogo(String key, String catalogo) {
    _catalogos[key].catalogo.add(catalogo);
    notifyListeners();
  }

  void catalogoVacio(String key) {
    _catalogos[key].catalogo = [];
    notifyListeners();
  }

  Map<String, ByteData> get firmas {
    return _firmas;
  }

  void actualizarFirmas(String key, ByteData valor) {
    _firmas[key] = valor;
  }

  Future<void> restablecerFirmas() async {
    _firmas = <String, ByteData>{};
    _comprobarFirmas = <String, bool>{};
    List<FirmaDocumento> respuestaFirmas = await obtenerFirmasPorProyecto(
        ApiDefinition.ipServer, inventario.proyecto, inventario);
    for (FirmaDocumento item in respuestaFirmas) {
      if (item.url.isEmpty) {
        _firmas[item.nombrefirma] = ByteData(0);
        _comprobarFirmas[item.nombrefirma] = false;
      } else {
        _firmas[item.nombrefirma] = await _descargarFirma(item.url);
        _comprobarFirmas[item.nombrefirma] = true;
      }
    }
    notifyListeners();
  }

  Map<String, Uint8List> get evidencia {
    return _evidencia;
  }

  void actualizarEvidencia(String key, Uint8List valor) {
    _evidencia[key] = valor;
    notifyListeners();
  }

  Future<void> restablecerEvidencia() async {
    _evidencia = <String, Uint8List>{};
    _comprobarFotos = <String, bool>{};
    List<FotoEvidencia> respuestaFotos = await obtenerFotosPorProyecto(
        ApiDefinition.ipServer, inventario.proyecto, inventario);
    for (FotoEvidencia item in respuestaFotos) {
      if (item.url.isEmpty) {
        _evidencia[item.nombrefoto] = Uint8List(0);
        _comprobarFotos[item.nombrefoto] = false;
      } else {
        _evidencia[item.nombrefoto] = await _descargarEvidencia(item.url);
        _comprobarFotos[item.nombrefoto] = true;
      }
    }
    notifyListeners();
  }

  Map<String, bool> get comprobarFirmas {
    return _comprobarFirmas;
  }

  void comprobarFirmasActualizarDato(String key, valor) {
    _comprobarFirmas[key] = valor;

    notifyListeners();
  }

  Map<String, TimeOfDay> get camposHora {
    return _camposHora;
  }

  void actualizarCampoHorao(String key, TimeOfDay valor) {
    _camposHora[key] = valor;
    notifyListeners();
  }

  void actualizarComprobarFirmas(String key, bool valor) {
    _comprobarFirmas[key] = valor;
    notifyListeners();
  }

  Map<String, bool> get comprobarFotos {
    return _comprobarFotos;
  }

  void actualizarComprobarFotos(String key, bool valor) {
    _comprobarFotos[key] = valor;
    notifyListeners();
  }

  Map<String, DateTime> get camposCalendario {
    return _camposCalendario;
  }

  void actualizarCampoCalendario(String key, DateTime valor) {
    _camposCalendario[key] = valor;
    notifyListeners();
  }

  Map<String, bool> get checkBox {
    return _checkBox;
  }

  void actualizarValorCheckBox(String key, bool valor) {
    _checkBox[key] = valor;
    notifyListeners();
  }

  Map<String, bool> get checkBoxEvidencia {
    return _checkBoxEvidencia;
  }

  void actualizarValorCheckBoxEvidencia(String key, bool valor) {
    _checkBoxEvidencia[key] = valor;
    notifyListeners();
  }

  Future<void> restablecerCheckBoxEvidencia() async {
    _checkBoxEvidencia = <String, bool>{};
    _comprobarEvidenciaCheck = <String, bool>{};
    _evidenciaCheckList = <String, Map<String, Uint8List>>{};

    List<FotoEvidencia> respuestaCheckBoxEvidencia =
        await obtenerCheckBoxEvidenciaProyecto(
            ApiDefinition.ipServer, inventario.proyecto, inventario);

    for (FotoEvidencia item in respuestaCheckBoxEvidencia) {
      if (item.url.isEmpty) {
        _checkBoxEvidencia[item.campoNombre] = false;
        _comprobarEvidenciaCheck[item.campoNombre] = false;
        _evidenciaCheckList[item.campoNombre] = <String, Uint8List>{};
      } else {
        _checkBoxEvidencia[item.campoNombre] = true;
        _comprobarEvidenciaCheck[item.campoNombre] = true;
        if (_evidenciaCheckList[item.campoNombre] != null) {
          _evidenciaCheckList[item.campoNombre][item.nombrefoto] =
              await _descargarEvidencia(item.url);
        } else {
          _evidenciaCheckList[item.campoNombre] = <String, Uint8List>{};
          _evidenciaCheckList[item.campoNombre][item.nombrefoto] =
              await _descargarEvidencia(item.url);
        }
      }
    }
    notifyListeners();
  }

  Map<String, bool> get comprobarEvidenciaCheck {
    return _comprobarEvidenciaCheck;
  }

  void actualizarValorComprobarEvidenciaCheck(String key, bool valor) {
    _comprobarEvidenciaCheck[key] = valor;
    notifyListeners();
  }

  Map<String, Map<String, Uint8List>> get evidenciaCheckList {
    return _evidenciaCheckList;
  }

  Future<void> obtenerRegistro(Inventario inventario, int idUsuario) async {
    _ind = 0;
    _inventario = inventario;
    Map<dynamic, dynamic> respuesta = await obtenerDatosProvider(
        ApiDefinition.ipServer, inventario.proyecto, inventario, idUsuario);

    _listaAgrupaciones = [];
    _catalogos = <String, Catalogo>{};
    var jsonListAgrupaciones = respuesta['listaAgrupaciones'] as List<dynamic>;
    for (int i = 0; i < jsonListAgrupaciones.length; i++) {
      _listaAgrupaciones
          .add(Agrupaciones.fromJson(jsonListAgrupaciones.elementAt(i)));
    }
    respuesta['catalogos'].forEach((key, value) {
      _catalogos[key] = Catalogo.fromJson(value);
    });

    List<FirmaDocumento> respuestaFirmas = [];
    var jsonListRespuestaFirmas = respuesta['respuestaFirmas'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaFirmas.length; i++) {
      print(jsonListRespuestaFirmas.elementAt(i));
      respuestaFirmas
          .add(FirmaDocumento.fromJson(jsonListRespuestaFirmas.elementAt(i)));
    }

    List<FotoEvidencia> respuestaFotos = [];
    var jsonListRespuestaFotos = respuesta['respuestaFotos'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaFotos.length; i++) {
      respuestaFotos
          .add(FotoEvidencia.fromJson(jsonListRespuestaFotos.elementAt(i)));
    }

    List<String> respuestaCheckBox = [];
    var jsonListRespuestaCheckBox =
        respuesta['respuestaCheckbox'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaCheckBox.length; i++) {
      respuestaCheckBox.add(jsonListRespuestaCheckBox.elementAt(i));
    }

    List<FotoEvidencia> respuestaCheckBoxEvidencia = [];
    var jsonListRespuestaCheckBoxEvidencia =
        respuesta['respuestaCheckboxEvidencia'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaCheckBoxEvidencia.length; i++) {
      respuestaCheckBoxEvidencia.add(FotoEvidencia.fromJson(
          jsonListRespuestaCheckBoxEvidencia.elementAt(i)));
    }

    _camposCalendario = _obtenerCamposCalendario(_listaAgrupaciones);
    _camposHora = _obtenerCamposHora(_listaAgrupaciones);
    _firmas = <String, ByteData>{};
    _evidencia = <String, Uint8List>{};
    _comprobarFirmas = <String, bool>{};
    _comprobarFotos = <String, bool>{};
    _checkBox = <String, bool>{};
    _checkBoxEvidencia = <String, bool>{};
    _comprobarEvidenciaCheck = <String, bool>{};
    _evidenciaCheckList = <String, Map<String, Uint8List>>{};
    _keyFirma = <String, GlobalKey<SignatureState>>{};

    for (FirmaDocumento item in respuestaFirmas) {
      _keyFirma[item.nombrefirma] = GlobalKey<SignatureState>();
      if (item.url.isEmpty) {
        _firmas[item.nombrefirma] = ByteData(0);
        _comprobarFirmas[item.nombrefirma] = false;
      } else {
        _firmas[item.nombrefirma] = await _descargarFirma(item.url);
        _comprobarFirmas[item.nombrefirma] = true;
      }
    }
    for (FotoEvidencia item in respuestaFotos) {
      if (item.url.isEmpty) {
        _evidencia[item.nombrefoto] = Uint8List(0);
        _comprobarFotos[item.nombrefoto] = false;
      } else {
        _evidencia[item.nombrefoto] = await _descargarEvidencia(item.url);
        _comprobarFotos[item.nombrefoto] = true;
      }
    }
    for (String item in respuestaCheckBox) {
      _checkBox[item] = false;
    }
    for (FotoEvidencia item in respuestaCheckBoxEvidencia) {
      if (item.url.isEmpty) {
        _checkBoxEvidencia[item.campoNombre] = false;
        _comprobarEvidenciaCheck[item.campoNombre] = false;
        _evidenciaCheckList[item.campoNombre] = <String, Uint8List>{};
      } else {
        _checkBoxEvidencia[item.campoNombre] = true;
        _comprobarEvidenciaCheck[item.campoNombre] = true;
        if (_evidenciaCheckList[item.campoNombre] != null) {
          _descargarEvidencia(item.url).then((value) =>
              _evidenciaCheckList[item.campoNombre][item.nombrefoto] = value);
        } else {
          _evidenciaCheckList[item.campoNombre] = <String, Uint8List>{};
          _descargarEvidencia(item.url).then((value) =>
              _evidenciaCheckList[item.campoNombre][item.nombrefoto] = value);
        }
      }
    }
    _acomodarDatos();
    notifyListeners();
  }

  Future<void> nuevoRegistro(Proyecto proyecto) async {
    Map<dynamic, dynamic> respuesta =
        await obtenerDatosRegistroNuevo(ApiDefinition.ipServer, proyecto);

    _listaAgrupaciones = [];
    _catalogos = <String, Catalogo>{};
    var jsonListAgrupaciones = respuesta['listaAgrupaciones'] as List<dynamic>;

    for (int i = 0; i < jsonListAgrupaciones.length; i++) {
      _listaAgrupaciones
          .add(Agrupaciones.fromJson(jsonListAgrupaciones.elementAt(i)));
    }
    respuesta['catalogos'].forEach((key, value) {
      _catalogos[key] = Catalogo.fromJson(value);
    });

    List<FirmaDocumento> respuestaFirmas = [];
    var jsonListRespuestaFirmas = respuesta['respuestaFirmas'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaFirmas.length; i++) {
      respuestaFirmas
          .add(FirmaDocumento.fromJson(jsonListRespuestaFirmas.elementAt(i)));
    }
    List<FotoEvidencia> respuestaFotos = [];
    var jsonListRespuestaFotos = respuesta['respuestaFotos'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaFotos.length; i++) {
      respuestaFotos
          .add(FotoEvidencia.fromJson(jsonListRespuestaFotos.elementAt(i)));
    }

    List<String> respuestaCheckBox = [];
    var jsonListRespuestaCheckBox =
        respuesta['respuestaCheckBox'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaCheckBox.length; i++) {
      respuestaCheckBox.add(jsonListRespuestaCheckBox.elementAt(i));
    }

    List<FotoEvidencia> respuestaCheckBoxEvidencia = [];
    var jsonListRespuestaCheckBoxEvidencia =
        respuesta['respuestaCheckBoxEvidencia'] as List<dynamic>;
    for (int i = 0; i < jsonListRespuestaCheckBoxEvidencia.length; i++) {
      respuestaCheckBoxEvidencia.add(FotoEvidencia.fromJson(
          jsonListRespuestaCheckBoxEvidencia.elementAt(i)));
    }
    _camposCalendario = _obtenerCamposCalendario(_listaAgrupaciones);
    _camposHora = _obtenerCamposHora(_listaAgrupaciones);

    _firmas = <String, ByteData>{};
    _evidencia = <String, Uint8List>{};

    _comprobarFirmas = <String, bool>{};
    _comprobarFotos = <String, bool>{};
    _comprobarEvidenciaCheck = <String, bool>{};
    _checkBox = <String, bool>{};
    _checkBoxEvidencia = <String, bool>{};
    _evidenciaCheckList = <String, Map<String, Uint8List>>{};
    _keyFirma = <String, GlobalKey<SignatureState>>{};

    for (FirmaDocumento item in respuestaFirmas) {
      _firmas[item.nombrefirma] = ByteData(0);
      _comprobarFirmas[item.nombrefirma] = false;
      _keyFirma[item.nombrefirma] = GlobalKey<SignatureState>();
    }
    for (FotoEvidencia item in respuestaFotos) {
      _evidencia[item.nombrefoto] = Uint8List(0);
      _comprobarFotos[item.nombrefoto] = false;
    }
    for (String item in respuestaCheckBox) {
      _checkBox[item] = false;
    }
    for (FotoEvidencia item in respuestaCheckBoxEvidencia) {
      _checkBoxEvidencia[item.campoNombre] = false;
      _comprobarEvidenciaCheck[item.campoNombre] = false;
      _evidenciaCheckList[item.campoNombre] = <String, Uint8List>{};
    }
    _acomodarDatos();
    notifyListeners();
  }

  void _acomodarDatos() {
    _camposAValidar = [];
    String nombreCampo = '';
    for (int i = 0; i < _listaAgrupaciones.length; i++) {
      for (int j = 0; j < _listaAgrupaciones.elementAt(i).campos.length; j++) {
        nombreCampo =
            _listaAgrupaciones.elementAt(i).campos.elementAt(j).nombreCampo;
        if (_listaAgrupaciones
                .elementAt(i)
                .campos
                .elementAt(j)
                .validarDuplicidad ==
            'TRUE') {
          _camposAValidar
              .add(listaAgrupaciones.elementAt(i).campos.elementAt(j));
        }
        if (_camposCalendario.containsKey(nombreCampo)) {
          String fecha =
              "${camposCalendario[nombreCampo].day.toString().padLeft(2, '0')}/${camposCalendario[nombreCampo].month.toString().padLeft(2, '0')}/${camposCalendario[nombreCampo].year}";
          actualizarValor(i, j, fecha);
        }
        if (_camposHora.containsKey(nombreCampo)) {
          String hora =
              '${camposHora[nombreCampo].hour.toString().padLeft(2, '0')}: ${camposHora[nombreCampo].minute.toString().padLeft(2, '0')}';
          actualizarValor(i, j, hora);
        }
      }
    }
  }

  Future<Uint8List> _descargarEvidencia(String url) async {
    Uint8List bytes = Uint8List(0);
    try {
      http.Client client = http.Client();
      var req = await client.get(Uri.parse(url));

      bytes = req.bodyBytes;
    } catch (e) {
      print('Error al cargar evidencia');
    }
    return bytes;
  }

  Future<ByteData> _descargarFirma(String url) async {
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(url));
    Uint8List bytes = req.bodyBytes;
    ByteData firma = ByteData.view(bytes.buffer);
    return firma;
  }

  Map<String, DateTime> _obtenerCamposCalendario(
      List<Agrupaciones> agrupaciones) {
    List<String> listaCalendarios = [];
    List<String> valores = [];
    Map<String, DateTime> campoCalendario = <String, DateTime>{};
    for (Agrupaciones agrupacion in agrupaciones) {
      for (Campos campo in agrupacion.campos) {
        if (campo.tipoCampo == 'CALENDARIO') {
          listaCalendarios.add(campo.nombreCampo);
          valores.add(campo.valor);
        }
      }
    }
    if (listaCalendarios.isNotEmpty) {
      for (int i = 0; i < listaCalendarios.length; i++) {
        print('Fecha: ${valores.elementAt(i)}');
        if (valores.isNotEmpty && valores.elementAt(i).length > 2) {
          if (valores.elementAt(i).length > 10) {
            List<String> fecha = valores.elementAt(i).split('-');
            if (fecha.length < 3) {
              campoCalendario[listaCalendarios.elementAt(i)] = DateTime.now();
            } else {
              int year = int.parse(valores.elementAt(i).split('-')[0]);
              int month = int.parse(valores.elementAt(i).split('-')[1]);
              int day =
                  int.parse(valores.elementAt(i).split('-')[2].substring(0, 1));
              campoCalendario[listaCalendarios.elementAt(i)] = DateTime(
                year,
                month,
                day,
              );
            }
          } else {
            List<String> fecha = valores.elementAt(i).split('/');
            if (fecha.length < 3) {
              campoCalendario[listaCalendarios.elementAt(i)] = DateTime.now();
            } else {
              int year = int.parse(valores.elementAt(i).split('/')[2]);
              int month = int.parse(valores.elementAt(i).split('/')[1]);
              int day = int.parse(valores.elementAt(i).split('/')[0]);

              campoCalendario[listaCalendarios.elementAt(i)] = DateTime(
                year,
                month,
                day,
              );
            }
          }
        } else {
          campoCalendario[listaCalendarios.elementAt(i)] = DateTime.now();
        }
      }
    }
    return campoCalendario;
  }

  Map<String, TimeOfDay> _obtenerCamposHora(List<Agrupaciones> agrupaciones) {
    List<String> listaHoras = [];
    List<String> valores = [];
    Map<String, TimeOfDay> horas = <String, TimeOfDay>{};
    for (Agrupaciones agrupacion in agrupaciones) {
      for (Campos campo in agrupacion.campos) {
        if (campo.tipoCampo == 'HORA') {
          listaHoras.add(campo.nombreCampo);
          valores.add(campo.valor);
        }
      }
    }
    if (listaHoras.isNotEmpty) {
      for (int i = 0; i < listaHoras.length; i++) {
        if (valores.isNotEmpty && valores.elementAt(i).length > 2) {
          List<String> textoSeparado =
              valores.elementAt(i).replaceAll(' ', '').split(':');
          print('Hora: $textoSeparado');
          if (textoSeparado.length == 2) {
            horas[listaHoras.elementAt(i)] = TimeOfDay(
                hour: int.parse(textoSeparado[0].replaceAll(' ', '')),
                minute: int.parse(textoSeparado[1].replaceAll(' ', '')));
          } else {
            horas[listaHoras.elementAt(i)] = TimeOfDay.now();
          }
        } else {
          horas[listaHoras.elementAt(i)] = TimeOfDay.now();
        }
      }
    }
    return horas;
  }
}
