import 'package:flutter/material.dart';
import 'api_service.dart';
import 'paquete.dart';
import 'detalle_page.dart';

class PaquetesPage extends StatefulWidget {
  final int userId;

  PaquetesPage({required this.userId});

  @override
  _PaquetesPageState createState() => _PaquetesPageState();
}

class _PaquetesPageState extends State<PaquetesPage> {
  final api = ApiService();
  late Future<List<Paquete>> paquetes;

  @override
  void initState() {
    super.initState();
    paquetes = api.getPaquetes(widget.userId);
  }

  // Función para definir el color según el estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado': return Colors.green;
      case 'recolectado': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fondo sutil
      appBar: AppBar(
        title: const Text("Mis Paquetes", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Paquete>>(
        future: paquetes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Error al cargar paquetes", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const Text("No tienes paquetes asignados", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              var p = data[i];
              Color statusColor = _getStatusColor(p.status);

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () async {
                    final seEntrego = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetallePage(paquete: p)),
                    );

                    if (seEntrego == true) {
                      setState(() {
                        paquetes = api.getPaquetes(widget.userId);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Imagen con bordes redondeados
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            p.imagen,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // Información del paquete
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Badge de estado
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.status.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botón o Icono de acción
                        p.status == 'entregado'
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: const Text('Recolectar', style: TextStyle(fontSize: 12)),
                                onPressed: () async {
                                  await api.recolectar(p.id, widget.userId);
                                  setState(() {
                                    paquetes = api.getPaquetes(widget.userId);
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}