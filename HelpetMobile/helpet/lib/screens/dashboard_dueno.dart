import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mascotas_page.dart';
import 'paseadores_page.dart';
import 'paseos_page.dart';
import 'perfil_page.dart';

class DashboardDueno extends StatefulWidget {
  const DashboardDueno({super.key});

  @override
  State<DashboardDueno> createState() => _DashboardDuenoState();
}

class _DashboardDuenoState extends State<DashboardDueno> {
  int _selectedIndex = 0;
  int? userId;
  String? nombreUsuario;
  bool _isLoading = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      final nombre = prefs.getString('nombre') ?? 'Usuario';

      setState(() {
        userId = id;
        nombreUsuario = nombre;
        _isLoading = false;
      });

      // Inicializamos las páginas después de cargar el userId
      _pages.addAll([
        MascotasPage(userId: userId ?? 0),
        PaseadoresPage(userId: userId ?? 0),
        PaseosPage(userId: userId ?? 0),
        PerfilPage(nombreUsuario: nombreUsuario ?? 'Usuario'),
      ]);
    } catch (e) {
      print('❌ Error cargando datos del usuario: $e');
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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('HelPet'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Por favor, inicia sesión nuevamente'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Volver al Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('HelPet - Bienvenido, $nombreUsuario'),
        backgroundColor: Colors.teal,
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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Paseadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Paseos',
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