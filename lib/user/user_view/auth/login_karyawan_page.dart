import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class LoginKaryawanPage extends StatelessWidget {
  const LoginKaryawanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Karyawan Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AppNavigator.back();
          },
          child: const Text('Go to LoginKaryawanPage'),
        ),
      ),
    );
  }
}
