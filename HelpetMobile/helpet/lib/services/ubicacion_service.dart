import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class UbicacionService {
  static final UbicacionService _instance = UbicacionService._internal();
  factory UbicacionService() => _instance;
  UbicacionService._internal();

  Timer? _timer;
  StreamController<Map<String, dynamic>> _ubicacionStreamController = 
      StreamController<Map<String, dynamic>>.broadcast();
  StreamController<LatLng> _posicionMapaStreamController = 
      StreamController<LatLng>.broadcast();

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  Stream<Map<String, dynamic>> get ubicacionStream => _ubicacionStreamController.stream;
  Stream<LatLng> get posicionMapaStream => _posicionMapaStreamController.stream;

  // Iniciar seguimiento de ubicación
  void iniciarSeguimiento(int paseoId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_ubicacionStreamController.isClosed) {
        timer.cancel();
        return;
      }
      await _obtenerUbicacionActual(paseoId);
    });
    
    // Obtener ubicación inmediatamente al iniciar
    _obtenerUbicacionActual(paseoId);
  }

  // Detener seguimiento
  void detenerSeguimiento() {
    _timer?.cancel();
    _timer = null;
  }

  // Obtener ubicación actual del servidor
  Future<void> _obtenerUbicacionActual(int paseoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_ubicacion_paseo.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'paseo_id': paseoId}),
      ).timeout(const Duration(seconds: 10));

      print('📍 Ubicación Response: ${response.statusCode}');
      print('📍 Ubicación Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['ubicacion'] != null) {
          final ubicacion = data['ubicacion'];
          
          if (!_ubicacionStreamController.isClosed) {
            _ubicacionStreamController.add(ubicacion);
            
            // Convertir a LatLng para el mapa
            final latLng = LatLng(
              double.parse(ubicacion['latitud'].toString()),
              double.parse(ubicacion['longitud'].toString()),
            );
            
            if (!_posicionMapaStreamController.isClosed) {
              _posicionMapaStreamController.add(latLng);
            }
          }
        } else {
          print('⚠️ No hay ubicación disponible: ${data['message']}');
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
    }
  }

  // Obtener historial de ubicaciones para trazar ruta
  static Future<List<LatLng>> obtenerHistorialUbicaciones(int paseoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_historial_ubicacion.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'paseo_id': paseoId}),
      ).timeout(const Duration(seconds: 10));

      print('🔄 Historial Response: ${response.statusCode}');
      print('🔄 Historial Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['historial'] != null) {
          List<LatLng> puntos = [];
          for (var ubicacion in data['historial']) {
            puntos.add(LatLng(
              double.parse(ubicacion['latitud'].toString()),
              double.parse(ubicacion['longitud'].toString()),
            ));
          }
          print('✅ Historial cargado: ${puntos.length} puntos');
          return puntos;
        }
      }
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
    }
    return [];
  }

  // Actualizar ubicación (para el paseador)
  static Future<bool> actualizarUbicacion({
    required int paseoId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      print('📍 Enviando ubicación: $latitud, $longitud para paseo: $paseoId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/update_ubicacion_paseo.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paseo_id': paseoId,
          'latitud': latitud,
          'longitud': longitud,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📤 Update Ubicación Response: ${response.statusCode}');
      print('📤 Update Ubicación Body: ${response.body}');

      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        print('✅ Ubicación actualizada correctamente');
        return true;
      } else {
        print('❌ Error en respuesta: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('❌ Error actualizando ubicación: $e');
      return false;
    }
  }

  void dispose() {
    _timer?.cancel();
    if (!_ubicacionStreamController.isClosed) {
      _ubicacionStreamController.close();
    }
    if (!_posicionMapaStreamController.isClosed) {
      _posicionMapaStreamController.close();
    }
  }
}