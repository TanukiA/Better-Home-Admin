import 'package:better_home_admin/models/admin.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';

class AdminController extends ControllerMVC {
  late Admin admin;

  AdminController() {
    admin = Admin(email: '', password: '');
  }
}
