import 'dart:convert';
import 'dart:typed_data';

import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:app_isae_desarrollo/src/models/Asistencia.dart';
import 'package:app_isae_desarrollo/src/models/Catalogo.dart';
import 'package:app_isae_desarrollo/src/models/CatalogoRelacionado.dart';
import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/DatosAValidar.dart';
import 'package:app_isae_desarrollo/src/models/EdicionAsignada.dart';
import 'package:app_isae_desarrollo/src/models/Estatus.dart';
import 'package:app_isae_desarrollo/src/models/Evidencia.dart';
import 'package:app_isae_desarrollo/src/models/Firma.dart';
import 'package:app_isae_desarrollo/src/models/FirmaDocumento.dart';
import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/models/HistorialCambios.dart';
import 'package:app_isae_desarrollo/src/models/Inventario.dart';
import 'package:app_isae_desarrollo/src/models/Notificaciones.dart';
import 'package:app_isae_desarrollo/src/models/Pendiente.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Proyecto.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/models/ValoresCampo.dart';
import 'package:app_isae_desarrollo/src/models/ValoresCampos.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:http/http.dart' as http;

import '../../models/Campos.dart';

Future<String> crearProyecto(String api, List<Agrupaciones> lista,
    String nombreProyecto, String tipoProyecto) async {
  String respuesta = 'Error';

  Uri url = Uri.parse(api + '/crear/proyecto/$nombreProyecto/$tipoProyecto');
  var body = json.encode(lista);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
    respuesta = 'Correcto';
  }

  return respuesta;
}

Future<List<Usuario>> obtenerUsuariosConToken(String api) async {
  List<Usuario> usuario = [];
  Uri url = Uri.parse(api + '/obtener/usuarios/token');
  var response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;

    for (int i = 0; i < jsonList.length; i++) {
      usuario.add(Usuario.fromJson(jsonList.elementAt(i)));
    }
  }
  return usuario;
}

Future<List<String>> actualizarFolioRegsitro(
    String api, Inventario registro) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/actualizar/folio/registro');

  var body = json.encode(registro.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<String> eliminarProyecto(String api, Proyecto proyecto) async {
  String respuesta = 'Error';

  Uri url = Uri.parse(api + '/eliminar/proyectos');

  var body = json.encode(proyecto.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    respuesta = response.body;
  }

  return respuesta;
}

Future<String> comprobarValoresDuplicado(
    String api, List<Campos> valores, int idProyecto, int idInventario) async {
  String datos = '';
  Uri url =
      Uri.parse(api + '/validar/valores/duplicados/$idProyecto/$idInventario');
  var body = json.encode({'campos': valores}['campos']);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    datos = response.body;
  }
  return datos;
}

Future<String> crearUsuario(String api, Usuario usuario) async {
  String respuesta = 'Error';
  Uri url = Uri.parse(api + '/crear/usuario');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
    respuesta = 'Correcto';
  }
  return respuesta;
}

Future<String> editarUsuario(String api, Usuario usuario) async {
  String respuesta = 'Error';
  Uri url = Uri.parse(api + '/editar/usuario');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
    respuesta = 'Correcto';
  }
  return respuesta;
}

Future<String> editarPassword(String api, Usuario usuario) async {
  String respuesta = 'Error';
  Uri url = Uri.parse(api + '/editar/password');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
    respuesta = 'Correcto';
  }
  return respuesta;
}

Future<String> eliminarUsuario(String api, Usuario usuario) async {
  String respuesta = 'Error';
  Uri url = Uri.parse(api + '/eliminar/usuario');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
    respuesta = 'Error';
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
    respuesta = 'Correcto';
  }
  return respuesta;
}

Future<List<String>> obtenerTipoProyectos(String api) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/tipoproyecto');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (String dato in jsonList) {
      lista.add(dato);
    }
  }
  return lista;
}

Future<List<Proyecto>> obtenerProyectos(String api) async {
  List<Proyecto> lista = [];
  Uri url = Uri.parse(api + '/obtener/proyectos');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Proyecto(
          idproyecto: jsonList.elementAt(i)['idproyecto'],
          proyecto: jsonList.elementAt(i)['proyecto'],
          descripcion: jsonList.elementAt(i)['tipoproyecto']['descripcion'],
          fechacreacion: jsonList.elementAt(i)['fechacreacion']));
    }
  }
  return lista;
}

Future<List<Proyecto>> obtenerProyectosAsignados(
    String api, Usuario usuario) async {
  List<Proyecto> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/proyectos/asignados/${usuario.idUsuario}');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Proyecto(
          idproyecto: jsonList.elementAt(i)['idproyecto'] ?? 0,
          proyecto: jsonList.elementAt(i)['proyecto'] ?? '',
          descripcion:
              jsonList.elementAt(i)['tipoproyecto']['descripcion'] ?? '',
          fechacreacion: jsonList.elementAt(i)['fechacreacion'] ?? ''));
    }
  }
  return lista;
}

Future<List<Inventario>> obtenerRegistros(String api, int idProyecto) async {
  List<Inventario> lista = [];
  Uri url = Uri.parse(api + '/obtener/registros/$idProyecto');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Inventario>> obtenerRegistrosBusqueda(
    String api, int idProyecto, String busqueda) async {
  List<Inventario> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/registros/busqueda/$idProyecto/$busqueda');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Inventario>> obtenerRegistrosUsuarioProyecto(
    String api, Usuario usuario, Proyecto proyecto) async {
  List<Inventario> lista = [];
  Uri url = Uri.parse(api +
      '/obtener/registros/asignados/usuario/proyecto/${usuario.idUsuario}/${proyecto.idproyecto}');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Inventario>> getRegistrosPorProyecto(
    String api, Proyecto proyecto) async {
  List<Inventario> lista = [];
  Uri url = Uri.parse(api + '/obtener/registros/proyecto');

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(proyecto));
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<String>> obtenerRegistrosAsignados(
    String api, int idusuario) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/registros/asignados/$idusuario');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> asignarProyecto(
    String api, int idUsuario, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/asignar/proyecto/$idUsuario/$idProyecto');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<Map<String, List<String>>> obtenerDuplicadosPorProyecto(
    String api, int idProyecto) async {
  Map<String, List<String>> respuesta = {};
  Uri url = Uri.parse(api + '/obtener/duplicados/proyecto/$idProyecto');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as Map;
    jsonList.forEach((key, value) {
      List<String> valores = [];
      for (var item in value) {
        valores.add(item.toString());
      }
      respuesta[key] = valores;
    });
  }
  return respuesta;
}

Future<List<String>> asignarRegistro(
    String api, int idUsuario, List<String> idRegistros) async {
  List<String> lista = [];
  Map datos = {'idRegistros': idRegistros};
  var body = json.encode(datos['idRegistros']);
  Uri url = Uri.parse(api + '/asignar/registro/$idUsuario');
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<int>> generarDocumentoRegistros(
    String api, List<Inventario> listaRegistro) async {
  List<int> lista = [];
  Map datos = {'listaRegistro': listaRegistro};
  var body = json.encode(datos['listaRegistro']);
  Uri url = Uri.parse(api + '/generar/documento/registros');
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList[i]);
    }
  }
  return lista;
}

Future<List<int>> generarDocumentoRegistrosProyecto(
    String api, List<Inventario> listaRegistro, int idProyecto) async {
  List<int> lista = [];
  Map datos = {'listaRegistro': listaRegistro};
  var body = json.encode(datos['listaRegistro']);
  Uri url = Uri.parse(api + '/generar/documento/registros/$idProyecto');
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList[i]);
    }
  }
  return lista;
}

Future<List<String>> obtenerEstados(String api) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/estados');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<Perfil>> obtenerPerfiles(String api) async {
  List<Perfil> lista = [];
  Uri url = Uri.parse(api + '/obtener/perfiles');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Perfil(
          idperfil: jsonList.elementAt(i)['idperfil'].toString(),
          perfil: jsonList.elementAt(i)['perfil']));
    }
  }
  return lista;
}

Future<List<Usuario>> obtenerUsuarios(String api) async {
  List<Usuario> lista = [];
  Uri url = Uri.parse(api + '/obtener/usuarios');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Usuario.fromJson(jsonList[i]));
    }
  }

  return lista;
}

Future<List<Usuario>> obtenerUsuario(String api, Usuario usuario) async {
  List<Usuario> lista = [];
  //https://www.danae.com.mx:8443/web-0.0.1-SNAPSHOT/obtener/usuario
  Uri url = Uri.parse(api + '/obtener/usuario');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Usuario.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<String> obtenerUrlDocumento(String api, int idInventario) async {
  String respuesta;
  Uri url = Uri.parse(api + '/obtener/documento/inventario/$idInventario');
  var response = await http.get(url);
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    respuesta = response.statusCode.toString();
  } else {
    respuesta = response.body;
  }
  return respuesta;
}

Future<List<String>> asignarPass(String api, Usuario usuario) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/editar/password');
  var body = json.encode(usuario.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> obtenerCatalogoCamposProyecto(
    String api, Proyecto proyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/catalogo/campos/proyecto');
  var body = json.encode(proyecto.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<Catalogo> obtenerDatosCatalogoCamposProyecto(
    String api, Proyecto proyecto, String tipoCatalogo) async {
  Catalogo catalogo = Catalogo();
  Uri url = Uri.parse(api + '/obtener/catalogo/datos/proyecto/$tipoCatalogo');
  var body = json.encode(proyecto.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (jsonList['tipoCatalogo'] != null) {
      catalogo = Catalogo.fromJson(jsonList);
    }
  }
  return catalogo;
}

Future<Catalogo> obtenerDatosCatalogoCamposProyectoUsuario(
    String api, Proyecto proyecto, String tipoCatalogo, int idUsuario) async {
  Catalogo catalogo = Catalogo();
  Uri url = Uri.parse(
      api + '/obtener/catalogo/datos/proyecto/$tipoCatalogo/$idUsuario');
  var body = json.encode(proyecto.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (jsonList['tipoCatalogo'] != null) {
      catalogo = Catalogo.fromJson(jsonList);
    }
  }
  return catalogo;
}

Future<String> nuevoCatalogoUsuario(String api, String tipoCatalogo,
    int idProyecto, int idUsuario, String catalogo) async {
  String datos = '';
  Uri url = Uri.parse(api +
      '/nuevo/catalogos/usuario/$tipoCatalogo/$idProyecto/$idUsuario/$catalogo');

  try {
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode < 200 ||
        response.statusCode > 400 ||
        json == null) {
      print('Error al obtener la informacion');
      final error = response.statusCode;
    } else {
      datos = response.body;
    }
  } catch (e) {
    print(url);
    print('Error en la consulta: $e');
  }
  return datos;
}

Future<String> nuevoCatalogoAutoCompleteUsuario(String api, String tipoCatalogo,
    int idProyecto, int idUsuario, String catalogo) async {
  String datos = '';
  Uri url = Uri.parse(
      api + '/nuevo/catalogos/usuario/$tipoCatalogo/$idProyecto/$idUsuario');

  var body = json.encode({'catalogo': catalogo});
  try {
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);

    if (response.statusCode < 200 ||
        response.statusCode > 400 ||
        json == null) {
      print('Error al obtener la informacion');
      final error = response.statusCode;
    } else {
      datos = response.body;
    }
  } catch (e) {
    print(url);
    print(body);
    print('Error en la consulta: $e');
  }
  return datos;
}

Future<List<FotoEvidencia>> obtenerFotosProyecto(
    String api, int idProyecto, int idInventario) async {
  List<FotoEvidencia> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/fotos/proyecto/$idProyecto/$idInventario');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(response.body) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(FotoEvidencia.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<List<HistorialCambios>> obtenerHistorialPorInventario(
    String api, Inventario inventario) async {
  List<HistorialCambios> lista = [];
  Uri url = Uri.parse(api + '/obtener/historial/registro');

  var body = json.encode(inventario.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(response.body) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(HistorialCambios.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<List<FotoEvidencia>> obtenerEvidencias(
    String api, List<int> listaInventarios) async {
  List<FotoEvidencia> lista = [];
  Uri url = Uri.parse(api + '/obtener/evidencias/inventarios');
  var datos = {'listaInventarios': listaInventarios};
  var body = json.encode(datos['listaInventarios']);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(response.body) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(FotoEvidencia.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<List<FirmaDocumento>> obtenerFirmaProyecto(
    String api, int idProyecto, int idInventario) async {
  List<FirmaDocumento> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/firmas/proyecto/$idProyecto/$idInventario');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(response.body) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(FirmaDocumento.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<Catalogo?> obtenerDatosCatalogoCamposProyectoRelacionado(String api,
    Proyecto proyecto, String tipoCatalogo, String catalogoSeleccionado) async {
  Catalogo? catalogo;
  Uri url = Uri.parse(api +
      '/obtener/catalogo/datos/proyecto/relacionado/$tipoCatalogo/$catalogoSeleccionado');
  var body = json.encode(proyecto.toJson());
  print(body);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    catalogo = Catalogo.fromJson(jsonList);
  }
  return catalogo;
}

Future<List<CatalogoRelacionado>?> obtenerCatalogosRelacionadoProyecto(
    String api, Proyecto proyecto) async {
  List<CatalogoRelacionado>? catalogo;
  Uri url = Uri.parse(api +
      '/obtener/catalogo/datos/proyecto/relacionado/${proyecto.idproyecto}');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    //catalogo = Catalogo.fromJson(jsonList);
  }
  return catalogo;
}

Future<List<String>> eliminarCatalogos(
    String api, Proyecto proyecto, String tipoCatalogo) async {
  List<String> lista = [];
  Uri url = Uri.parse(
      api + '/eliminar/catalogos/$tipoCatalogo/${proyecto.idproyecto}');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> eliminarAsignacionProyecto(
    String api, Proyecto proyecto, Usuario usuario) async {
  List<String> lista = [];
  Uri url = Uri.parse(api +
      '/eliminar/asignacion/proyecto/${usuario.idUsuario}/${proyecto.idproyecto}');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<FirmaDocumento>> obtenerFirmasPorProyecto(
    String api, Proyecto proyecto, Inventario inventario) async {
  List<FirmaDocumento> datos = [];
  Uri url = Uri.parse(api +
      '/obtener/campos/firma/proyecto/${proyecto.idproyecto}/${inventario.idinventario}');
  var response = await http.get(url);
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    var jsonList = json.decode(response.body) as List;
    var countR = jsonList.toList().length;

    for (int i = 0; i < countR; i++) {
      datos.add(FirmaDocumento.fromJson(jsonList[i]));
    }
  }
  return datos;
}

Future<List<Inventario>> registrarAsignarRegistro(
    String api, Usuario usuario, Proyecto proyecto) async {
  List<Inventario> lista = [];
  String url = api +
      '/registrar/asignar/nuevo/registro/${proyecto.idproyecto}/${usuario.idUsuario}';
  var uri = Uri.parse(url);
  var response =
      await http.get(uri, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(response.body) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList[i]));
    }
  }
  return lista;
}

Future<String?> actualizarDashboard(
    String api, String proyecto, String datoAnterior, String datoNuevo) async {
  String? dato;
  Uri url = Uri.parse(
      api + '/actualizar/dashboard/$proyecto/$datoAnterior/$datoNuevo');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    dato = response.body;
  }
  return dato;
}

Future<Map<dynamic, dynamic>> obtenerDatosProvider(
    String api, Proyecto proyecto, Inventario inventario, int idUsuario) async {
  Map<dynamic, dynamic> respuesta = <dynamic, dynamic>{};
  String url = api +
      '/obtener/datoscompletos/registro/${inventario.idinventario}/${proyecto.idproyecto}/$idUsuario';
  var uri = Uri.parse(url);
  var response =
      await http.get(uri, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as Map;
    respuesta = jsonList;
  }
  return respuesta;
}

Future<Map<dynamic, dynamic>> obtenerDatosProviderPorUsuarios(String api,
    Proyecto proyecto, Inventario inventario, List<Usuario> usuarios) async {
  Map<dynamic, dynamic> respuesta = <dynamic, dynamic>{};
  String url = api +
      '/obtener/datoscompletos/registro/${inventario.idinventario}/${proyecto.idproyecto}';
  var uri = Uri.parse(url);
  var response = await http.post(uri,
      headers: {"Content-Type": "application/json"}, body: usuarios);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as Map;
    respuesta = jsonList;
  }
  return respuesta;
}

Future<List<FotoEvidencia>> obtenerFotosPorProyecto(
    String api, Proyecto proyecto, Inventario inventario) async {
  List<FotoEvidencia> datos = [];
  String url = api +
      '/obtener/campos/foto/proyecto/${proyecto.idproyecto}/${inventario.idinventario}';
  var uri = Uri.parse(url);
  var response = await http.get(uri);
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    var jsonList = json.decode(response.body) as List;
    var countR = jsonList.toList().length;

    for (int i = 0; i < countR; i++) {
      datos.add(FotoEvidencia.fromJson(jsonList[i]));
    }
  }
  return datos;
}

Future<List<String>> eliminarAsignacionRegistro(
    String api, int idUsuario, int idRegistro) async {
  List<String> lista = [];
  Uri url =
      Uri.parse(api + '/eliminar/asignacion/registro/$idUsuario/$idRegistro');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> crearCatalogo(String api, Proyecto proyecto,
    List<String> catalogo, String tipoCatalogo) async {
  List<String> lista = [];
  print('Tipo Catalogo: ' + tipoCatalogo);
  Uri url =
      Uri.parse(api + '/crear/catalogo/${proyecto.idproyecto}/$tipoCatalogo');
  var body = json.encode(catalogo);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> crearCatalogoRelacionado(
    String api, CatalogoRelacionado catalogo, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/crear/catalogo/relacionado/$idProyecto');
  var body = json.encode(catalogo.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<Inventario>> obtenerValoresCampos(String api, int idProyecto,
    String campo, String busqueda, int idusuario) async {
  List<Inventario> lista = [];
  Uri url = Uri.parse(api + '/obtener/valores/campos/busqueda');
  Map<String, String> datos = {
    'campo': campo,
    'busqueda': busqueda,
    'idproyecto': idProyecto.toString(),
    'idusuario': idusuario.toString(),
  };
  var body = json.encode(datos);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Inventario>> obtenerValoresCamposUsuarios(
    String api,
    int idProyecto,
    String campo,
    String busqueda,
    List<Usuario> usuarios) async {
  List<Inventario> lista = [];
  Uri url = Uri.parse(api + '/obtener/valores/campos/busqueda');
  Map<String, dynamic> datos = {
    'campo': campo,
    'busqueda': busqueda,
    'idproyecto': idProyecto.toString(),
    'usuarios': usuarios,
  };
  var body = json.encode(datos);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<String>> obtenerValoresBusqueda(
    String api, int idProyecto, int idUsuario, String tipoBusqueda) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/valores/busqueda/$idProyecto/$idUsuario');
  // Map<String, String> datos = {
  //   'tipoBusqueda': tipoBusqueda,
  // };
  // var body = json.encode(datos);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: tipoBusqueda);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> registrarInventario(
    String api, String folio, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/registrar/inventario/$folio/$idProyecto');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<EdicionAsignada>> obtenerCamposEdicion(
    String api, int idusuario, int idinventario) async {
  List<EdicionAsignada> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/ediciones/usuario/$idusuario/$idinventario');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(EdicionAsignada.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<DatosAValidar>> obtenerDatosAValidarPendientes(String api) async {
  List<DatosAValidar> lista = [];
  Uri url = Uri.parse(api + '/obtener/datosvalidar/pendiente');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(DatosAValidar.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Map<String, dynamic>>> obtenerTotalRegistrosPorProyecto(
    String api) async {
  List<Map<String, dynamic>> lista = [];
  Uri url = Uri.parse(api + '/obtener/total/registros/proyectos');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i) as Map<String, dynamic>);
    }
  }
  return lista;
}

Future<List<DatosAValidar>> obtenerDatosAValidarAsignados(String api) async {
  List<DatosAValidar> lista = [];
  Uri url = Uri.parse(api + '/obtener/match/datos/issste');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      DatosAValidar aux = DatosAValidar(
        iddatoavalidar: jsonList.elementAt(i)['iddatoavalidar'],
        dato: jsonList.elementAt(i)['dato'],
        estatus: '',
        inventario: Inventario(
            idinventario: int.parse(jsonList.elementAt(i)['idinventario'])),
        tipodedato: '',
      );
      lista.add(aux);
    }
  }
  return lista;
}

Future<String> obtenerTotalValoresAValidar(
    String api, String tipoDeDato) async {
  String respuesta = '';
  Uri url = Uri.parse(api + '/obtener/total/datosavalidar/$tipoDeDato');
  print('Obteniendo TotalValores a validar');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    respuesta = utf8.decode(response.bodyBytes);
  }
  return respuesta;
}

Future<List<String>> obtenerTiposDeDatosAValidar(String api) async {
  List<String> respuesta = [];
  Uri url = Uri.parse(api + '/obtener/tipo/datosavalidar');
  print('Obteniendo tipos de datos');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      respuesta.add(jsonList.elementAt(i));
    }
  }
  return respuesta;
}

Future<List<String>> crearRegistro(
    String api, List<ValoresCampo> valores) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/registrar/campo/valores');
  Map datos = {'valoresCampo': valores};
  var body = json.encode(datos['valoresCampo']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> crearRegistroPlantilla(
    String api, List<List<ValoresCampo>> valores) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/registrar/campo/valores/plantilla');

  Map datos = {'listaValores': valores};

  var body = json.encode(datos['listaValores']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<String> leerPantillaExcel(
    String api, List<int> documento, int idUsuario, int idProyecto) async {
  List<String> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/excel/datos/proyecto/$idUsuario/$idProyecto');
  String respuesta = '';
  Map datos = {'documento': documento};

  var body = json.encode(datos['documento']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    respuesta = response.body;
  }
  return respuesta;
}

Future<String> eliminarRegistro(
    String api, int idInventario, String password) async {
  Uri url = Uri.parse(api + '/registro/eliminar/id/$idInventario/$password');
  String respuesta = '';

  var response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    respuesta = response.body;
  }
  return respuesta;
}

Future<String> volverAGenerarDocumento(String api, int idInventario) async {
  String datos = '';
  Uri url = Uri.parse(api + '/generar/nuevo/documento/$idInventario');
  var response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    datos = response.body;
  }
  return datos;
}

Future<String> volverAGenerarDocumentosSeleccionados(
    String api, int idProyecto, List<int> listaIdInventarios) async {
  String respuesta = '';
  Uri url = Uri.parse(api + '/generar/nuevo/documento/$idProyecto');
  Map datos = {'idInventario': listaIdInventarios};
  var body = json.encode(datos['idInventario']);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    respuesta = response.body;
  }
  return respuesta;
}

Future<List<String>> crearInventarioPlantilla(
    String api, List<Inventario> registros, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/registrar/registro/plantilla/$idProyecto');

  Map datos = {'registros': registros};

  var body = json.encode(datos['registros']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<List<Agrupaciones>>> obtenerRegistrosDuplicados(
    String api, Proyecto proyecto, String dato) async {
  List<List<Agrupaciones>> lista = [];
  List<Agrupaciones> agrupaciones = [];
  Uri url = Uri.parse(
      api + '/obtener/registros/duplicados/proyecto/${proyecto.idproyecto}');

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: dato);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      agrupaciones = [];
      for (int j = 0; j < jsonList.elementAt(i).length; j++) {
        agrupaciones
            .add(Agrupaciones.fromJson(jsonList.elementAt(i).elementAt(j)));
      }
      lista.add(agrupaciones);
    }
  }
  return lista;
}

Future<List<String>> obtenerFoliosRegistrados(
    String api, List<String> folios, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/folios/registrados/$idProyecto');

  Map datos = {'folios': folios};

  var body = json.encode(datos['folios']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<FotoEvidencia>> obtenerCheckBoxEvidenciaProyecto(
    String api, Proyecto proyecto, Inventario inventario) async {
  List<FotoEvidencia> respuesta = [];
  String url = api +
      '/obtener/campos/checkboxevidencia/proyecto/${proyecto.idproyecto}/${inventario.idinventario}';
  var uri = Uri.parse(url);
  var response =
      await http.get(uri, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      respuesta.add(FotoEvidencia.fromJson(jsonList.elementAt(i)));
    }
  }
  return respuesta;
}

Future<Map<dynamic, dynamic>> obtenerDatosRegistroNuevo(
    String api, Proyecto proyecto) async {
  Map<dynamic, dynamic> respuesta = <dynamic, dynamic>{};
  Uri url = Uri.parse(api + '/obtener/datos/nuevo/registro');
  var body = json.encode(proyecto.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as Map;
    respuesta = jsonList;
  }
  return respuesta;
}

Future<Map<dynamic, dynamic>> obtenerPDFUnidos(
    String api, Proyecto proyecto, List<int> ids, String paginas) async {
  Map<dynamic, dynamic> respuesta = <dynamic, dynamic>{};
  if (paginas.isEmpty) {
    paginas = '0';
  }
  Uri url = Uri.parse(
      api + '/obtener/pdf/seleccionado/${proyecto.proyecto}/$paginas');
  Map<String, dynamic> lista = {'idRegistros': ids};
  var body = json.encode(lista['idRegistros']);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as Map;
    respuesta = jsonList;
  }
  return respuesta;
}

Future<List<String>> actualizarValoresCampos(
    String api, List<ValoresCampos> valores) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/actualizar/valores/campos');

  Map datos = {'valores': valores};

  var body = json.encode(datos['valores']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> actualizarValores(
    String api, Map<String, dynamic> datos) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/inventario/actualizar/valores');

  var body = json.encode(datos);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> asignarEdicion(
    String api, List<EdicionAsignada> listaEdicionesAsignadas) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/asignar/ediciones');

  Map datos = {'lista': listaEdicionesAsignadas};

  var body = json.encode(datos['lista']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    print(response.body);
  }
  return lista;
}

Future<List<String>> actualizarFirmas(String api, Firma firma) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/actualizar/firma/registro');

  var body = json.encode(firma.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> actualizarEvidencia(
    String api, Evidencia evidencia, int idUsuario) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/actualizar/evidencia/registro/$idUsuario');

  var body = json.encode(evidencia.toJson());

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<void> eliminarEvidencia(String api, int idInventario) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/eliminar/evidencia/registro/$idInventario');

  var response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var respuesta = response.body;
    print(respuesta);
  }
}

Future<List<String>> cambiarEstatus(String api, Estatus estatus) async {
  List<String> datos = [];
  Uri url = Uri.parse(api + '/estatus/cambiarestatus');
  var body = json.encode(estatus.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    var countR = jsonList.toList().length;

    for (int i = 0; i < countR; i++) {
      datos.add(jsonList[i]);
    }

    print(datos);
  }
  return datos;
}

Future<Pendiente?> obtenerPendienteActual(String api, int idInventario) async {
  Pendiente? respuesta;
  Uri url = Uri.parse(api + '/obtener/pendiente/$idInventario');
  var response = await http.get(url);
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error al obtener la informacion');
    final error = response.statusCode;
  } else {
    var jsonList =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    respuesta = Pendiente.fromJson(jsonList);
  }
  return respuesta;
}

Future<List<String>> obtenerUltimoIdFolio(String api) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/id/ultimo/folio');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> obtenerCamposProyectoBusqueda(
    String api, int idProyecto) async {
  List<String> lista = [];
  Uri url = Uri.parse(api + '/obtener/campos/busqueda/proyecto/$idProyecto');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<List<String>> obtenerDatosProyectoBusqueda(
    String api, int idProyecto, String tipoBusqueda) async {
  List<String> lista = [];
  Uri url = Uri.parse(
      api + '/obtener/datos/busqueda/proyecto/$idProyecto/$tipoBusqueda');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    lista.add('TODO');
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return lista;
}

Future<CatalogoRelacionado?> obtenerCatalogoRelacionado(
    String api, CatalogoRelacionado datos, int idProyecto) async {
  CatalogoRelacionado? catalogo;
  Uri url = Uri.parse(api + '/obtener/catalogorelacionado/$idProyecto');
  var body = json.encode(datos.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    catalogo = CatalogoRelacionado.fromJson(jsonList);
  }
  return catalogo;
}

Future<String?> mandarNotificacion(
    String api, Notificaciones notificaciones) async {
  String? respuesta;
  Uri url = Uri.parse(api + '/nueva/notificacion');
  var body = json.encode(notificaciones.toJson());
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    respuesta = response.body;
  }
  return respuesta;
}

Future<Uint8List> obtenerPdf(
    String api, List<Agrupaciones> lista, int idInventario) async {
  List<int> listaByte = [];
  Uri url = Uri.parse(api + '/obtener/documento/pdf/$idInventario');
  Map datos = {
    'lista': lista,
  };

  var body = json.encode(datos['lista']);
  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      listaByte.add(jsonList[i]);
    }
  }
  return Uint8List.fromList(listaByte);
}

Future<List<Agrupaciones>> obtenerCamposProyecto(
    String api, int idProyecto) async {
  List<Agrupaciones> agrupaciones = [];
  Uri url = Uri.parse(api + '/obtener/campos/proyecto/$idProyecto');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      agrupaciones.add(Agrupaciones.fromJson(jsonList.elementAt(i)));
    }
  }
  return agrupaciones;
}

Future<List<Agrupaciones>> obtenerDatosCamposRegistro(
    String api, int idProyecto, int idRegistro) async {
  List<Agrupaciones> agrupaciones = [];
  Uri url = Uri.parse(api + '/obtener/datos/registro/$idRegistro/$idProyecto');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      agrupaciones.add(Agrupaciones.fromJson(jsonList.elementAt(i)));
      print('Valor: ${jsonList.elementAt(i)['campos'].elementAt(0)['valor']}');
    }
  }
  return agrupaciones;
}

Future<Map<String, Catalogo>> obtenerCatalogosProyecto(
    String api, Proyecto proyecto) async {
  Map<String, Catalogo> catalogos = Map<String, Catalogo>();
  Uri url =
      Uri.parse(api + '/obtener/catalogos/proyecto/${proyecto.idproyecto}');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      catalogos[jsonList.elementAt(i)] =
          await obtenerDatosCatalogoCamposProyecto(
              ApiDefinition.ipServer, proyecto, jsonList.elementAt(i));
    }
  }
  return catalogos;
}

Future<Map<String, Catalogo>> obtenerCatalogosProyectoUsuario(
    String api, Proyecto proyecto, int idUsuario) async {
  Map<String, Catalogo> catalogos = Map<String, Catalogo>();
  Uri url =
      Uri.parse(api + '/obtener/catalogos/proyecto/${proyecto.idproyecto}');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      catalogos[jsonList.elementAt(i)] =
          await obtenerDatosCatalogoCamposProyectoUsuario(
              ApiDefinition.ipServer,
              proyecto,
              jsonList.elementAt(i),
              idUsuario);
    }
  }
  return catalogos;
}

Future<List<String>> obtenerCheckBoxProyecto(
    String api, Proyecto proyecto) async {
  List<String> respuesta = [];
  Uri url = Uri.parse(
      api + '/obtener/campos/checkbox/proyecto/${proyecto.idproyecto}');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      respuesta.add(jsonList.elementAt(i));
    }
  }
  return respuesta;
}

Future<http.Response> descargarAsistencia(String api) async {
  Uri url = Uri.parse(api + '/asistencia/generarReporte');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  }
  return response;
}

Future<List<Usuario>> obtenerUsuariosAsistencia(
    String api, String fechaInicio, String fechaFinal) async {
  List<Usuario> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/usuarios/asistencia/$fechaInicio/$fechaFinal');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Usuario.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<Uint8List> obtenerFirmasRegistroBytes(
    String api, int idInventario, int idCampo) async {
  List<int> lista = [];
  Uri url =
      Uri.parse(api + '/obtener/firmas/documento/byte/$idInventario/$idCampo');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return Uint8List.fromList(lista);
}

Future<Uint8List> obtenerEvidenciaRegistroBytes(
    String api, int idInventario, int idCampo, int idUsuario) async {
  List<int> lista = [];
  Uri url = Uri.parse(api +
      '/obtener/evidencia/documento/byte/$idInventario/$idCampo/$idUsuario');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }
  return Uint8List.fromList(lista);
}

Future<List<FotoEvidencia>> obtenerEvidenciaBytes(String api, String idProyecto,
    String idInventario, String idUsuario) async {
  List<FotoEvidencia> lista = [];
  Uri url = Uri.parse(api +
      '/obtener/busqueda/evidencia/byte/$idProyecto/$idInventario/$idUsuario');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(FotoEvidencia.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<FirmaDocumento>> obtenerFirmasRegistro(
    String api, int idInventario, int idCampo) async {
  List<FirmaDocumento> lista = [];
  Uri url = Uri.parse(api + '/obtener/firmas/documento/$idInventario/$idCampo');

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(FirmaDocumento.fromJson(jsonList.elementAt(i)));
    }
  }
  return lista;
}

Future<List<Asistencia>> obtenerAsistencia(
    String api, Usuario usuario, String fechaInicio, String fechaFin) async {
  List<Asistencia> asistencia = [];
  Uri url = Uri.parse(
      api + '/obtener/asistencia/${usuario.idUsuario}/$fechaInicio/$fechaFin');
  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      asistencia.add(Asistencia.fromJson(jsonList.elementAt(i)));
    }
  }
  return asistencia;
}

Future<http.Response> generarReporte(String api, List<String> dias) async {
  Uri url = Uri.parse(api + '/asistencia/generarReporte');

  Map datos = {'dias': dias};

  var body = json.encode(dias);

  var response =
      await http.get(url, headers: {"Content-Type": "application/json"});
  print('Respuesta: ${response.statusCode}');
  if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    print(jsonList);
  }
  return response;
}

Future<List<Inventario>> obtenerRegistrosDashboard(
    String api, List<String> proyectos) async {
  List<Inventario> lista = [];

  Uri url = Uri.parse(api + '/obtener/registros/dashboard');
  Map datos = {
    'proyectos': proyectos,
  };
  var body = json.encode(datos['proyectos']);

  var response = await http.post(url,
      headers: {"Content-Type": "application/json"}, body: body);
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Inventario.fromJson(jsonList.elementAt(i)));
    }
  }

  return lista;
}

Future<List<Cliente>> obtenerClientesPorUsuario(
    String api, int idclienteaplicacion) async {
  List<Cliente> lista = [];

  Uri url = Uri.parse(api + '/obtener/clientes/usuario/$idclienteaplicacion');

  var response = await http.get(
    url,
    headers: {"Content-Type": "application/json"},
  );
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Cliente.fromJson(jsonList.elementAt(i)));
    }
  }

  return lista;
}

Future<List<Proyecto>> obtenerProyecrtosPorCliente(
    String api, Cliente? clienteSeleccionado) async {
  List<Proyecto> lista = [];

  Uri url = Uri.parse(api + '/obtener/proyectos/cliente');

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(clienteSeleccionado),
  );
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(Proyecto.fromJson(jsonList.elementAt(i)));
    }
  }

  return lista;
}

Future<List<String>> nuevoCliente(String api, Cliente cliente) async {
  List<String> lista = [];

  Uri url = Uri.parse(api + '/nuevo/cliente');

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode(cliente),
  );
  print('Respuesta: ${response.statusCode}');

  if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
    print('Error en la consulta');
  } else {
    var jsonList = json.decode(utf8.decode(response.bodyBytes)) as List;
    for (int i = 0; i < jsonList.length; i++) {
      lista.add(jsonList.elementAt(i));
    }
  }

  return lista;
}
