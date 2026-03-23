import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: userController),
            TextField(controller: passController, obscureText: true),
            ElevatedButton(
              onPressed: () async {
                int userId = await api.login(
                  userController.text,
                  passController.text,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePage(userId: userId),
                  ),
                );
              },
              child: Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
