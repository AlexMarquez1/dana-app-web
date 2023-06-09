import 'package:chips_input/chips_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/Perfil.dart';
import '../../models/Usuario.dart';
import '../../utils/UpperCaseTextFormatterCustom.dart';

class ListaUsuarios extends StatelessWidget {
  TextEditingController controllerUsuarios;
  List<Usuario> listaUsuarios;
  StateSetter actualizar;
  List<Usuario> usuariosSeleccionado;
  Function usuarioSeleccionadoAccion;
  Usuario usuarioSeleccionado;
  String tipoBusqueda;
  ListaUsuarios({
    Key key,
    @required this.controllerUsuarios,
    @required this.listaUsuarios,
    @required this.usuariosSeleccionado,
    @required this.actualizar,
    @required this.usuarioSeleccionadoAccion,
    @required this.tipoBusqueda,
    this.usuarioSeleccionado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tipoBusqueda == 'MULTIPLE') {
      return _usuariosMultiple(context);
    } else {
      return _usuariosSimple(context);
    }
  }

  Widget _usuariosMultiple(BuildContext context) {
    return Center(
      child: Column(children: [
        ChipsInput(
          maxChips: 3, // remove, if you like infinity number of chips
          initialValue: usuariosSeleccionado,
          findSuggestions: (String query) {
            if (query.isNotEmpty) {
              var lowercaseQuery = query.toLowerCase();
              final results = listaUsuarios.where((usuario) {
                return usuario.usuario
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    usuario.usuario.toLowerCase().contains(query.toLowerCase());
              }).toList(growable: false)
                ..sort((a, b) => a.usuario
                    .toLowerCase()
                    .indexOf(lowercaseQuery)
                    .compareTo(
                        b.usuario.toLowerCase().indexOf(lowercaseQuery)));
              return results;
            }
            return listaUsuarios;
          },
          onChanged: (data) async {
            // print(data);
            await usuarioSeleccionadoAccion(
                context, data.isEmpty ? null : data.last, data, actualizar);
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Usuarios'),
          chipBuilder: (context, state, Usuario usuario) {
            return InputChip(
              key: ObjectKey(usuario.idUsuario),
              label: Text(usuario.usuario),
              // avatar: CircleAvatar(
              //   backgroundImage: NetworkImage(profile.imageUrl),
              // ),
              onDeleted: () => state.deleteChip(usuario),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
          suggestionBuilder: (context, Usuario usuario) {
            return ListTile(
              key: ObjectKey(usuario.idUsuario),
              // leading: CircleAvatar(
              //   backgroundImage: NetworkImage(profile.imageUrl),
              // ),
              title: Text(usuario.usuario),
              subtitle: Text(usuario.nombre),
            );
          },
          optionsViewBuilder: (BuildContext context,
              void Function(Usuario) onSelected, Iterable<Usuario> options) {
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
                      Usuario option = options.elementAt(index);
                      return ListTile(
                        onTap: () async {
                          print(option.usuario);
                          onSelected(option);
                        },
                        title: Text(option.usuario),
                        subtitle: Text(option.nombre),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _usuariosSimple(BuildContext context) {
    return Autocomplete<Usuario>(
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (controllerUsuarios.text.isNotEmpty) {
          textEditingController.text = controllerUsuarios.text;
        }
        controllerUsuarios = textEditingController;
        return Container(
          width: 200.0,
          child: TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un usuario';
                } else {
                  bool validacion = false;
                  for (Usuario usuario in listaUsuarios) {
                    if (usuario.usuario == value) {
                      validacion = true;
                      break;
                    }
                  }
                  if (validacion) {
                    return null;
                  } else {
                    return 'Ingresa un usuario valido';
                  }
                }
              },
              controller: controllerUsuarios,
              focusNode: focusNode,
              decoration: InputDecoration(
                  suffixIcon: _listaUsuariosCompleta(
                      context, listaUsuarios, actualizar),
                  border: OutlineInputBorder(),
                  hintText: 'Usuarios'),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: <TextInputFormatter>[
                UpperCaseTextFormatter(),
              ],
              onFieldSubmitted: (valor) {
                onFieldSubmitted();
              }),
        );
      },
      displayStringForOption: (Usuario usuarioSeleccionado) {
        return usuarioSeleccionado.usuario.toUpperCase();
      },
      optionsViewBuilder:
          (BuildContext context, onSelected, Iterable<Usuario> options) {
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
                  Usuario option = options.elementAt(index);
                  return ListTile(
                    onTap: () async {
                      onSelected(option);
                    },
                    title: Text(option.usuario),
                  );
                },
              ),
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return Iterable.empty();
        } else {
          if (listaUsuarios.isEmpty) {
            return [
              Usuario(
                  0,
                  'SIN RESULTADOS',
                  'SIN RESULTADOS',
                  '_correo',
                  '_telefono',
                  '_ubicacion',
                  '_jefeInmediato',
                  Perfil(),
                  '_password',
                  0)
            ];
          } else {
            return listaUsuarios.where((Usuario usuario) {
              return usuario.usuario
                  .toUpperCase()
                  .contains(textEditingValue.text.toUpperCase());
            });
          }
        }
      },
      onSelected: (seleccion) async {
        if (seleccion.usuario == 'SIN RESULTADOS') {
          controllerUsuarios.text = '';
          actualizar(() {});
        } else {
          print('Se a seleccionado: ${seleccion.usuario}');
          // _controllerUsuarios.text = seleccion.usuario;
          usuarioSeleccionado = seleccion;
          await usuarioSeleccionadoAccion(
              context, usuarioSeleccionado, actualizar);
        }
      },
    );
  }

  Widget _listaUsuariosCompleta(BuildContext context,
      List<Usuario> listaUsuarios, StateSetter actualizar) {
    return PopupMenuButton(
      color: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_sharp),
      offset: const Offset(0, 50),
      onSelected: (value) async {
        for (Usuario usuario in listaUsuarios) {
          if (usuario.usuario.toUpperCase() == value) {
            controllerUsuarios.text = value;
            usuarioSeleccionado = usuario;
            await usuarioSeleccionadoAccion(
                context, usuarioSeleccionado, actualizar);
            break;
          }
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<Object>> list = [];
        for (Usuario usuario in listaUsuarios) {
          list.add(
            PopupMenuItem(
              child: Text(usuario.usuario.toUpperCase()),
              value: usuario.usuario.toUpperCase(),
            ),
          );
        }

        return list;
      },
    );
  }
}
