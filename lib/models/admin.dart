import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home_admin/models/admin.dart';
import 'package:better_home_admin/models/auth_service.dart';
import 'package:flutter/material.dart';

class Admin extends ModelMVC {
  String? email;
  String? password;

  Admin({required String this.email, required String this.password});

  Future<bool> login(String email, String password) async {
    AuthService auth = AuthService();
    final success = await auth.signIn(email, password);
    return success;
  }
}
