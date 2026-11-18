import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _senha = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("BUSTOP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              controller: _usuario,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              controller: _senha,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("É um Motorista?"),
                Obx(() => Switch(
                    value: controller.isMotorista,
                    onChanged: (valor) {
                      controller.isMotorista = valor;
                    })),
              ],
            ),
            const SizedBox(height: 20),
            Obx(
              () {
                return controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          controller.login(_usuario.text, _senha.text);
                        },
                        child: const Text('Login'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
