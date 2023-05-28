import 'package:better_home_admin/models/admin.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';

class LoginController extends ControllerMVC {
  late Admin admin;

  LoginController() {
    admin = Admin(email: '', password: '');
  }

  bool validEmailFormat(String email) {
    if (email.isEmpty) return true;

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    return regex.hasMatch(email);
  }

  Future<bool> isValidAdmin(String email, String password) async {
    return await admin.isValidAdmin(email, password);
  }

  void showUnauthorizedError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unauthorized user"),
          content: const Text("Invalid email or password"),
          actions: [
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
