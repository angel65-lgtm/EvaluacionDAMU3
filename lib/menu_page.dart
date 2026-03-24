import 'package:flutter/material.dart';
import 'paquetes_page.dart';
import 'login_page.dart';

class MenuPage extends StatelessWidget {

  final String nombre;
  final int usuarioId;

  const MenuPage({
    super.key,
    required this.nombre,
    required this.usuarioId
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Bienvenido $nombre"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const SizedBox(height: 10),

          // 📦 VER PAQUETES
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text("Mis paquetes"),
              subtitle: const Text("Ver paquetes asignados"),

              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaquetesPage(userId: usuarioId)
                  )
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 🚪 LOGOUT
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Cerrar sesión"),

              onTap: (){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage()
                  ),
                  (route) => false,
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}