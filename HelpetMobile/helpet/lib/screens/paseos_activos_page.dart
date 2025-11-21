import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalle_paseo_page.dart';

class PaseosActivosPage extends StatefulWidget {
  final int paseadorId;
  const PaseosActivosPage({super.key, required this.paseadorId});

  @override
  State<PaseosActivosPage> createState() => _PaseosActivosPageState();
}

class _PaseosActivosPageState extends State<PaseosActivosPage> {
  List paseos = [];
  bool isLoading = true;
  String errorMessage = '';

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _loadPaseosActivos();
  }

  Future<void> _loadPaseosActivos() async {
    try {
      print('🔄 Cargando paseos activos para paseador: ${widget.paseadorId}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/get_paseos_activos.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'paseador_id': widget.paseadorId}),
      ).timeout(const Duration(seconds: 10));

      print('📊 Paseos Activos Response: ${response.statusCode}');
      print('📊 Paseos Activos Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          paseos = data is List ? data : [];
          isLoading = false;
        });
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando paseos activos: $e');
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'en_curso':
        return Colors.orange;
      case 'aceptado':
        return Colors.teal;
      case 'finalizado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaseoCard(Map paseo, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallePaseoPage(paseo: paseo),
            ),
          ).then((_) => _loadPaseosActivos());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorEstado(paseo['estado']).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  paseo['estado'] == 'en_curso' 
                      ? Icons.directions_walk 
                      : Icons.pending_actions,
                  color: _getColorEstado(paseo['estado']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dueño: ${paseo['dueno_nombre'] ?? 'No especificado'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mascotas: ${paseo['mascotas'] ?? 'No especificadas'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: ${_formatearFecha(paseo['fecha'])}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColorEstado(paseo['estado']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getColorEstado(paseo['estado'])),
                      ),
                      child: Text(
                        paseo['estado'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getColorEstado(paseo['estado']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tienes paseos activos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los paseos aceptados o en curso aparecerán aquí',
            textAlign: TextAlign.center,
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
            'Error al cargar paseos',
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
            onPressed: _loadPaseosActivos,
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
        title: const Text('Paseos Activos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaseosActivos,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorState()
              : paseos.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadPaseosActivos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paseos.length,
                        itemBuilder: (context, index) {
                          return _buildPaseoCard(paseos[index], index);
                        },
                      ),
                    ),
    );
  }
}