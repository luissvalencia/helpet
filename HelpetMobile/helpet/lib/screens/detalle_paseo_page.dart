import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'seguimiento_paseo_page.dart';
import '../services/ubicacion_service.dart';

class DetallePaseoPage extends StatefulWidget {
  final Map paseo;
  const DetallePaseoPage({super.key, required this.paseo});

  @override
  State<DetallePaseoPage> createState() => _DetallePaseoPageState();
}

class _DetallePaseoPageState extends State<DetallePaseoPage> {
  bool isUpdating = false;
  late String estado;
  Timer? _ubicacionTimer;
  bool _enviandoUbicacion = false;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    estado = widget.paseo['estado'];
    if (estado == 'en_curso') {
      _iniciarEnvioUbicacion();
    }
  }

  @override
  void dispose() {
    _ubicacionTimer?.cancel();
    super.dispose();
  }

  void _iniciarEnvioUbicacion() {
    _ubicacionTimer?.cancel();
    
    // Enviar ubicación inmediatamente
    _enviarUbicacionActual();
    
    // Programar envío cada 10 segundos
    _ubicacionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _enviarUbicacionActual();
    });
  }

  Future<void> _enviarUbicacionActual() async {
    if (_enviandoUbicacion) return;
    
    _enviandoUbicacion = true;
    try {
      // Verificar permisos de ubicación
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Servicio de ubicación deshabilitado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          print('❌ Permisos de ubicación denegados');
          return;
        }
      }

      // Obtener ubicación actual
      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      );
      
      print('📍 Enviando ubicación: ${posicion.latitude}, ${posicion.longitude}');
      
      // Enviar al servidor usando UbicacionService
      bool exito = await UbicacionService.actualizarUbicacion(
        paseoId: widget.paseo['paseo_id'],
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      );
      
      if (exito) {
        print('✅ Ubicación enviada correctamente');
      } else {
        print('❌ Error enviando ubicación');
      }
    } catch (e) {
      print('❌ Error obteniendo/enviando ubicación: $e');
    } finally {
      _enviandoUbicacion = false;
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    if (isUpdating) return;
    
    setState(() => isUpdating = true);
    try {
      print('🔄 Cambiando estado a: $nuevoEstado');
      print('📤 Enviando paseo_id: ${widget.paseo['paseo_id']}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/update_estado_paseo.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paseo_id': widget.paseo['paseo_id'],
          'estado': nuevoEstado,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() => estado = nuevoEstado);

        // Manejar cambios de estado
        if (nuevoEstado == 'en_curso') {
          _iniciarEnvioUbicacion();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("📍 Paseo iniciado - Enviando ubicación...")),
            );
          }
        } else if (nuevoEstado == 'finalizado') {
          _ubicacionTimer?.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🛑 Paseo finalizado - Ubicación detenida")),
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Paseo cambiado a '$nuevoEstado'")),
          );
        }
      } else {
        String errorMsg = data['message'] ?? '❌ Error al actualizar';
        print('❌ Error del servidor: $errorMsg');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error de conexión: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Widget _buildBotonEstado() {
    if (estado == 'aceptado') {
      return ElevatedButton.icon(
        onPressed: isUpdating ? null : () => _cambiarEstado('en_curso'),
        icon: const Icon(Icons.play_arrow),
        label: const Text("Iniciar Paseo"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
      );
    } else if (estado == 'en_curso') {
      return ElevatedButton.icon(
        onPressed: isUpdating ? null : () => _cambiarEstado('finalizado'),
        icon: const Icon(Icons.flag),
        label: const Text("Finalizar Paseo"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        ),
      );
    } else if (estado == 'finalizado') {
      return const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 8),
          Text(
            "Paseo Completado",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Color _getColorEstado() {
    switch (estado) {
      case 'en_curso':
        return Colors.orange;
      case 'aceptado':
        return Colors.teal;
      case 'finalizado':
        return Colors.green;
      case 'pendiente':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Widget _buildEstadoSeguimiento() {
    if (estado == 'en_curso') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seguimiento ACTIVO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "Ubicación enviándose cada 10 segundos",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final paseo = widget.paseo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Paseo"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de información del paseo
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dueño
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          "Dueño: ${paseo['dueno_nombre']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Mascotas
                    Row(
                      children: [
                        const Icon(Icons.pets, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          "Mascotas: ${paseo['mascotas']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Fecha
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          "Fecha: ${paseo['fecha']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Estado
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.teal),
                        const SizedBox(width: 8),
                        const Text(
                          "Estado: ",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          estado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getColorEstado(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Estado de seguimiento
            _buildEstadoSeguimiento(),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Center(
              child: Column(
                children: [
                  // Botón de estado (Iniciar/Finalizar)
                  _buildBotonEstado(),
                  
                  const SizedBox(height: 20),
                  
                  // Botón de seguimiento en mapa
                  if (estado == 'en_curso' || estado == 'finalizado')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeguimientoPaseoPage(
                              paseoId: paseo['paseo_id'],
                              esPaseador: true,
                              duenoNombre: paseo['dueno_nombre'],
                              mascotas: paseo['mascotas'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text("Ver seguimiento en mapa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}