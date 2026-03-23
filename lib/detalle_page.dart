import 'package:flutter/material.dart';
import 'paquete.dart';
import 'api_service.dart';

class DetallePage extends StatelessWidget {
  final Paquete paquete;
  final api = ApiService();

  DetallePage({required this.paquete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(paquete.nombre)),
      body: Column(
        children: [
          Text(paquete.descripcion),
          Text(paquete.destino),
          ElevatedButton(
            child: Text('Entregar'),
            onPressed: () async {
              await api.entregar(paquete.id);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}