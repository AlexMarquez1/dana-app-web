import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/page/widgets/TablaUsuarios.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final _formKeyEditar = GlobalKey<FormState>();

  TextEditingController _nombre = new TextEditingController();

  TextEditingController _correo = new TextEditingController();

  TextEditingController _telefono = new TextEditingController();

  TextEditingController _ubicacion = new TextEditingController();

  TextEditingController _nombreEditar = new TextEditingController();

  TextEditingController _correoEditar = new TextEditingController();

  TextEditingController _telefonoEditar = new TextEditingController();

  TextEditingController _ubicacionEditar = new TextEditingController();

  TextEditingController _password = new TextEditingController();

  List<String> _listaEstados = [];

  List<Perfil> _listaPerfiles = [Perfil(idperfil: '0', perfil: 'Perfiles')];

  List<Usuario> _listaUsuarios = [
    Usuario(
      idUsuario: 0,
      nombre: '',
      usuario: 'Jefes',
      correo: '_correo',
      telefono: '_telefono',
      ubicacion: '_ubicacion',
      jefeInmediato: '_jefeInmediato',
      perfil: Perfil(),
      password: '_password',
      passTemp: 0,
      clienteAplicacion: ClienteAplicacion(),
      status: '',
      token: '',
      vistacliente: Cliente(),
    )
  ];

  List<Usuario> _tablaUsuarios = [];

  Perfil _perfilSeleccionado = Perfil(idperfil: '0', perfil: 'Perfiles');

  Usuario _usuarioSeleccionado = Usuario(
    idUsuario: 0,
    nombre: '',
    usuario: 'Jefes',
    correo: '_correo',
    telefono: '_telefono',
    ubicacion: '_ubicacion',
    jefeInmediato: '_jefeInmediato',
    perfil: Perfil(),
    password: '_password',
    passTemp: 0,
    clienteAplicacion: ClienteAplicacion(),
    status: '',
    token: '',
    vistacliente: Cliente(),
  );

  bool _ocultarPass = true;

  @override
  void dispose() {
    // _nombre.dispose();
    // _correo.dispose();
    // _telefono.dispose();
    // _ubicacion.dispose();
    // _nombreEditar.dispose();
    // _correoEditar.dispose();
    // _telefonoEditar.dispose();
    // _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      body: _contenedor(context),
      endDrawer: DrawerPrincipal(),
    );
  }

  Widget _contenedor(BuildContext context) {
    Size sizePantalla = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: sizePantalla.width,
            padding: EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                'Usuarios'.toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          _tarjeta(sizePantalla, _nuevoUsuario()),
          _tarjeta(sizePantalla, _usuariosModificar()),
        ],
      ),
    );
  }

  Widget _tarjeta(Size sizePantalla, Widget contenido) {
    return Container(
      width: sizePantalla.width * 0.8,
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

  Widget _usuariosModificar() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            Center(
              child: Column(
                children: [
                  // Padding(
                  //   padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  //   child: Text(
                  //     'Lista de usuarios',
                  //     style: TextStyle(fontSize: 20.0),
                  //   ),
                  // ),
                  _tablaUsuarios.isEmpty
                      ? _tablaUsuariosFuture()
                      : _tablaConstruida(_tablaUsuarios),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tablaConstruida(List<Usuario> lista) {
    // return Container(
    //   margin: EdgeInsets.all(20.0),
    //   child: DataTable(
    //     showCheckboxColumn: false,
    //     columns: [
    //       DataColumn(label: Text('Nombre'.toUpperCase())),
    //       DataColumn(label: Text('Correo'.toUpperCase())),
    //       DataColumn(label: Text('Perfil'.toUpperCase())),
    //     ],
    //     rows: lista
    //         .map(
    //           (usuario) => DataRow(
    //             onSelectChanged: (seleccion) {
    //               if (seleccion) {
    //                 _limpiarCampos();
    //                 _nombreEditar.text = usuario.nombre;
    //                 _correoEditar.text = usuario.correo;
    //                 _telefonoEditar.text = usuario.telefono;
    //                 _perfilSeleccionado.perfil = usuario.perfil.perfil;
    //                 _ubicacion.text = usuario.ubicacion;
    //                 _usuarioSeleccionado.usuario = usuario.jefeInmediato;
    //                 _password.text = usuario.password;
    //                 _usuarioSeleccionadoDialogo(usuario);
    //               }
    //             },
    //             cells: [
    //               DataCell(Text(usuario.nombre)),
    //               DataCell(Text(usuario.correo)),
    //               DataCell(Text(usuario.perfil.perfil)),
    //             ],
    //           ),
    //         )
    //         .toList(),
    //   ),
    // );
    return TablaUsuarios(
      listaUsuarios: lista,
      accion: (seleccion, Usuario usuario) {
        if (seleccion) {
          _limpiarCampos();
          _nombreEditar.text = usuario.nombre!;
          _correoEditar.text = usuario.correo!;
          _telefonoEditar.text = usuario.telefono!;
          _perfilSeleccionado.perfil = usuario.perfil!.perfil;
          _ubicacion.text = usuario.ubicacion!;
          _usuarioSeleccionado.usuario = usuario.jefeInmediato;
          _password.text = usuario.password!;
          _usuarioSeleccionadoDialogo(usuario);
        }
      },
    );
  }

  Widget _tablaUsuariosFuture() {
    return FutureBuilder(
      future: _obtenerUsuarios(),
      builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapshot) {
        if (snapshot.hasData) {
          _tablaUsuarios = snapshot.data!;
          return _tablaConstruida(_tablaUsuarios);
        } else {
          return Container(
            width: 200.0,
            height: 200.0,
            margin: EdgeInsets.only(top: 100.0, bottom: 100.0),
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
            ),
          );
        }
      },
    );
  }

  _usuarioSeleccionadoDialogo(Usuario usuario) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Text("Usuario: ${usuario.nombre}")),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _limpiarCampos();
                          Navigator.pop(context);
                        });
                      },
                      icon: Icon(Icons.close)),
                ],
              ),
            ),
            children: <Widget>[
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return _formularioEditar(setState, usuario);
                },
              ),
            ],
          );
        });
  }

  Widget _formularioEditar(StateSetter actualizacion, Usuario us) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          return Form(
            key: _formKeyEditar,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nombre',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa el nombre';
                                  }
                                  return null;
                                },
                                controller: _nombreEditar,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Nombre'),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Correo',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: TextFormField(
                                validator: (value) {
                                  bool emailValid = RegExp(
                                          r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                      .hasMatch(value!);
                                  if (emailValid) {
                                    print(value.split('@')[1]);
                                    return null;
                                  } else {
                                    return 'Ingresa un correo valido';
                                  }
                                },
                                controller: _correoEditar,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Correo'),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Telefono',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa el telefono';
                                  }
                                  return null;
                                },
                                controller: _telefonoEditar,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Telefono'),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Contraseña',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: TextFormField(
                                obscureText: _ocultarPass,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa la contraseña';
                                  }
                                  return null;
                                },
                                controller: _password,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          if (_ocultarPass) {
                                            _ocultarPass = false;
                                          } else {
                                            _ocultarPass = true;
                                          }
                                          actualizacion(() {});
                                        },
                                        icon: Icon(_ocultarPass
                                            ? Icons.visibility_off
                                            : Icons.visibility)),
                                    border: OutlineInputBorder(),
                                    hintText: 'Contraseña'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perfil',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: _perfilSeleccion(_listaPerfiles),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Ubicacion',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              width: box.maxWidth / 3,
                              child: _autoCompletar(),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Jefe Inmediato',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: _usuarioSeleccion(_listaUsuarios)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeyEditar.currentState!.validate()) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white, width: 3),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning),
                                        Container(child: Text("Mensaje")),
                                      ],
                                    ),
                                    children: <Widget>[
                                      Center(
                                        child: Container(
                                            margin: EdgeInsets.all(30.0),
                                            child: Text(
                                                'Estas seguro de guardar los cambios'
                                                    .toUpperCase())),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding: EdgeInsets.only(
                                                    top: 10.0, right: 10.0),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    for (int i = 0;
                                                        i <
                                                            _listaPerfiles
                                                                .length;
                                                        i++) {
                                                      if (_listaPerfiles
                                                              .elementAt(i)
                                                              .perfil ==
                                                          _perfilSeleccionado
                                                              .perfil) {
                                                        _perfilSeleccionado =
                                                            _listaPerfiles
                                                                .elementAt(i);
                                                      }
                                                    }

                                                    print(
                                                        'Perfil seleccionado: ${_perfilSeleccionado.perfil}');
                                                    print(
                                                        'IdPerfil seleccionado: ${_perfilSeleccionado.idperfil}');

                                                    Usuario usuario = new Usuario(
                                                        idUsuario: us.idUsuario,
                                                        nombre:
                                                            _nombreEditar.text,
                                                        usuario: us.usuario,
                                                        correo:
                                                            _correoEditar.text,
                                                        telefono:
                                                            _telefonoEditar
                                                                .text,
                                                        ubicacion:
                                                            _ubicacion.text,
                                                        jefeInmediato:
                                                            _usuarioSeleccionado
                                                                .usuario,
                                                        perfil:
                                                            _perfilSeleccionado,
                                                        password:
                                                            _password.text,
                                                        passTemp: us.passTemp,
                                                        token: '',
                                                        clienteAplicacion: us
                                                            .clienteAplicacion,
                                                        status: us.status,
                                                        vistacliente:
                                                            us.vistacliente);
                                                    PantallaDeCarga.loadingI(
                                                        context, true);

                                                    await editarUsuario(
                                                        ApiDefinition.ipServer,
                                                        usuario);
                                                    PantallaDeCarga.loadingI(
                                                        context, false);
                                                    _tablaUsuarios = [];
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    _limpiarCampos();
                                                    setState(() {});
                                                  },
                                                  child: Text('Aceptar'),
                                                )),
                                            Container(
                                                padding: EdgeInsets.only(
                                                    top: 10.0, right: 10.0),
                                                alignment:
                                                    Alignment.centerRight,
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
                        },
                        child: Text('Editar'),
                      ),
                      SizedBox(
                        width: 30.0,
                      ),
                      // ElevatedButton(
                      //   style: ButtonStyle(
                      //     backgroundColor:
                      //         MaterialStateProperty.all<Color>(Colors.red),
                      //   ),
                      //   onPressed: () {
                      //     showDialog(
                      //         context: context,
                      //         builder: (context) {
                      //           return SimpleDialog(
                      //             shape: RoundedRectangleBorder(
                      //                 side: BorderSide(
                      //                     color: Colors.white, width: 3),
                      //                 borderRadius: BorderRadius.all(
                      //                     Radius.circular(15))),
                      //             title: Row(
                      //               children: [
                      //                 Icon(Icons.warning),
                      //                 SizedBox(
                      //                   width: 10.0,
                      //                 ),
                      //                 Container(child: Text("Mensaje")),
                      //               ],
                      //             ),
                      //             children: <Widget>[
                      //               Center(
                      //                 child: Container(
                      //                     margin: EdgeInsets.all(30.0),
                      //                     child: Text(
                      //                         'Estas seguro de eliminar a: ${_nombreEditar.text}'
                      //                             .toUpperCase())),
                      //               ),
                      //               Container(
                      //                 margin: EdgeInsets.only(left: 20.0),
                      //                 child: Row(
                      //                   children: [
                      //                     Container(
                      //                         padding: EdgeInsets.only(
                      //                             top: 10.0, right: 10.0),
                      //                         alignment: Alignment.centerRight,
                      //                         child: ElevatedButton(
                      //                           onPressed: () async {
                      //                             PantallaDeCarga.loadingI(
                      //                                 context, true);
                      //                             await eliminarUsuario(
                      //                                 ApiDefinition.ipServer,
                      //                                 us);
                      //                             Navigator.pop(context);
                      //                             Navigator.pop(context);
                      //                             PantallaDeCarga.loadingI(
                      //                                 context, false);
                      //                             _tablaUsuarios = [];
                      //                             setState(() {});
                      //                           },
                      //                           child: Text('Aceptar'),
                      //                         )),
                      //                     Container(
                      //                         padding: EdgeInsets.only(
                      //                             top: 10.0, right: 10.0),
                      //                         alignment: Alignment.centerRight,
                      //                         child: ElevatedButton(
                      //                           onPressed: () {
                      //                             Navigator.of(context).pop();
                      //                           },
                      //                           child: Text('Cancelar'),
                      //                         )),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //           );
                      //         });
                      //   },
                      //   child: Text('Eliminar usuario'),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _nuevoUsuario() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Text(
                        'Nuevo Usuario',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 50.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nombre',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el nombre';
                                    }
                                    return null;
                                  },
                                  controller: _nombre,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Nombre'),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                'Correo',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: TextFormField(
                                  validator: (value) {
                                    bool emailValid = RegExp(
                                            r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                        .hasMatch(value!);
                                    if (emailValid) {
                                      print(value.split('@')[1]);
                                      return null;
                                    } else {
                                      return 'Ingresa un correo valido';
                                    }
                                  },
                                  controller: _correo,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Correo'),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                'Telefono',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa el telefono';
                                    }
                                    return null;
                                  },
                                  controller: _telefono,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Telefono'),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 50.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perfil',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: _listaPerfiles.length == 1
                                    ? _perfiles()
                                    : _perfilSeleccion(_listaPerfiles),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                'Ubicacion',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: box.maxWidth / 3,
                                child: _listaEstados.isEmpty
                                    ? _autoCompletarFuture()
                                    : _autoCompletar(),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                'Jefe Inmediato',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  width: box.maxWidth / 3,
                                  child: _listaUsuarios.length == 1
                                      ? _usuarios()
                                      : _usuarioSeleccion(_listaUsuarios)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.only(
                  right: 100.0,
                ),
                margin: EdgeInsets.only(
                  bottom: 30.0,
                ),
                width: box.maxWidth,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Prosesando Datos')),
                      // );
                      print('Guardar usuario');
                      Usuario usuario = new Usuario(
                        idUsuario: 0,
                        nombre: _nombre.text,
                        usuario: _correo.text.split('@')[0],
                        correo: _correo.text,
                        telefono: _telefono.text,
                        ubicacion: _ubicacion.text,
                        jefeInmediato: _usuarioSeleccionado.usuario,
                        perfil: _perfilSeleccionado,
                        password: '12345',
                        passTemp: 1,
                        token: '',
                        clienteAplicacion:
                            VariablesGlobales.usuario.clienteAplicacion,
                        status: 'ACTIVO',
                        vistacliente: Cliente(idcliente: 0),
                      );
                      PantallaDeCarga.loadingI(context, true);
                      await crearUsuario(ApiDefinition.ipServer, usuario);
                      PantallaDeCarga.loadingI(context, false);

                      _limpiarCampos();
                      _tablaUsuarios = [];

                      setState(() {});
                    }
                  },
                  child: Text(
                    'Guardar',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _limpiarCampos() {
    _nombre.text = '';
    _correo.text = '';
    _telefono.text = '';
    _ubicacion.text = '';
    _usuarioSeleccionado = Usuario(
      idUsuario: 0,
      nombre: '',
      usuario: 'Jefes',
      correo: '_correo',
      telefono: '_telefono',
      ubicacion: '_ubicacion',
      jefeInmediato: '_jefeInmediato',
      perfil: Perfil(),
      password: '_password',
      passTemp: 0,
      status: '',
      token: '',
      clienteAplicacion: ClienteAplicacion(),
      vistacliente: Cliente(),
    );
    _perfilSeleccionado = Perfil(idperfil: '0', perfil: 'Perfiles');
  }

  Future<List<String>> _obtenerEstados() async {
    return await obtenerEstados(ApiDefinition.ipServer);
  }

  Widget _autoCompletar() {
    return Autocomplete<Object>(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (_ubicacion.text.isNotEmpty) {
          textEditingController.text = _ubicacion.text;
        }
        _ubicacion = textEditingController;
        return TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa la ubicacion';
            } else {
              bool validacion = false;
              for (String ubicacion in _listaEstados) {
                if (ubicacion == value) {
                  validacion = true;
                  break;
                }
              }
              if (validacion) {
                return null;
              } else {
                return 'Ingresa una ubicacion valida';
              }
            }
          },
          controller: _ubicacion,
          focusNode: focusNode,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Ubicacion'),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return Iterable.empty();
        } else {
          return _listaEstados.where((String opcion) {
            return opcion.contains(textEditingValue.text.toUpperCase());
          });
        }
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected onSelected, Iterable<dynamic> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 300.0,
              height: 250,
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (seleccion) {
        print(seleccion);
      },
    );
  }

  Widget _autoCompletarFuture() {
    return FutureBuilder(
      future: _obtenerEstados(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _listaEstados = snapshot.data;
          return _autoCompletar();
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  Future<List<Perfil>> _obtenerPerfiles() async {
    return await obtenerPerfiles(ApiDefinition.ipServer);
  }

  Widget _perfiles() {
    return FutureBuilder(
      future: _obtenerPerfiles(),
      builder: (BuildContext context, AsyncSnapshot<List<Perfil>> snapShot) {
        if (snapShot.hasData) {
          for (Perfil perfil in snapShot.data!) {
            _listaPerfiles.add(perfil);
          }
          return _perfilSeleccion(_listaPerfiles);
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  Widget _perfilSeleccion(List<Perfil> lista) {
    return Container(
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == 'Perfiles') {
            return 'Selecciona un perfil';
          }
          return null;
        },
        value: _perfilSeleccionado.perfil,
        onChanged: (valor) {
          for (int i = 0; i < _listaPerfiles.length; i++) {
            if (_listaPerfiles.elementAt(i).perfil == valor) {
              _perfilSeleccionado = _listaPerfiles.elementAt(i);
            }
          }
          setState(() {});
        },
        items: lista.map((item) {
          return DropdownMenuItem(
            value: item.perfil,
            child: Text(item.perfil!),
          );
        }).toList(),
      ),
    );
  }

  Future<List<Usuario>> _obtenerUsuarios() async {
    return await obtenerUsuarios(ApiDefinition.ipServer);
  }

  Widget _usuarios() {
    return FutureBuilder(
      future: _obtenerUsuarios(),
      builder: (BuildContext context, AsyncSnapshot<List<Usuario>> snapShot) {
        if (snapShot.hasData) {
          for (Usuario usuario in snapShot.data!) {
            _listaUsuarios.add(usuario);
          }
          return _usuarioSeleccion(_listaUsuarios);
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }

  Widget _usuarioSeleccion(List<Usuario> lista) {
    return Container(
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == 'Jefes') {
            return 'Selecciona un jefe';
          }
          return null;
        },
        value: _usuarioSeleccionado.usuario,
        onChanged: (valor) {
          for (int i = 0; i < _listaUsuarios.length; i++) {
            if (_listaUsuarios.elementAt(i).usuario == valor) {
              _usuarioSeleccionado = _listaUsuarios.elementAt(i);
              break;
            }
          }
          setState(() {});
        },
        items: lista.map((item) {
          return DropdownMenuItem(
            value: item.usuario,
            child: Text(
              item.usuario!,
              style: TextStyle(fontSize: 15.0),
            ),
          );
        }).toList(),
      ),
    );
  }
}
