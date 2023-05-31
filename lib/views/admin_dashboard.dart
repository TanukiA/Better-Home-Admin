import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard(
      {Key? key, required this.loginCon, required this.adminCon})
      : super(key: key);
  final LoginController loginCon;
  final AdminController adminCon;

  @override
  StateMVC<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends StateMVC<AdminDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      body: Row(
        children: [
          VerticalMenu(loginCon: LoginController()),
          const Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
