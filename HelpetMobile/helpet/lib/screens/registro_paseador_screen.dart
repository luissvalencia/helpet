import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistroPaseadorPage extends StatefulWidget {
  const RegistroPaseadorPage({Key? key}) : super(key: key);

  @override
  State<RegistroPaseadorPage> createState() => _RegistroPaseadorPageState();
}

class _RegistroPaseadorPageState extends State<RegistroPaseadorPage> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();
  final experienciaController = TextEditingController();
  String disponibilidad = 'Mañana';
  bool _cargando = false;

  // 🔽 URL CORREGIDA
  static const String baseUrl = "https://helpet-back.onrender.com";

  Future<void> _registrarPaseador() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Oculta el teclado
    setState(() => _cargando = true);

    try {
      final url = Uri.parse('$baseUrl/registro_paseador.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombreController.text.trim(),
          'email': correoController.text.trim(),
          'password': passwordController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'direccion': direccionController.text.trim(),
          'experiencia': experienciaController.text.trim(),
          'disponibilidad': disponibilidad,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📤 Registro Paseador Response: ${response.statusCode}');
      print('📤 Registro Paseador Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          _mostrarMensaje('✅ ¡Registro exitoso! 🐾', Colors.green);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pushNamed(context, '/login');
        } else {
          _mostrarMensaje(data['message'] ?? 'Error en el registro', Colors.red);
        }
      } else {
        _mostrarMensaje('❌ Error del servidor (${response.statusCode})', Colors.orange);
      }
    } catch (e) {
      print('❌ Error en registro paseador: $e');
      _mostrarMensaje('❌ Error de conexión: $e', Colors.red);
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Paseador'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cargando ? null : () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF004D40)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_walk, size: 90, color: Colors.teal),
                      const SizedBox(height: 10),
                      const Text(
                        'Registro de Paseador',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _campoTexto('Nombre completo', nombreController),
                      _campoTexto('Correo electrónico', correoController,
                          tipo: TextInputType.emailAddress),
                      _campoTexto('Teléfono', telefonoController,
                          tipo: TextInputType.phone, obligatorio: false),
                      _campoTexto('Dirección', direccionController, obligatorio: false),
                      _campoTexto('Años de experiencia', experienciaController,
                          tipo: TextInputType.number),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: disponibilidad,
                        decoration: const InputDecoration(
                          labelText: 'Disponibilidad *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Mañana', child: Text('Mañana')),
                          DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                          DropdownMenuItem(value: 'Noche', child: Text('Noche')),
                          DropdownMenuItem(value: 'Todo el día', child: Text('Todo el día')),
                        ],
                        onChanged: (value) => setState(() => disponibilidad = value!),
                        validator: (value) => value == null ? 'Seleccione disponibilidad' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) => value!.length < 6
                            ? 'Debe tener al menos 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _registrarPaseador,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check),
                                    SizedBox(width: 8),
                                    Text(
                                      'Registrar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '* Campos obligatorios',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text, bool obligatorio = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: obligatorio ? '$label *' : label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.person_outline),
        ),
        validator: obligatorio 
            ? (value) => value!.isEmpty ? 'Campo obligatorio' : null
            : null,
      ),
    );
  }
}