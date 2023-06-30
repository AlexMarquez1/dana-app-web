import 'package:animate_do/animate_do.dart';
import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Dialogos.dart';
import 'package:app_isae_desarrollo/src/page/widgets/PantallaCarga.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/Consultas.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKeyNuevoPass = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nuevoPassController = new TextEditingController();
  TextEditingController _nuevoPassRController = new TextEditingController();
  TextEditingController _usuarioController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();

  bool _nuevoIniico = false;
  bool _nuevoPass = true;
  bool _nuevoPassR = true;
  bool _ocultarPass = true;

  AnimationController _animateController;

  Usuario _usuario = Usuario(
      0, '', '', '', '', '', '', Perfil(idperfil: '', perfil: ''), '', 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tarjeta(),
    );
  }

  Widget _tarjeta() {
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 50,
          bottom: MediaQuery.of(context).size.height / 50),
      child: Center(
          child: Card(
        borderOnForeground: true,
        elevation: 20,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white, width: 3),
        ),
        child: Container(
          width: 600.0,
          height: MediaQuery.of(context).size.height,
          child: _nuevoIniico
              ? FadeInLeft(
                  child: _primerLogin(),
                )
              : FadeOutLeft(
                  controller: (controller) => _animateController = controller,
                  child: _login(),
                ),
        ),
      )),
    );
  }

  Widget _primerLogin() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
      return SingleChildScrollView(
        child: Form(
          key: _formKeyNuevoPass,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30.0),
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      _nuevoIniico = false;
                      setState(() {});
                    },
                    icon: Icon(Icons.arrow_back)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Text(
                  'Primer inicio de sesión',
                  style: TextStyle(fontSize: 50.0),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 50.0),
                child: ShakeAnimatedWidget(
                  enabled: true,
                  duration: Duration(seconds: 50),
                  shakeAngle: Rotation.deg(z: 180),
                  curve: Curves.linear,
                  child: Container(
                    child: Image(
                      image: AssetImage('assets/img/logo_isae.png'),
                      width: 200.0,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                margin: EdgeInsets.symmetric(horizontal: 70.0),
                width: box.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nueva contraseña',
                      style: TextStyle(fontSize: 30),
                    ),
                    TextFormField(
                      controller: _nuevoPassController,
                      obscureText: _nuevoPass,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (_nuevoPass) {
                                  _nuevoPass = false;
                                } else {
                                  _nuevoPass = true;
                                }
                                setState(() {});
                              },
                              icon: Icon(_nuevoPass
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          border: OutlineInputBorder(),
                          hintText: 'Nueva contraseña'),
                      validator: (validar) {
                        if (validar.isEmpty) {
                          return 'Ingresa una nueva contraseña';
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                      'Repetir contraseña',
                      style: TextStyle(fontSize: 30),
                    ),
                    TextFormField(
                      controller: _nuevoPassRController,
                      obscureText: _nuevoPassR,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (_nuevoPassR) {
                                  _nuevoPassR = false;
                                } else {
                                  _nuevoPassR = true;
                                }
                                setState(() {});
                              },
                              icon: Icon(_nuevoPassR
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          border: OutlineInputBorder(),
                          hintText: 'Repetir contraseña'),
                      validator: (validar) {
                        if (validar.isEmpty) {
                          return 'Repite la contraseña';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: 200.0,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKeyNuevoPass.currentState.validate()) {
                      if (_nuevoPassController.text ==
                          _nuevoPassRController.text) {
                        PantallaDeCarga.loadingI(context, true);
                        _usuario.password = _nuevoPassController.text;
                        await asignarPass(ApiDefinition.ipServer, _usuario);
                        PantallaDeCarga.loadingI(context, false);
                        Navigator.pushNamed(context, '/inicio');
                      } else {
                        Dialogos.advertencia(
                            context, 'La contraseña no coincide', _error);
                      }
                    }
                  },
                  child: Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 30.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _error() {
    Navigator.pop(context);
  }

  Widget _login() {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints box) {
      return SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 150.0),
                child: Text(
                  'Inicia Sesión',
                  style: TextStyle(fontSize: 50.0),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 50.0),
                child: ShakeAnimatedWidget(
                  enabled: true,
                  duration: Duration(seconds: 50),
                  shakeAngle: Rotation.deg(z: 180),
                  curve: Curves.linear,
                  child: Container(
                    child: Image(
                      image: AssetImage('assets/img/logo_isae.png'),
                      width: 200.0,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                margin: EdgeInsets.symmetric(horizontal: 70.0),
                width: box.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuario',
                      style: TextStyle(fontSize: 30),
                    ),
                    TextFormField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), hintText: 'Usuario'),
                      validator: (validar) {
                        if (validar.isEmpty) {
                          return 'Ingresa el usuario';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {
                        _ingresar();
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'Contraseña',
                      style: TextStyle(fontSize: 30),
                    ),
                    TextFormField(
                      controller: _passController,
                      obscureText: _ocultarPass,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (_ocultarPass) {
                                  _ocultarPass = false;
                                } else {
                                  _ocultarPass = true;
                                }
                                setState(() {});
                              },
                              icon: Icon(_ocultarPass
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          border: OutlineInputBorder(),
                          hintText: 'Contraseña'),
                      validator: (validar) {
                        if (validar.isEmpty) {
                          return 'Ingresa la contraseña';
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {
                        _ingresar();
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text('Olvidaste tu Contraseña?',
                            style: TextStyle(fontSize: 20.0))),
                  ],
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: 200.0,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _ingresar();
                    }
                    setState(() {});
                    //Navigator.pushNamed(context, '/inicio');
                  },
                  child: Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 30.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _ingresar() async {
    PantallaDeCarga.loadingI(context, true);
    _usuario.usuario = _usuarioController.text;
    _usuario.password = _passController.text;
    List<Usuario> usuario =
        await obtenerUsuario(ApiDefinition.ipServer, _usuario);
    PantallaDeCarga.loadingI(context, false);
    if (usuario.isEmpty) {
      Dialogos.error(context, 'Usuario o contraseña incorrectos');
    } else {
      if (usuario.elementAt(0).passTemp == 1) {
        _nuevoIniico = true;
        _animateController.forward();
        setState(() {});
      } else {
        VariablesGlobales.usuario = usuario.first;
        if (usuario.first.status == 'ACTIVO' &&
            usuario.first.perfil.idperfil != '6') {
          Navigator.pushNamed(context, '/inicio');
        } else {
          Dialogos.error(context, 'Usuario o contraseña incorrectos');
        }
      }
    }
  }
}
