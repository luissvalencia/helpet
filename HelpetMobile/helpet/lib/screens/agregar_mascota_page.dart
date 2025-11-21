import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AgregarMascotaPage extends StatefulWidget {
  const AgregarMascotaPage({super.key});

  @override
  State<AgregarMascotaPage> createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AgregarMascotaPage> {
  final nombreController = TextEditingController();
  final especieController = TextEditingController();
  final razaController = TextEditingController();
  final edadController = TextEditingController();
  bool _isLoading = false;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  Future<void> _agregarMascota() async {
    if (nombreController.text.isEmpty || especieController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos obligatorios")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Usuario no identificado")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/add_mascota.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'nombre': nombreController.text,
          'especie': especieController.text,
          'raza': razaController.text,
          'edad': edadController.text.isEmpty ? 0 : int.tryParse(edadController.text) ?? 0,
        }),
      );

      print('➕ Add Mascota Response: ${response.statusCode}');
      print('➕ Add Mascota Body: ${response.body}');

      final data = json.decode(response.body);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor: data['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (data['success'] == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error agregando mascota: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Mascota"), 
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: especieController,
              decoration: const InputDecoration(
                labelText: "Especie * (Perro, Gato, etc.)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: razaController,
              decoration: const InputDecoration(
                labelText: "Raza (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: edadController,
              decoration: const InputDecoration(
                labelText: "Edad (opcional)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _agregarMascota,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                        "Guardar Mascota",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "* Campos obligatorios",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}