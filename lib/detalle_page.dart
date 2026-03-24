import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data'; // Fundamental para que funcione en laptop
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
  
  // Variables para compatibilidad con Laptop
  Uint8List? _imageBytes; 
  XFile? _imageFile;      

  final _attendanceController = TextEditingController();
  
  Position? _currentPosition;
  bool _asistenciaConfirmada = false;
  bool _cargandoGps = false;

  Future<void> _confirmarAsistencia() async {
    setState(() => _cargandoGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'El GPS está desactivado.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permisos denegados.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _currentPosition = position;
        _asistenciaConfirmada = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Ubicación obtenida")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _cargandoGps = false);
    }
  }

  void _finalizarEntrega() async {
    if (!_asistenciaConfirmada || _currentPosition == null) {
      _showError("Primero confirma tu asistencia (GPS)");
      return;
    }
    if (_imageFile == null) {
      _showError("La foto es obligatoria");
      return;
    }
    if (_attendanceController.text.trim().isEmpty) {
      _showError("El nombre es obligatorio");
      return;
    }

    try {
      await api.entregar(
        widget.paquete.id,
        _imageFile!.path, 
        _attendanceController.text.trim(),
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showError("Error al enviar: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ $msg")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Entrega")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // === DISEÑO BONITO DE DATOS ===
            _buildInfoCard(),
            
            const SizedBox(height: 25),

            TextField(
              controller: _attendanceController,
              decoration: const InputDecoration(
                labelText: "Nombre de quien recibe",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            _cargandoGps 
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _confirmarAsistencia,
                  icon: Icon(_asistenciaConfirmada ? Icons.check_circle : Icons.location_on),
                  label: Text(_asistenciaConfirmada ? "Asistencia Confirmada" : "Confirmar Asistencia"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _asistenciaConfirmada ? Colors.blue : Colors.orange,
                  ),
                ),

            const SizedBox(height: 25),

            // Previsualización adaptada para Laptop
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!)
              ),
              child: _imageBytes == null 
                ? const Center(child: Text("Falta foto de evidencia")) 
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  ),
            ),

            TextButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? pic = await picker.pickImage(source: ImageSource.camera);
                
                if (pic != null) {
                  final bytes = await pic.readAsBytes();
                  setState(() {
                    _imageBytes = bytes;
                    _imageFile = pic;
                  });
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Seleccionar Foto"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _asistenciaConfirmada ? _finalizarEntrega : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("FINALIZAR ENTREGA", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === EL MISMO DISEÑO QUE TE GUSTÓ ===
  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.paquete.nombre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _statusBadge(widget.paquete.status),
              ],
            ),
            const Divider(height: 30),
            _infoRow(Icons.description_outlined, "Descripción", widget.paquete.descripcion),
            const SizedBox(height: 15),
            _infoRow(Icons.location_on_outlined, "Origen", "Centro de Distribución", Colors.orange),
            const SizedBox(height: 15),
            _infoRow(Icons.local_shipping_outlined, "Dirección de Destino", widget.paquete.destino, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, [Color iconColor = Colors.blueGrey]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }
}