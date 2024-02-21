import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:app_isae_desarrollo/src/models/FotoBytes.dart';
import 'package:app_isae_desarrollo/src/models/FotoEvidencia.dart';
import 'package:app_isae_desarrollo/src/models/Notificaciones.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DetallesImagen.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/MensajeWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/MultiSeleccion.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/providers/evidenciaSeleccionadaProvider.dart';
import 'package:app_isae_desarrollo/src/providers/notificacionProbider.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NotificacionesPage extends StatefulWidget {
  NotificacionesPage({Key? key}) : super(key: key);

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Usuario>? _listaUsuarios;

  Map<int, bool> _usuarioSeleccionado = Map<int, bool>();
  final ScrollController _scrollControllerUsuarios = ScrollController();
  final ScrollController _scrollEvidencia = ScrollController();
  final TextEditingController _controllerRemitente =
      TextEditingController(text: VariablesGlobales.usuario.nombre);

  EvidenciaSeleccionadaProvider? _evidenciaSeleccionada;
  NotificacionProvider? _notificacion;

  List<DetallesImagen> _listaComponenteImagen = [];
  Map<String, bool> _opciones = {'BAJA': true, 'MEDIA': false, 'ALTA': false};

  AnimationController? _animacionEntradaController;
  AnimationController? _animacionSalidaController;

  AnimationController? _animacionEntradaMensaje;
  AnimationController? _animacionSalidaMensaje;

  String _tituloMensaje = 'Listo';
  String _contenidoMensaje =
      'Los mensajes han sido enviados satisfactoriamente';
  Color _colorMensaje = Colors.green[300]!;
  IconData _iconoMensaje = Icons.check;
  bool _bloquearBoton = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _evidenciaSeleccionada =
        Provider.of<EvidenciaSeleccionadaProvider>(context);
    _notificacion = Provider.of<NotificacionProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      endDrawer: DrawerPrincipal(),
      body: SingleChildScrollView(
        child: MediaQuery.of(context).size.width > 1600
            ? _contenidoAncho(context)
            : _contenidoLargo(context),
      ),
    );
  }

  Widget _contenidoAncho(BuildContext context) {
    Size sizePantalla = MediaQuery.of(context).size;
    // print('Tamaño de pantalla: ${sizePantalla.width}');
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: sizePantalla.width,
              padding: EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text(
                  'Notificaciones'.toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tarjeta(sizePantalla, _listaUsuariosDisponibles(),
                    sizePantalla.width * 0.5, sizePantalla.height * 0.8),
                _tarjeta(
                    sizePantalla,
                    _notificaicon(sizePantalla.width.toInt()),
                    sizePantalla.width * 0.4,
                    null),
              ],
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: MensajeWidget(
              entrada: (controller) => _animacionEntradaMensaje = controller,
              salida: (controller) => _animacionSalidaMensaje = controller,
              fnSalida: () => _animacionSalidaMensaje!.forward(),
              titulo: _tituloMensaje,
              contenido: _contenidoMensaje,
              color: _colorMensaje,
              icono: _iconoMensaje),
        ),
      ],
    );
  }

  Widget _contenidoLargo(BuildContext context) {
    Size sizePantalla = MediaQuery.of(context).size;
    // print('Tamaño de pantalla: $sizePantalla');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: sizePantalla.width,
          padding: EdgeInsets.only(top: 20.0),
          child: Center(
            child: Text(
              'Notificaciones'.toUpperCase(),
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        _tarjeta(sizePantalla, _listaUsuariosDisponibles(),
            sizePantalla.width * 0.8, sizePantalla.height * 0.4),
        _tarjeta(sizePantalla, _notificaicon(sizePantalla.width.toInt()),
            sizePantalla.width * 0.8, null),
      ],
    );
  }

  Widget _notificaicon(int ancho) {
    _listaComponenteImagen = [];
    for (FotoEvidencia item in _evidenciaSeleccionada!.evidenciaSeleccionada) {
      _listaComponenteImagen.add(
        DetallesImagen(
          evidencia: item,
          seleccionCheck: true,
          tipoComponente: 'ELIMINAR',
          anchoImagen: 100.0,
          altoImagen: 100.0,
        ),
      );
    }
    print('Ancho de la pagina: $ancho');
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
              child: Text(
                'Notificacion',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prioridad:'),
                        Wrap(
                          alignment: WrapAlignment.start,
                          runSpacing: 10.0,
                          spacing: 10.0,
                          children: [
                            _clip('BAJA',
                                Icon(Icons.keyboard_arrow_down_outlined)),
                            _clip('MEDIA', Icon(Icons.crop_square_rounded)),
                            _clip(
                                'ALTA', Icon(Icons.keyboard_arrow_up_outlined))
                          ],
                        ),
                        Row(
                          children: [
                            Text('Remitente: '),
                            _mensaje(
                                'Nombre de la persona que esta enviando la notificacion')
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: 400.0,
                          child: TextFormField(
                            enabled: false,
                            controller: _controllerRemitente,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Remitente'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Titulo notificacion: '),
                            _mensaje('Titulo descriptivo de la notificacion'),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: 400.0,
                          child: TextFormField(
                            controller: _notificacion!.tituloController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Titulo notificacion'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Contenido notificacion: '),
                            _mensaje(
                                'Contenido de la notificacion tan largo como sea necesario')
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          width: 400.0,
                          child: TextFormField(
                            controller: _notificacion!.contenidoController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Contenido notificacion'),
                            maxLines: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 400.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Evidencia: '),
                              _mensaje(
                                  'Adjunte la evidencia que sea necesaria para complementar con la informacion')
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              PantallaDeCarga.loadingI(context, true);
                              List<FotoEvidencia> listaEvidencias =
                                  await obtenerEvidenciaBytes(
                                      ApiDefinition.ipServer,
                                      'TODO',
                                      'TODO',
                                      'TODO');

                              PantallaDeCarga.loadingI(context, false);
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder:
                                          (BuildContext context, setState) {
                                        return SimpleDialog(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 30.0),
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(Icons.close)),
                                            ),
                                            MultiSeleccion(
                                              listaEvidenacia: listaEvidencias,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  });
                              setState(() {});
                            },
                            child: Text('Seleccionar Evidencia'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _evidenciaSeleccionada!.evidenciaSeleccionada.length != 0
                      ? Container(
                          // height: 470.0,
                          width: 400.0,
                          // padding: const EdgeInsets.all(20.0),
                          child: Card(
                            elevation: 1.5,
                            child: ExpansionTile(
                              maintainState: true,
                              title: Text(
                                  'Imagenes adjuntas: ${_evidenciaSeleccionada!.evidenciaSeleccionada.length}'),
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  height: 400.0,
                                  width: 700.0,
                                  child: SingleChildScrollView(
                                    controller: _scrollEvidencia,
                                    child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.center,
                                        children: _listaComponenteImagen),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
              ancho > 700 ? _vistaPrevia(ancho) : Container(),
            ],
          ),
          ancho <= 700 ? _vistaPrevia(ancho) : Container(),
        ],
      ),
    ));
  }

  Widget _clip(String label, Widget icono) {
    return InputChip(
      selected: _opciones[label]!,
      label: Text(label),
      tooltip: label,
      labelStyle:
          TextStyle(color: _opciones[label]! ? Colors.white : Colors.black),
      selectedColor: Colors.blue.withOpacity(0.8),
      avatar: CircleAvatar(
        child: icono,
        backgroundColor: Colors.white.withOpacity(0),
      ),
      backgroundColor: Colors.grey[400],
      onSelected: (seleccion) {
        setState(() {
          _opciones.forEach((key, value) {
            _opciones[key] = false;
          });
          if (seleccion) {
            _opciones[label] = seleccion;
          } else {
            _opciones[label] = true;
          }
        });
      },
    );
  }

  Widget _vistaPrevia(int ancho) {
    double margen = 0;
    double anchoImagen = 0;
    double anchoTexto = 0;
    double anchoNotificacion = 0;
    double margenTop = 0;
    double margenLeft = 0;

    switch (ancho) {
      case 2000:
        margen = 20.0;
        anchoImagen = 325.0;
        anchoNotificacion = 255;
        margenTop = 40.0;
        margenLeft = 25.0;
        anchoTexto = 150;
        break;
      case 1600:
        margen = 100.0;
        anchoImagen = 500.0;
        anchoNotificacion = 330;
        margenTop = 55.0;
        margenLeft = 37.0;
        anchoTexto = 230;
        break;
      case 700:
        margen = 10.0;
        anchoImagen = 500.0;
        anchoNotificacion = 360;
        margenTop = 60.0;
        margenLeft = 40.0;
        anchoTexto = 255;
        break;
      default:
        margen = 100.0;
        anchoImagen = 500.0;
        anchoNotificacion = 330;
        margenTop = 55.0;
        margenLeft = 37.0;
        anchoTexto = 230;
        break;
    }
    return Column(
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vista previa del dispositivo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                width: anchoImagen - 5,
                child: Text(
                  'En esta vista previa, se ofrece una idea general de cómo se mostrará tu mensaje en un dispositivo móvil. La apariencia real del mensaje varía en función del dispositivo.',
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          padding: EdgeInsets.only(left: margen),
          width: anchoImagen,
          height: 500.0,
          alignment: Alignment.topCenter,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                // left: margenLeft,
                top: margenTop,
                child: SizedBox(
                  width: anchoNotificacion,
                  height: 100.0,
                  child: BounceInDown(
                    animate: true,
                    controller: (controller) =>
                        _animacionEntradaController = controller,
                    duration: Duration(seconds: 2),
                    child: FadeOutUp(
                      controller: (controller) =>
                          _animacionSalidaController = controller,
                      animate: false,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(top: 5.0),
                                    width: anchoTexto,
                                    child: Text(
                                      _notificacion!.tituloController.text
                                                  .length ==
                                              0
                                          ? 'Titulo Notificacion'
                                          : _notificacion!
                                              .tituloController.text,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.0),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    width: anchoTexto,
                                    height: 50.0,
                                    child: Text(
                                      _notificacion!.contenidoController.text
                                                  .length ==
                                              0
                                          ? 'Contenido de la notificacion'
                                          : _notificacion!
                                              .contenidoController.text,
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 10.0),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Container(
                                width: 60.0,
                                height: 60.0,
                                color: Colors.grey[400],
                                child: _evidenciaSeleccionada!
                                            .evidenciaSeleccionada.length ==
                                        0
                                    ? Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 50,
                                      )
                                    : Image.network(
                                        _evidenciaSeleccionada!
                                            .evidenciaSeleccionada[0].url!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/img/PlantillaCelular.png',
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0.0,
                child: ElevatedButton(
                  onPressed: _bloquearBoton
                      ? null
                      : () async {
                          bool usuarioSeleccionado = false;
                          String? prioridad;

                          _opciones.forEach((key, value) {
                            if (value) {
                              prioridad = key;
                            }
                          });

                          for (Usuario usuario in _listaUsuarios!) {
                            if (_usuarioSeleccionado[usuario.idUsuario]!) {
                              usuarioSeleccionado = true;
                              break;
                            }
                          }
                          if (usuarioSeleccionado) {
                            if (_notificacion!
                                    .tituloController.text.isNotEmpty &&
                                _notificacion!
                                    .contenidoController.text.isNotEmpty) {
                              List<Usuario> listaUsuarios = [];

                              for (Usuario usuario in _listaUsuarios!) {
                                if (_usuarioSeleccionado[usuario.idUsuario]!) {
                                  listaUsuarios.add(usuario);
                                }
                              }
                              DateTime now = new DateTime.now();
                              String dia = now.day.toString();
                              String mes = now.month.toString();
                              String anio = now.year.toString();
                              String hora = now.hour.toString();
                              String minutos = now.minute.toString();
                              Map<String, String> data = {
                                'FECHA':
                                    '${dia.length == 1 ? '0$dia' : dia}-${mes.length == 1 ? '0$mes' : mes}-$anio',
                                'HORA':
                                    '${hora.length == 1 ? '0$hora' : hora}:${minutos.length == 1 ? '0$minutos' : minutos}',
                                'PRIORIDAD': prioridad!,
                                'REMITENTE': _controllerRemitente.text,
                              };

                              for (FotoEvidencia foto in _evidenciaSeleccionada!
                                  .evidenciaSeleccionada) {
                                data['${foto.idfoto}-${foto.nombrefoto}'] =
                                    foto.url!;
                              }

                              Notificaciones notificacion = Notificaciones(
                                id: 0,
                                titulo: _notificacion!.tituloController.text,
                                contenido:
                                    _notificacion!.contenidoController.text,
                                image: _evidenciaSeleccionada!
                                        .evidenciaSeleccionada.isEmpty
                                    ? ''
                                    : _evidenciaSeleccionada!
                                        .evidenciaSeleccionada[0].url,
                                data: data,
                                token: listaUsuarios,
                                imagenes: _evidenciaSeleccionada!
                                    .evidenciaSeleccionada,
                              );

                              try {
                                setState(() {
                                  _bloquearBoton = true;
                                });
                                await mandarNotificacion(
                                    ApiDefinition.ipServer, notificacion);

                                _notificacion!.tituloController.text = '';
                                _notificacion!.contenidoController.text = '';
                                _evidenciaSeleccionada!.removeAll();

                                _animacionSalidaController!.forward();

                                Future.delayed(Duration(seconds: 2), () {
                                  _animacionEntradaController!.reset();
                                  _animacionEntradaController!.forward();
                                  _animacionSalidaController!.reset();
                                  setState(() {
                                    _bloquearBoton = false;
                                    for (Usuario usuario in _listaUsuarios!) {
                                      _usuarioSeleccionado[usuario.idUsuario!] =
                                          false;
                                    }
                                  });
                                });
                                print('Datos: $data');

                                _animacionEntradaMensaje!.reset();
                                _animacionSalidaMensaje!.reset();
                                _animacionEntradaMensaje!.forward();

                                Future.delayed(Duration(seconds: 10), () {
                                  _animacionSalidaMensaje!.forward();
                                });
                              } catch (e) {
                                setState(() {
                                  _tituloMensaje = 'Error';
                                  _contenidoMensaje =
                                      'Ocurrio un error en la ejecucion, vuelve a intentarlo de nuevo mas tarde';
                                  _colorMensaje = Colors.red[300]!;
                                  _iconoMensaje = Icons.close;
                                });
                              }
                            } else {
                              Dialogos.mensaje(context,
                                  'Titulo de la notificacion o contenido no pueden estar vacios');
                            }
                          } else {
                            Dialogos.mensaje(context,
                                'Selecciona al menos un usuario para mandar la notificacion');
                          }
                        },
                  child: Text('Enviar notificacion'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mensaje(String mensaje) {
    return Tooltip(
      message: mensaje,
      textStyle: TextStyle(fontSize: 15.0, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: Icon(
        Icons.help,
        color: Colors.grey,
        size: 20.0,
      ),
    );
  }

  Future<Uint8List> _obtenerBytes(String url) async {
    http.Response respuesta = await http.get(url as Uri);

    if (respuesta.bodyBytes.isEmpty) {
      return Uint8List(0);
    } else {
      return respuesta.bodyBytes;
    }
  }

  Widget _listaUsuariosDisponibles() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        controller: _scrollControllerUsuarios,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
              child: Text(
                'Usuarios disponibles',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
            Divider(),
            _listaUsuarios == null || _listaUsuarios!.isEmpty
                ? _tablaUsuariosDisponiblesBuilder()
                : _tablaUsuariosDisponibles(),
          ],
        ),
      ),
    );
  }

  Future<List<Usuario>> _obtenerUsuarios() async {
    return await obtenerUsuariosConToken(ApiDefinition.ipServer);
  }

  Widget _tablaUsuariosDisponiblesBuilder() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 200.0,
            margin: EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: _obtenerUsuarios(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Usuario>> snapshot) {
                if (snapshot.hasData) {
                  _listaUsuarios = snapshot.data;
                  if (_usuarioSeleccionado.isEmpty) {
                    for (Usuario usuario in snapshot.data!) {
                      _usuarioSeleccionado[usuario.idUsuario!] = false;
                    }
                  }
                  return DataTable(
                    showCheckboxColumn: true,
                    columns: [
                      DataColumn(label: Text('Usuario'.toUpperCase())),
                      DataColumn(label: Text('Nombre'.toUpperCase())),
                      DataColumn(label: Text('Telefono'.toUpperCase())),
                      DataColumn(label: Text('correo'.toUpperCase())),
                    ],
                    rows: snapshot.data == null
                        ? []
                        : snapshot.data!
                            .map(
                              (usuario) => DataRow(
                                selected:
                                    _usuarioSeleccionado[usuario.idUsuario]!,
                                onSelectChanged: (seleccion) {
                                  if (seleccion!) {
                                    _usuarioSeleccionado[usuario.idUsuario!] =
                                        seleccion;
                                  } else {
                                    _usuarioSeleccionado[usuario.idUsuario!] =
                                        seleccion;
                                  }
                                  setState(() {});
                                },
                                cells: [
                                  DataCell(Text(usuario.usuario!)),
                                  DataCell(Text(usuario.nombre!)),
                                  DataCell(Text(usuario.telefono!)),
                                  DataCell(Text(usuario.correo!)),
                                ],
                              ),
                            )
                            .toList(),
                  );
                } else {
                  return Container(
                    width: 150.0,
                    height: 100.0,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _tablaUsuariosDisponibles() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 200.0,
            margin: EdgeInsets.all(20.0),
            child: DataTable(
              showCheckboxColumn: true,
              columns: [
                DataColumn(label: Text('Usuario'.toUpperCase())),
                DataColumn(label: Text('Nombre'.toUpperCase())),
                DataColumn(label: Text('Telefono'.toUpperCase())),
                DataColumn(label: Text('correo'.toUpperCase())),
              ],
              rows: _listaUsuarios == null
                  ? []
                  : _listaUsuarios!
                      .map(
                        (usuario) => DataRow(
                          selected: _usuarioSeleccionado[usuario.idUsuario]!,
                          onSelectChanged: (seleccion) {
                            if (seleccion!) {
                              _usuarioSeleccionado[usuario.idUsuario!] =
                                  seleccion;
                            } else {
                              _usuarioSeleccionado[usuario.idUsuario!] =
                                  seleccion;
                            }
                            setState(() {});
                          },
                          cells: [
                            DataCell(Text(usuario.usuario!)),
                            DataCell(Text(usuario.nombre!)),
                            DataCell(Text(usuario.telefono!)),
                            DataCell(Text(usuario.correo!)),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _tarjeta(
      Size sizePantalla, Widget contenido, double ancho, double? alto) {
    return Container(
      width: ancho,
      height: alto,
      padding: EdgeInsets.only(top: 20.0),
      margin: EdgeInsets.symmetric(horizontal: 25.0),
      child: Card(
        borderOnForeground: true,
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 3),
        ),
        child: contenido,
      ),
    );
  }
}
