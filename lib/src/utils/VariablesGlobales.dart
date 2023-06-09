import 'package:app_isae_desarrollo/src/models/Perfil.dart';
import 'package:app_isae_desarrollo/src/models/Usuario.dart';

class VariablesGlobales {
  static Usuario usuario = Usuario(0, '_nombre', '_usuario', '_correo',
      '_telefono', '_ubicacion', '_jefeInmediato', Perfil(), '_password', 0);
}
