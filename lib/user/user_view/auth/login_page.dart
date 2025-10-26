import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AppNavigator.back();
          },
          child: const Text('Go to Profile'),
        ),
      ),
    );
  }
}
