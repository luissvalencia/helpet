import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'solicitudes_paseos_page.dart';

class PaseadoresPage extends StatefulWidget {
  final int userId;

  const PaseadoresPage({super.key, required this.userId});

  @override
  State<PaseadoresPage> createState() => _PaseadoresPageState();
}

class _PaseadoresPageState extends State<PaseadoresPage> {
  List paseadores = [];
  bool isLoading = true;
  String errorMessage = '';

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _loadPaseadores();
  }

  Future<void> _loadPaseadores() async {
    try {
      print('🔄 Cargando paseadores...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get_paseadores.php'),
      ).timeout(const Duration(seconds: 10));

      print('📊 Paseadores Response: ${response.statusCode}');
      print('📊 Paseadores Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          paseadores = data is List ? data : [];
          isLoading = false;
        });
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando paseadores: $e');
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildPaseadorCard(Map paseador, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          paseador['nombre'] ?? 'Paseador',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Experiencia: ${paseador['experiencia'] ?? '0'} años'),
            if (paseador['calificacion_promedio'] != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${paseador['calificacion_promedio']}'),
                ],
              ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SolicitudesPaseosPage(
                  userId: widget.userId,
                  paseadorId: int.parse(paseador['id'].toString()),
                ),
              ),
            );
          },
          child: const Text('Solicitar'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay paseadores disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Intenta más tarde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar paseadores',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadPaseadores,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paseadores Disponibles'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaseadores,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorState()
              : paseadores.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadPaseadores,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        itemCount: paseadores.length,
                        itemBuilder: (context, index) {
                          return _buildPaseadorCard(paseadores[index], index);
                        },
                      ),
                    ),
    );
  }
}