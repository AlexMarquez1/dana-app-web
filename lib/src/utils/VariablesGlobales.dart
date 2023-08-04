import 'package:app_isae_desarrollo/src/models/Cliente.dart';
import 'package:app_isae_desarrollo/src/models/ClienteAplicacion.dart';
import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

class VariablesGlobales {
  static Usuario usuario = Usuario(
    idUsuario: 0,
    nombre: '',
    usuario: '',
    correo: '',
    jefeInmediato: '',
    passTemp: 0,
    password: '',
    perfil: Perfil(),
    status: '',
    telefono: '',
    token: '',
    ubicacion: '',
    clienteAplicacion: ClienteAplicacion(),
    vistacliente: Cliente(),
  );
}
