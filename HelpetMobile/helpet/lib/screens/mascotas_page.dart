import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MascotasPage extends StatefulWidget {
  final int userId;
  const MascotasPage({super.key, required this.userId});

  @override
  State<MascotasPage> createState() => _MascotasPageState();
}

class _MascotasPageState extends State<MascotasPage> {
  List mascotas = [];
  bool isLoading = true;

  // 🔽 URL CORREGIDA - usa tu dominio de Render
  static const String baseUrl = "https://helpet-back.onrender.com";

  @override
  void initState() {
    super.initState();
    _loadMascotas();
  }

  Future<void> _loadMascotas() async {
    try {
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
          mascotas = data is List ? data : [];
          isLoading = false;
        });
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando mascotas: $e');
      setState(() => isLoading = false);
      _showErrorSnackbar('Error al cargar mascotas: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ✅ MÉTODO PARA AGREGAR MASCOTA
  void _agregarMascota() {
    showDialog(
      context: context,
      builder: (context) => AddMascotaDialog(
        userId: widget.userId,
        onMascotaAdded: () {
          _loadMascotas(); // Recargar la lista
          _showSuccessSnackbar('Mascota agregada correctamente');
        },
      ),
    );
  }

  // ✅ MÉTODO PARA ELIMINAR MASCOTA
  void _eliminarMascota(int mascotaId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de que quieres eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmarEliminarMascota(mascotaId, nombre);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarMascota(int mascotaId, String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_mascota.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'mascota_id': mascotaId}),
      );

      print('🗑️ Delete Response: ${response.statusCode}');
      print('🗑️ Delete Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _showSuccessSnackbar('$nombre eliminado correctamente');
          _loadMascotas(); // Recargar lista
        } else {
          _showErrorSnackbar(data['message'] ?? 'Error al eliminar mascota');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Error de conexión: $e');
    }
  }

  Widget _buildMascotaCard(Map mascota, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.pets, color: Colors.teal, size: 30),
        title: Text(
          mascota['nombre'] ?? 'Sin nombre',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Especie: ${mascota['especie'] ?? 'No especificado'}'),
            if (mascota['raza'] != null && mascota['raza'].isNotEmpty)
              Text('Raza: ${mascota['raza']}'),
            if (mascota['edad'] != null && mascota['edad'] > 0)
              Text('Edad: ${mascota['edad']} años'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _eliminarMascota(
            int.parse(mascota['id'].toString()),
            mascota['nombre'] ?? 'la mascota',
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tienes mascotas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar tu primera mascota',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
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
        title: const Text('Mis Mascotas'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMascotas,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mascotas.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMascotas,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: mascotas.length,
                    itemBuilder: (context, index) {
                      return _buildMascotaCard(mascotas[index], index);
                    },
                  ),
                ),
      // ✅ BOTÓN FLOTANTE PARA AGREGAR MASCOTA
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarMascota,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ✅ DIALOG PARA AGREGAR MASCOTA
class AddMascotaDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onMascotaAdded;

  const AddMascotaDialog({
    super.key,
    required this.userId,
    required this.onMascotaAdded,
  });

  @override
  State<AddMascotaDialog> createState() => _AddMascotaDialogState();
}

class _AddMascotaDialogState extends State<AddMascotaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _especieController = TextEditingController();
  final _razaController = TextEditingController();
  final _edadController = TextEditingController();
  bool _isSaving = false;

  static const String baseUrl = "https://helpet-back.onrender.com";

  Future<void> _guardarMascota() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_mascota.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'nombre': _nombreController.text,
          'especie': _especieController.text,
          'raza': _razaController.text,
          'edad': _edadController.text.isEmpty ? '0' : _edadController.text,
        }),
      );

      print('➕ Add Mascota Response: ${response.statusCode}');
      print('➕ Add Mascota Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Navigator.pop(context);
          widget.onMascotaAdded();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Error al guardar')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Mascota'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(
                  labelText: 'Especie (ej: Perro, Gato)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la especie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(
                  labelText: 'Raza (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _edadController,
                decoration: const InputDecoration(
                  labelText: 'Edad (opcional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _guardarMascota,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          child: _isSaving 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}