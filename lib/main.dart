import 'package:app_isae_desarrollo/src/page/AsignacionesPage.dart';
import 'package:app_isae_desarrollo/src/page/AsistenciaPage.dart';
import 'package:app_isae_desarrollo/src/page/BalancePage.dart';
import 'package:app_isae_desarrollo/src/page/CamposProyecto.dart';
import 'package:app_isae_desarrollo/src/page/CatalogoPage.dart';
import 'package:app_isae_desarrollo/src/page/DashboardPage.dart';
import 'package:app_isae_desarrollo/src/page/Duplicidad.dart';
import 'package:app_isae_desarrollo/src/page/InicioPage.dart';
import 'package:app_isae_desarrollo/src/page/NotificacionesPage.dart';
import 'package:app_isae_desarrollo/src/page/ProyectosPage.dart';
import 'package:app_isae_desarrollo/src/page/RegistrosPage.dart';
import 'package:app_isae_desarrollo/src/page/UsuariosPage.dart';
import 'package:app_isae_desarrollo/src/page/loginPage.dart';
import 'package:app_isae_desarrollo/src/providers/duplicadosProvider.dart';
import 'package:app_isae_desarrollo/src/providers/evidenciaSeleccionadaProvider.dart';
import 'package:app_isae_desarrollo/src/providers/notificacionProbider.dart';
import 'package:app_isae_desarrollo/src/providers/registroProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:firebase/firebase.dart';

void main() {
  if (apps.isEmpty) {
    initializeApp(
      apiKey: "AIzaSyDYsaRLxNsjG-N2sMi5NAruxN0h6QzfkFA",
      authDomain: "isae-de6da.firebaseapp.com",
      databaseURL: "https://isae-de6da.firebaseio.com",
      projectId: "isae-de6da",
      appId: "1:972087423452:web:2a371fa79ca495c6f75f19",
      storageBucket: "isae-de6da.appspot.com",
    );
  }
  runApp(AppState());
}

class AppState extends StatelessWidget {
  const AppState({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => EvidenciaSeleccionadaProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => NotificacionProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => RegistroProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => DuplicadosProvider(),
          lazy: false,
        )
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [
        const Locale('en', 'US'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Isae app',
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget),
        //maxWidth: 1200,
        minWidth: 700,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.resize(700, name: MOBILE, scaleFactor: 0.5),
          ResponsiveBreakpoint.autoScale(800, name: TABLET, scaleFactor: 0.5),
          ResponsiveBreakpoint.autoScale(1000, name: DESKTOP, scaleFactor: 0.5),
          ResponsiveBreakpoint.autoScale(2460, name: '4K'),
        ],
        background: Container(color: Color(0xFFF5F5F5)),
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => LoginPage(),
        '/inicio': (BuildContext context) => InicioPage(),
        '/proyectos': (BuildContext context) => ProyectosPage(),
        '/usuarios': (BuildContext context) => UsuariosPage(),
        '/catalogo': (BuildContext context) => CatalogoPage(),
        '/asignaciones': (BuildContext context) => AsignacionesPage(),
        '/registros': (BuildContext context) => RegistroPage(),
        '/asistencia': (BuildContext context) => AsistenciaPage(),
        '/dashborad': (BuildContext context) => DashBoardPage(),
        '/camposproyecto': (BuildContext context) => CamposProyecto(),
        '/notificaciones': (BuildContext context) => NotificacionesPage(),
        '/duplicados': (BuildContext context) => Duplicados(),
        '/balance': (BuildContext context) => BalancePage(),
      },
    );
  }
}
