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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Mis paquetes"),
    ),
    body: FutureBuilder<List<Paquete>>(
      future: paquetes,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar paquetes"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No hay paquetes"));
        }

        final data = snapshot.data!;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) {
            var p = data[i];

            return ListTile(
              title: Text(p.nombre),
              subtitle: Text(p.status),
              trailing: ElevatedButton(
                child: Text('Recolectar'),
                onPressed: () async {
                  await api.recolectar(p.id);
                  setState(() {
                    paquetes = api.getPaquetes(widget.userId);
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallePage(paquete: p),
                  ),
                );
              },
            );
          },
        );
      },
    ),
  );
}
}