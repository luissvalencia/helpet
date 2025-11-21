import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SolicitudesPaseosPage extends StatefulWidget {
  final int userId;
  final int paseadorId;
  const SolicitudesPaseosPage({required this.userId, required this.paseadorId, super.key});

  @override
  _SolicitudesPaseosPageState createState() => _SolicitudesPaseosPageState();
}

class _SolicitudesPaseosPageState extends State<SolicitudesPaseosPage> {
  List<Map<String, dynamic>> mascotas = [];
  List<int> selectedMascotas = [];
  DateTime selectedFecha = DateTime.now();
  TimeOfDay selectedHora = TimeOfDay.now();
  bool _isLoading = false;
  bool _loadingMascotas = true;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    fetchMascotas();
  }

  Future<void> fetchMascotas() async {
    try {
      print('🔄 Cargando mascotas para usuario: ${widget.userId}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/get_mascotas.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': widget.userId}),
      ).timeout(const Duration(seconds: 10));

      print('📊 Mascotas Response: ${response.statusCode}');
      print('📊 Mascotas Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          mascotas = List<Map<String, dynamic>>.from(data);
          _loadingMascotas = false;
        });
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando mascotas: $e');
      setState(() => _loadingMascotas = false);
      _showSnackbar('Error cargando mascotas: $e', Colors.red);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedFecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedFecha) {
      setState(() => selectedFecha = picked);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedHora,
    );
    if (picked != null && picked != selectedHora) {
      setState(() => selectedHora = picked);
    }
  }

  Future<void> solicitarPaseo() async {
    if (selectedMascotas.isEmpty) {
      _showSnackbar('Selecciona al menos una mascota.', Colors.orange);
      return;
    }

    if (selectedFecha.isBefore(DateTime.now())) {
      _showSnackbar('La fecha no puede ser en el pasado.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fechaCompleta = DateTime(
        selectedFecha.year,
        selectedFecha.month,
        selectedFecha.day,
        selectedHora.hour,
        selectedHora.minute,
      );

      print('📤 Enviando solicitud de paseo...');
      print('📤 Usuario: ${widget.userId}, Paseador: ${widget.paseadorId}');
      print('📤 Mascotas: $selectedMascotas');
      print('📤 Fecha: $fechaCompleta');

      final response = await http.post(
        Uri.parse('$baseUrl/add_solicitud_paseo.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'paseador_id': widget.paseadorId,
          'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(fechaCompleta),
          'mascotas': selectedMascotas.join(','),
        }),
      ).timeout(const Duration(seconds: 15));

      print('📥 Solicitud Response: ${response.statusCode}');
      print('📥 Solicitud Body: ${response.body}');

      final data = json.decode(response.body);
      
      _showSnackbar(
        data['message'], 
        data['success'] == true ? Colors.green : Colors.red
      );

      if (data['success'] == true) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error enviando solicitud: $e');
      _showSnackbar('Error de conexión: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildMascotaItem(Map<String, dynamic> mascota) {
    int mascotaId = int.tryParse(mascota['id']?.toString() ?? '0') ?? 0;
    String nombre = mascota['nombre'] ?? 'Sin nombre';
    String especie = mascota['especie'] ?? '';
    String raza = mascota['raza'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          [especie, if (raza.isNotEmpty) raza].where((e) => e.isNotEmpty).join(' - '),
          style: const TextStyle(fontSize: 12),
        ),
        value: selectedMascotas.contains(mascotaId),
        onChanged: (val) {
          setState(() {
            if (val == true) {
              selectedMascotas.add(mascotaId);
            } else {
              selectedMascotas.remove(mascotaId);
            }
          });
        },
        secondary: const Icon(Icons.pets, color: Colors.teal),
      ),
    );
  }

  Widget _buildEmptyMascotas() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tienes mascotas registradas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Registra tus mascotas primero para solicitar paseos',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Paseo'), 
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: _loadingMascotas
          ? const Center(child: CircularProgressIndicator())
          : mascotas.isEmpty
              ? _buildEmptyMascotas()
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona tus mascotas para el paseo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mascotas seleccionadas: ${selectedMascotas.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: mascotas.length,
                          itemBuilder: (context, index) {
                            return _buildMascotaItem(mascotas[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text(
                                'Fecha y Hora del Paseo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Fecha:', style: TextStyle(color: Colors.grey)),
                                      Text(DateFormat('dd/MM/yyyy').format(selectedFecha)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Hora:', style: TextStyle(color: Colors.grey)),
                                      Text(selectedHora.format(context)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.calendar_today, color: Colors.teal),
                                      label: const Text('Cambiar fecha'),
                                      onPressed: () => _seleccionarFecha(context),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.access_time, color: Colors.teal),
                                      label: const Text('Cambiar hora'),
                                      onPressed: () => _seleccionarHora(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : solicitarPaseo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Solicitar Paseo',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}