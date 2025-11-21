import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // 🔽 IMPORT FALTANTE PARA TIMER
import '../services/ubicacion_service.dart';

class SeguimientoPaseoPage extends StatefulWidget {
  final int paseoId;
  final bool esPaseador;
  final String? duenoNombre;
  final String? mascotas;

  const SeguimientoPaseoPage({
    super.key,
    required this.paseoId,
    this.esPaseador = false,
    this.duenoNombre,
    this.mascotas,
  });

  @override
  State<SeguimientoPaseoPage> createState() => _SeguimientoPaseoPageState();
}

class _SeguimientoPaseoPageState extends State<SeguimientoPaseoPage> {
  final UbicacionService _ubicacionService = UbicacionService();
  Map<String, dynamic>? _ultimaUbicacion;
  bool _cargando = true;
  LatLng _posicionActual = LatLng(2.444814, -76.614739); // Popayán por defecto
  List<LatLng> _historialRuta = [];
  MapController _mapController = MapController();
  Timer? _refreshTimer;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _inicializarSeguimiento();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _cargarUbicacionActual();
      }
    });
  }

  void _inicializarSeguimiento() async {
    print('🔄 Iniciando seguimiento para paseo: ${widget.paseoId}');
    print('🔍 ID recibido en SeguimientoPage: ${widget.paseoId}');
    print('🔍 Tipo de ID: ${widget.paseoId.runtimeType}');
    
    // Cargar ubicación inicial e historial
    await _cargarUbicacionActual();
    await _cargarHistorialRuta();
    
    // Configurar listeners para actualizaciones en tiempo real
    _ubicacionService.ubicacionStream.listen((ubicacion) {
      print('📍 Nueva ubicación recibida: $ubicacion');
      if (mounted) {
        setState(() {
          _ultimaUbicacion = ubicacion;
          _cargando = false;
        });
        _actualizarPosicionDesdeUbicacion(ubicacion);
      }
    });

    _ubicacionService.posicionMapaStream.listen((latLng) {
      print('🗺️ Nueva posición en mapa: $latLng');
      if (mounted) {
        _actualizarPosicionMapa(latLng);
      }
    });
  }

  Future<void> _cargarUbicacionActual() async {
    try {
      print('📡 Cargando ubicación actual...');
      final response = await http.post(
        Uri.parse('$baseUrl/get_ubicacion_paseo.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'paseo_id': widget.paseoId}),
      ).timeout(const Duration(seconds: 10));

      print('📡 Ubicación Response: ${response.statusCode}');
      print('📡 Ubicación Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['ubicacion'] != null) {
          final ubicacion = data['ubicacion'];
          if (mounted) {
            setState(() {
              _ultimaUbicacion = ubicacion;
              _posicionActual = LatLng(
                double.parse(ubicacion['latitud'].toString()),
                double.parse(ubicacion['longitud'].toString()),
              );
              _cargando = false;
            });
            // Mover mapa a la nueva posición
            _mapController.move(_posicionActual, 15);
          }
        } else {
          print('⚠️ No hay ubicación disponible: ${data['message']}');
          if (mounted) {
            setState(() => _cargando = false);
          }
        }
      }
    } catch (e) {
      print('❌ Error cargando ubicación actual: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _cargarHistorialRuta() async {
    try {
      print('🔄 Cargando historial de ruta...');
      final response = await http.post(
        Uri.parse('$baseUrl/get_historial_ubicacion.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'paseo_id': widget.paseoId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['historial'] is List) {
          final historial = data['historial'];
          if (mounted) {
            setState(() {
              _historialRuta = historial.map<LatLng>((punto) {
                return LatLng(
                  double.parse(punto['latitud'].toString()),
                  double.parse(punto['longitud'].toString()),
                );
              }).toList();
            });
          }
          print('✅ Historial cargado: ${_historialRuta.length} puntos');
        }
      }
    } catch (e) {
      print('❌ Error cargando historial: $e');
    }
  }

  void _actualizarPosicionDesdeUbicacion(Map<String, dynamic> ubicacion) {
    final nuevaPosicion = LatLng(
      double.parse(ubicacion['latitud'].toString()),
      double.parse(ubicacion['longitud'].toString()),
    );
    _actualizarPosicionMapa(nuevaPosicion);
  }

  void _actualizarPosicionMapa(LatLng nuevaPosicion) {
    if (!mounted) return;
    
    setState(() {
      _posicionActual = nuevaPosicion;
      // Agregar al historial si es una nueva posición
      if (_historialRuta.isEmpty || 
          _historialRuta.last.latitude != nuevaPosicion.latitude || 
          _historialRuta.last.longitude != nuevaPosicion.longitude) {
        _historialRuta.add(nuevaPosicion);
      }
    });

    // Mover el mapa a la nueva posición
    _mapController.move(nuevaPosicion, 15);
  }

  void _recargarTodo() {
    if (mounted) {
      setState(() => _cargando = true);
    }
    _cargarUbicacionActual();
    _cargarHistorialRuta();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _ubicacionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seguimiento en Tiempo Real"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargarTodo,
          ),
        ],
      ),
      body: _buildContenido(),
    );
  }

  Widget _buildContenido() {
    return Column(
      children: [
        // Información del paseo
        if (widget.duenoNombre != null || widget.mascotas != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal[50],
            child: Row(
              children: [
                const Icon(Icons.pets, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.duenoNombre != null)
                        Text(
                          'Dueño: ${widget.duenoNombre}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (widget.mascotas != null)
                        Text(
                          'Mascotas: ${widget.mascotas}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Mapa OpenStreetMap
        Expanded(
          flex: 3,
          child: _buildMapa(),
        ),

        // Panel de información
        Expanded(
          flex: 1,
          child: _buildPanelInformacion(),
        ),
      ],
    );
  }

  Widget _buildMapa() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _posicionActual,
        zoom: 15.0,
      ),
      children: [
        // Capa de tiles (calles) - OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.helpet',
        ),
        
        // Capa de marcadores
        MarkerLayer(
          markers: [
            Marker(
              point: _posicionActual,
              width: 40,
              height: 40,
              builder: (ctx) => const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
        
        // Capa de ruta (historial)
        if (_historialRuta.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _historialRuta,
                color: Colors.blue.withOpacity(0.7),
                strokeWidth: 4,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPanelInformacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔽 TEXTO ACORTADO Y CON EXPANDED
          const Expanded(
            child: Text(
              "Seguimiento en Tiempo Real", // 🔽 TEXTO MÁS CORTO
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              maxLines: 2, // 🔽 MÁXIMO 2 LÍNEAS
              overflow: TextOverflow.ellipsis, // 🔽 PUNTOS SUSPENSIVOS SI SOBRA
            ),
          ),
          const SizedBox(height: 8), // 🔽 REDUCIDO DE 12 A 8
          Row(
            children: [
              _buildInfoItem("Latitud", _posicionActual.latitude.toStringAsFixed(6)),
              const SizedBox(width: 20),
              _buildInfoItem("Longitud", _posicionActual.longitude.toStringAsFixed(6)),
            ],
          ),
          const SizedBox(height: 6), // 🔽 REDUCIDO DE 8 A 6
          if (_ultimaUbicacion != null) ...[
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey), // 🔽 ICONO MÁS PEQUEÑO
                const SizedBox(width: 4),
                Expanded( // 🔽 AGREGAR EXPANDED PARA EVITAR OVERFLOW
                  child: Text(
                    "Actualizado: ${_formatearFecha(_ultimaUbicacion!['fecha_hora'])}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis, // 🔽 PUNTOS SUSPENSIVOS SI SOBRA
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6), // 🔽 REDUCIDO DE 8 A 6
          Row(
            children: [
              Expanded( // 🔽 AGREGAR EXPANDED
                child: Text(
                  "Puntos de ruta: ${_historialRuta.length}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis, // 🔽 PUNTOS SUSPENSIVOS SI SOBRA
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // 🔽 REDUCIDO DE 8 A 4
          const Row(
            children: [
              Expanded( // 🔽 AGREGAR EXPANDED
                child: Text(
                  "Actualización automática cada 10 segundos",
                  style: TextStyle(fontSize: 10, color: Colors.green, fontStyle: FontStyle.italic),
                  overflow: TextOverflow.ellipsis, // 🔽 PUNTOS SUSPENSIVOS SI SOBRA
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }
}