import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'ubicacion_service.dart';
import 'dart:async'; // ¡Falta esta importación!
class BackgroundUbicacionService {
  static final BackgroundUbicacionService _instance = BackgroundUbicacionService._internal();
  factory BackgroundUbicacionService() => _instance;
  BackgroundUbicacionService._internal();

  StreamSubscription<Position>? _positionStream;
  bool _activo = false;

  bool get estaActivo => _activo;

  // Iniciar envío automático de ubicación
  Future<void> iniciarEnvioUbicacion(int paseoId) async {
    if (_activo) return;

    // Verificar permisos
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicios de ubicación desactivados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación permanentemente denegados');
    }

    _activo = true;

    // Iniciar stream de ubicación
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10, // metros
        timeLimit: Duration(seconds: 30),
      ),
    ).listen((Position position) async {
      final success = await UbicacionService.actualizarUbicacion(
        paseoId: paseoId,
        latitud: position.latitude,
        longitud: position.longitude,
      );

      if (!success) {
        print('Error enviando ubicación al servidor');
      }
    }, onError: (error) {
      print('Error en stream de ubicación: $error');
    });
  }

  // Detener envío de ubicación
  void detenerEnvioUbicacion() {
    _positionStream?.cancel();
    _positionStream = null;
    _activo = false;
  }
}