import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'seguimiento_paseo_page.dart';

class PaseosPage extends StatefulWidget {
  final int userId;
  const PaseosPage({super.key, required this.userId});

  @override
  State<PaseosPage> createState() => _PaseosPageState();
}

class _PaseosPageState extends State<PaseosPage> {
  List paseos = [];
  bool isLoading = true;
  String errorMessage = '';
  Timer? _refreshTimer;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _loadPaseos();
    // Configurar actualización automática cada 30 segundos para paseos en curso
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadPaseos(); // Recargar automáticamente
      }
    });
  }

  Future<void> _loadPaseos() async {
    try {
      print('🔍 Dueño solicitando paseos para user_id: ${widget.userId}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/get_paseos.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': widget.userId}),
      ).timeout(const Duration(seconds: 10));

      print('📡 Paseos Response: ${response.statusCode}');
      print('📡 Paseos Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (mounted) {
          setState(() {
            paseos = data is List ? data : [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando paseos: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error de conexión: $e';
          isLoading = false;
        });
      }
    }
  }

  Widget _buildEstadoChip(String estado) {
    final estadoLower = estado.toLowerCase();
    Color color;
    String texto;
    IconData icono;

    switch (estadoLower) {
      case 'en_curso':
        color = Colors.orange;
        texto = 'EN CURSO';
        icono = Icons.directions_walk;
        break;
      case 'aceptado':
        color = Colors.green;
        texto = 'ACEPTADO';
        icono = Icons.check_circle;
        break;
      case 'finalizado':
        color = Colors.blue;
        texto = 'FINALIZADO';
        icono = Icons.flag;
        break;
      case 'rechazado':
        color = Colors.red;
        texto = 'RECHAZADO';
        icono = Icons.cancel;
        break;
      case 'pendiente':
        color = Colors.amber;
        texto = 'PENDIENTE';
        icono = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        texto = estado.toUpperCase();
        icono = Icons.help;
    }

    return Chip(
      label: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      avatar: Icon(icono, size: 16, color: Colors.white),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaseoCard(Map paseo, int index) {
    final estado = (paseo['estado'] ?? 'pendiente').toString().trim();
    final estadoLower = estado.toLowerCase();
    final nombrePaseador = paseo['paseador_nombre'] ?? 'Desconocido';
    final fecha = paseo['fecha'] ?? '';
    final mascotas = (paseo['mascotas'] ?? '').toString().trim();
    final paseoId = int.tryParse(paseo['paseo_id']?.toString() ?? '0') ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: estadoLower == 'en_curso'
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con paseador y estado
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: estadoLower == 'en_curso' ? Colors.orange : Colors.teal,
                    child: const Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombrePaseador,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: $paseoId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildEstadoChip(estado),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información del paseo
              Row(
                children: [
                  const Icon(Icons.pets, size: 16, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mascotas.isEmpty ? "Sin mascotas especificadas" : mascotas,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    fecha,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Botones de acción
              if (estadoLower == 'en_curso') 
                _buildBotonesPaseoEnCurso(paseoId, nombrePaseador, mascotas)
              else if (estadoLower == 'finalizado')
                _buildInfoPaseoFinalizado()
              else if (estadoLower == 'aceptado')
                _buildInfoPaseoAceptado()
              else if (estadoLower == 'pendiente')
                _buildInfoPaseoPendiente()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonesPaseoEnCurso(int paseoId, String paseador, String mascotas) {
    return Column(
      children: [
        // Indicador de seguimiento activo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                "Seguimiento activo - GPS activo",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Botón de seguimiento
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeguimientoPaseoPage(
                    paseoId: paseoId,
                    esPaseador: false,
                    duenoNombre: "Tú",
                    mascotas: mascotas,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              "VER SEGUIMIENTO EN VIVO",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPaseoFinalizado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "Paseo completado exitosamente",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPaseoAceptado() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Text(
            "Esperando que el paseador inicie el paseo",
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPaseoPendiente() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pending_actions, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            "Solicitud pendiente de aprobación",
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes paseos registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solicita un paseo desde la pestaña "Paseadores"',
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
            onPressed: _loadPaseos,
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
        title: const Text('Mis Paseos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaseos,
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
                      onRefresh: _loadPaseos,
                      child: Column(
                        children: [
                          // Header informativo
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.teal.shade50,
                            child: Row(
                              children: [
                                const Icon(Icons.info, color: Colors.teal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tienes ${paseos.length} paseo${paseos.length == 1 ? '' : 's'} registrado${paseos.length == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      color: Colors.teal.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Lista de paseos
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 16),
                              itemCount: paseos.length,
                              itemBuilder: (context, index) {
                                return _buildPaseoCard(paseos[index], index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}