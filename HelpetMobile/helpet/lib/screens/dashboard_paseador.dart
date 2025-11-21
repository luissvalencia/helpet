import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'solicitudes_paseador_page.dart';
import 'paseos_activos_page.dart';
import 'historial_paseos_page.dart';
import 'perfil_page.dart';

class DashboardPaseadorScreen extends StatefulWidget {
  const DashboardPaseadorScreen({super.key});

  @override
  State<DashboardPaseadorScreen> createState() => _DashboardPaseadorScreenState();
}

class _DashboardPaseadorScreenState extends State<DashboardPaseadorScreen> {
  String nombre = "Paseador";
  int paseadorId = 0;
  int _selectedIndex = 0;
  bool _isLoading = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        nombre = prefs.getString('nombre') ?? "Paseador";
        paseadorId = prefs.getInt('user_id') ?? 0;
        _isLoading = false;
      });

      // ✅ AGREGAR TODAS LAS PÁGINAS INCLUYENDO HISTORIAL Y PERFIL
      _pages.addAll([
        SolicitudesPaseadorPage(paseadorId: paseadorId),
        PaseosActivosPage(paseadorId: paseadorId),
        HistorialPaseosPage(paseadorId: paseadorId),
        PerfilPage(nombreUsuario: nombre),
      ]);
    } catch (e) {
      print('❌ Error cargando datos del paseador: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (paseadorId == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('HelPet - Paseador'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar paseador',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Por favor, inicia sesión nuevamente'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                child: const Text('Volver al Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("HelPet - Bienvenido, $nombre"),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Activos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}