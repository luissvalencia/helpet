import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SolicitudesPaseadorPage extends StatefulWidget {
  final int paseadorId;
  const SolicitudesPaseadorPage({super.key, required this.paseadorId});

  @override
  State<SolicitudesPaseadorPage> createState() => _SolicitudesPaseadorPageState();
}

class _SolicitudesPaseadorPageState extends State<SolicitudesPaseadorPage> {
  List solicitudes = [];
  bool isLoading = true;
  String errorMessage = '';

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }

  Future<void> _loadSolicitudes() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('🔄 Cargando solicitudes para paseador: ${widget.paseadorId}');
      
      final response = await http.post(
        Uri.parse("$baseUrl/get_solicitudes_paseador.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"paseador_id": widget.paseadorId}),
      ).timeout(const Duration(seconds: 10));

      print('📊 Solicitudes Response: ${response.statusCode}');
      print('📊 Solicitudes Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() => solicitudes = data);
        } else {
          setState(() => solicitudes = []);
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando solicitudes: $e');
      setState(() {
        errorMessage = 'Error de conexión: $e';
      });
      _showSnack("Error de conexión: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _actualizarEstado(int paseoId, String estado) async {
    try {
      print('🔄 Actualizando estado a: $estado para paseo: $paseoId');
      
      final response = await http.post(
        Uri.parse("$baseUrl/update_estado_paseo.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "paseo_id": paseoId,
          "estado": estado,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📤 Update Estado Response: ${response.statusCode}');
      print('📤 Update Estado Body: ${response.body}');

      final data = json.decode(response.body);
      _showSnack(data['message'] ?? 'Operación completada', 
                data['success'] == true ? Colors.green : Colors.red);

      if (data['success'] == true) {
        _loadSolicitudes(); // Recargar la lista
      }
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      _showSnack("Error al actualizar el estado: $e", Colors.red);
    }
  }

  void _showSnack(String message, [Color color = Colors.blue]) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: color,
      ));
  }

  Widget _buildSolicitudCard(Map solicitud, int index) {
    final paseoId = int.tryParse(solicitud['paseo_id']?.toString() ?? '0') ?? 0;
    final duenoNombre = solicitud['dueno_nombre'] ?? 'Dueño no especificado';
    final mascotas = solicitud['mascotas'] ?? 'No especificadas';
    final fecha = solicitud['fecha'] ?? 'Fecha no especificada';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Dueño: $duenoNombre", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.pets, color: Colors.teal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Mascotas: $mascotas"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.teal, size: 16),
                const SizedBox(width: 8),
                Text("Fecha: $fecha"),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _actualizarEstado(paseoId, 'rechazado'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Rechazar"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _actualizarEstado(paseoId, 'aceptado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Aceptar"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No tienes solicitudes pendientes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Las nuevas solicitudes aparecerán aquí 🐾",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Error al cargar solicitudes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadSolicitudes,
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
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
        title: const Text("Solicitudes de Paseo"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSolicitudes,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? _buildErrorState()
              : solicitudes.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadSolicitudes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: solicitudes.length,
                        itemBuilder: (context, index) {
                          return _buildSolicitudCard(solicitudes[index], index);
                        },
                      ),
                    ),
    );
  }
}