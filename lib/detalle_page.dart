import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Necesitas instalar este paquete
import 'dart:io';
import 'paquete.dart';
import 'api_service.dart';

class DetallePage extends StatefulWidget {
  final Paquete paquete;
  DetallePage({required this.paquete});

  @override
  State<DetallePage> createState() => _DetallePageState();
}

class _DetallePageState extends State<DetallePage> {
  final api = ApiService();
  File? _image;
  final _attendanceController = TextEditingController();

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _confirmarEntrega() async {
    if (_image == null || _attendanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Foto y Nombre de quien recibe son obligatorios")),
      );
      return;
    }

    try {
      await api.entregar(widget.paquete.id, _image!.path, _attendanceController.text);
      Navigator.pop(context, true); // Regresa indicando que se actualizó
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al procesar la entrega")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Envío')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Información Visual
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _infoRow(Icons.inventory, "Producto", widget.paquete.nombre),
                    const Divider(),
                    _infoRow(Icons.description, "Descripción", widget.paquete.descripcion),
                    const Divider(),
                    _infoRow(Icons.location_on, "Destino", widget.paquete.destino),
                    const Divider(),
                    _infoRow(Icons.info, "Estado Actual", widget.paquete.status, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Sección de Validación de Entrega
            const Text("Validación de Entrega", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            
            TextField(
              controller: _attendanceController,
              decoration: const InputDecoration(
                labelText: "Nombre de quien recibe (Attendance)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            Center(
              child: Column(
                children: [
                  _image == null 
                    ? const Text("No se ha tomado foto de evidencia")
                    : Image.file(_image!, height: 150),
                  TextButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar Foto de Evidencia"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: _confirmarEntrega,
                child: const Text('FINALIZAR ENTREGA', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey[700]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}