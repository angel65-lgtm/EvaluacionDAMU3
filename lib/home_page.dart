import 'package:flutter/material.dart';
import 'paquetes_page.dart';

class HomePage extends StatelessWidget {
  final int userId;

  HomePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paquetes')),
      body: PaquetesPage(userId: userId),
    );
  }
}