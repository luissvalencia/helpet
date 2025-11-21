import 'package:flutter/material.dart';
import 'package:helpet_app/screens/welcome_screen.dart';
import 'package:helpet_app/screens/login_screen.dart';
import 'package:helpet_app/screens/registro_selector_screen.dart';
import 'package:helpet_app/screens/registro_dueno_screen.dart';
import 'package:helpet_app/screens/registro_paseador_screen.dart';
import 'package:helpet_app/screens/dashboard_dueno.dart';
import 'package:helpet_app/screens/dashboard_paseador.dart';
import 'package:helpet_app/screens/mascotas_page.dart';
import 'package:helpet_app/screens/agregar_mascota_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HelPetApp());
}

class HelPetApp extends StatelessWidget {
  const HelPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelPet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/registro_selector': (context) => const RegistroSelectorScreen(),
        '/registro_dueno': (context) => const RegistroDuenoPage(),
        '/registro_paseador': (context) => const RegistroPaseadorPage(),
        '/dashboard_dueno': (context) => const DashboardDueno(),
        '/dashboard_paseador': (context) => const DashboardPaseadorScreen(),
        '/agregar_mascota': (context) => const AgregarMascotaPage(),
        // MascotasPage ahora recibe userId
        '/mascotas': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int?;
          if (args != null) {
            return MascotasPage(userId: args);
          } else {
            // Por seguridad, si no hay userId, redirigimos a Dashboard
            return const DashboardDueno();
          }
        },
      },
    );
  }
}
