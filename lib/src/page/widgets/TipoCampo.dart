import 'package:app_isae_desarrollo/src/models/Agrupaciones.dart';
import 'package:flutter/material.dart';

class TipoCampo extends StatefulWidget {
  String tipoSeleccionado;
  String nombreCampo;
  List<Agrupaciones> listaAgrupaciones;
  Function actualizar;
  TipoCampo({
    Key? key,
    required this.tipoSeleccionado,
    required this.listaAgrupaciones,
    required this.nombreCampo,
    required this.actualizar,
  }) : super(key: key);

  @override
  State<TipoCampo> createState() => _TipoCampoState();
}

class _TipoCampoState extends State<TipoCampo> {
  final Map<String, bool> _opciones = {
    'ALFANUMERICO': false,
    'ALFABETICO': false,
    'NUMERICO': false,
    'CORREO': false,
    'CATALOGO': false,
    'FIRMA': false,
    'FOTO': false,
    'CALENDARIO': false,
    'CHECKBOX': false,
  };

  @override
  Widget build(BuildContext context) {
    _opciones[this.widget.tipoSeleccionado] = true;
    return _contenido();
  }

  Widget _contenido() {
    return _clips();
  }

  Widget _clips() {
    return Container(
      width: 300.0,
      child: Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10.0,
        spacing: 10.0,
        children: [
          _clip('ALFANUMERICO', _iconoTexto('ABC123')),
          _clip('ALFABETICO', _iconoTexto('ABC')),
          _clip('NUMERICO', _iconoTexto('123')),
          _clip('CORREO', _iconoTexto('@')),
          _clip(
            'CATALOGO',
            const Icon(
              Icons.view_list_rounded,
              color: Colors.black,
            ),
          ),
          _clip(
            'FIRMA',
            const Icon(
              Icons.edit,
              color: Colors.black,
            ),
          ),
          _clip(
            'FOTO',
            const Icon(
              Icons.camera_alt,
              color: Colors.black,
            ),
          ),
          _clip(
            'CALENDARIO',
            const Icon(
              Icons.calendar_today_rounded,
              color: Colors.black,
            ),
          ),
          _clip(
            'CHECKBOX',
            const Icon(
              Icons.check_box,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
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
          for (int i = 0; i < widget.listaAgrupaciones.length; i++) {
            for (int j = 0;
                j < widget.listaAgrupaciones.elementAt(i).campos!.length;
                j++) {
              if (widget.listaAgrupaciones
                      .elementAt(i)
                      .campos!
                      .elementAt(j)
                      .nombreCampo ==
                  widget.nombreCampo) {
                widget.listaAgrupaciones
                    .elementAt(i)
                    .campos!
                    .elementAt(j)
                    .tipoCampo = label;
                if (widget.listaAgrupaciones
                            .elementAt(i)
                            .campos!
                            .elementAt(j)
                            .tipoCampo ==
                        'FIRMA' ||
                    widget.listaAgrupaciones
                            .elementAt(i)
                            .campos!
                            .elementAt(j)
                            .tipoCampo ==
                        'CATALOGO') {
                  widget.listaAgrupaciones
                      .elementAt(i)
                      .campos!
                      .elementAt(j)
                      .controladorRestriccion = new TextEditingController();
                  widget.listaAgrupaciones
                      .elementAt(i)
                      .campos!
                      .elementAt(j)
                      .controladorLongitud = new TextEditingController();
                } else {
                  TextEditingController controladorRestriccion =
                      new TextEditingController();
                  TextEditingController controladorLongitud =
                      new TextEditingController();
                  controladorRestriccion.text = 'N/A';
                  controladorLongitud.text = '100';
                  widget.listaAgrupaciones
                      .elementAt(i)
                      .campos!
                      .elementAt(j)
                      .controladorRestriccion = controladorRestriccion;
                  widget.listaAgrupaciones
                      .elementAt(i)
                      .campos!
                      .elementAt(j)
                      .controladorLongitud = controladorLongitud;
                }
              }
            }
          }
          widget.tipoSeleccionado = label;
        });
        widget.actualizar();
      },
    );
  }

  Widget _iconoTexto(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10.0,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }
}
