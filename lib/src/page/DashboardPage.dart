import 'dart:math';

import 'package:app_isae_desarrollo/src/page/widgets/DrawerWidget.dart';
import 'package:app_isae_desarrollo/src/page/widgets/Tarjetas.dart';
import 'package:app_isae_desarrollo/src/page/widgets/appBar.dart';
import 'package:app_isae_desarrollo/src/services/APIWebService/ApiDefinitions.dart';
import 'package:app_isae_desarrollo/src/utils/VariablesGlobales.dart';
import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/APIWebService/Consultas.dart';

class DashBoardPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _listaProyectos = [];

  List<Map<String, dynamic>> _listaEstatusProyecto = [];

  double _escala = 0.9;

  String _proyectoSeleccionado = 'NINGUNO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBarPrincipal(context, _scaffoldKey),
      body: _contenido(context),
      endDrawer: DrawerPrincipal(),
    );
  }

  Widget _contenido(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _listaProyectos.isEmpty
                    ? FutureBuilder(
                        future: obtenerTotalRegistrosPorProyecto(
                            ApiDefinition.ipServer),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            _listaProyectos = snapshot.data;
                            return _graficaPorProyectos(
                                context, _listaProyectos);
                          } else {
                            return Container(
                                width: size.width * 0.6,
                                height: 10.0,
                                child: LinearProgressIndicator());
                          }
                        })
                    : _graficaPorProyectos(context, _listaProyectos),
              ],
            ),
          ),
          _proyectoSeleccionado == 'NINGUNO'
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatefulBuilder(builder:
                        ((BuildContext context, StateSetter actualizar) {
                      return _graficaProyecto(
                          context, _listaEstatusProyecto, actualizar);
                    })),
                  ],
                ),
        ],
      ),
    );
  }

  int touchedIndex = -1;

  Widget _graficaProyecto(BuildContext context,
      List<Map<String, dynamic>> datos, StateSetter actualizar) {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        for (Map<String, dynamic> item in datos)
          StatefulBuilder(
              builder: (BuildContext context, StateSetter actualizar) {
            return _tarjetaDatos(item['domain'], item['measure'], actualizar,
                _devolverColor(item['domain']));
          }),
        _tarjetaDatos('Total', 1233, actualizar, Colors.black),
        Transform.scale(
          scale: 2,
          child: Container(
            width: 560.0,
            height: 300.0,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                    pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      actualizar(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection.touchedSectionIndex;
                      });
                    }),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(datos)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _devolverColor(String estatus) {
    Color respuesta = Color.fromRGBO(36, 90, 149, 1);
    switch (estatus) {
      case 'NUEVO':
        respuesta = Colors.grey;
        break;
      case 'ASIGNADO':
        respuesta = Colors.blue;
        break;
      case 'PENDIENTE':
        respuesta = Colors.yellow;
        break;
      case 'EN PROCESO':
        respuesta = Colors.orange;
        break;
      case 'CERRADO':
        respuesta = Colors.green;
        break;
      default:
        respuesta = Color.fromRGBO(36, 90, 149, 1);
        break;
    }
    return respuesta;
  }

  List<PieChartSectionData> showingSections(List<Map<String, dynamic>> lista) {
    return List.generate(lista.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: _devolverColor(lista.elementAt(i)['domain']),
            value: lista.elementAt(i)['measure'],
            title: lista.elementAt(i)['measure'].toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: _devolverColor(lista.elementAt(i)['domain']),
            value: lista.elementAt(i)['measure'],
            title: lista.elementAt(i)['measure'].toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: _devolverColor(lista.elementAt(i)['domain']),
            value: lista.elementAt(i)['measure'],
            title: lista.elementAt(i)['measure'].toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: _devolverColor(lista.elementAt(i)['domain']),
            value: lista.elementAt(i)['measure'],
            title: lista.elementAt(i)['measure'].toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 4:
          return PieChartSectionData(
            color: _devolverColor(lista.elementAt(i)['domain']),
            value: lista.elementAt(i)['measure'],
            title: lista.elementAt(i)['measure'].toString(),
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _graficaPorProyectos(
      BuildContext context, List<Map<String, dynamic>> datos) {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        Container(
          width: 560.0,
          height: 300.0,
          child: DChartPie(
            labelFontSize: 15,
            strokeWidth: 5,
            data: datos,
            fillColor: (pieData, index) {
              return Color.fromRGBO(36, 90, 149, 1);
            },
            animate: true,
            pieLabel: (barValue, index) {
              return "${barValue['domain'].toString()}: ${barValue['measure']}";
            },
            labelPosition: PieLabelPosition.outside,
          ),
          // DChartBar(
          //   data: [
          //     {
          //       'id': 'Bar',
          //       'data': [
          //         {'domain': '2020', 'measure': 3},
          //         {'domain': '2021', 'measure': 4},
          //         {'domain': '2022', 'measure': 6},
          //         {'domain': '2023', 'measure': 0.3},
          //       ],
          //     },
          //   ],
          //   domainLabelPaddingToAxisLine: 16,
          //   axisLineTick: 2,
          //   axisLinePointTick: 2,
          //   axisLinePointWidth: 10,
          //   axisLineColor: Colors.green,
          //   measureLabelPaddingToAxisLine: 10,
          //   barColor: (barData, index, id) => Colors.green,
          //   showBarValue: true,
          //   animate: true,
          //   measureLabelColor: Colors.black,
          //   barValue: (barValue, index) {
          //     return barValue['measure'].toString();
          //   },
          // ),
        ),
        Container(
          width: size.width * 0.45,
          height: 500.0,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              for (Map<String, dynamic> item in _listaProyectos)
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter actualizar) {
                  return Transform.scale(
                    scale: _escala,
                    child: InkWell(
                      onTap: () {},
                      child: MouseRegion(
                        onHover: (_) {
                          actualizar(() {
                            _escala = 1;
                          });
                        },
                        onExit: (_) {
                          actualizar(() {
                            _escala = 0.9;
                          });
                        },
                        child: _tarjetaDatos(item['domain'], item['measure'],
                            actualizar, Color.fromRGBO(36, 90, 149, 1)),
                      ),
                    ),
                  );
                })
            ],
          ),

          // Wrap(
          //   spacing: 10.0,
          //   runSpacing: 5.0,
          //   children: [
          //     for (Map<String, dynamic> item in _listaProyectos)
          //       StatefulBuilder(
          //           builder: (BuildContext context, StateSetter actualizar) {
          //         return Transform.scale(
          //           scale: _escala,
          //           child: InkWell(
          //             onTap: () {},
          //             child: MouseRegion(
          //               onHover: (_) {
          //                 actualizar(() {
          //                   _escala = 1;
          //                 });
          //               },
          //               onExit: (_) {
          //                 actualizar(() {
          //                   _escala = 0.9;
          //                 });
          //               },
          //               child: _tarjetaDatos(item['domain'], item['measure'],
          //                   actualizar, Color.fromRGBO(36, 90, 149, 1)),
          //             ),
          //           ),
          //         );
          //       })
          //   ],
          // ),
        ),
      ],
    );
  }

  Widget _tarjetaDatos(
      String nombre, int cantidad, StateSetter actualizar, Color color) {
    return Transform.scale(
      scale: 0.95,
      child: Container(
        width: 200.0,
        height: 200.0,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 5.0, color: color),
            left: BorderSide(width: 5.0, color: color),
            right: BorderSide(width: 5.0, color: color),
            top: BorderSide(width: 5.0, color: color),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              nombre,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$cantidad',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
