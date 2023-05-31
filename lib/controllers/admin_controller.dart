import 'package:better_home_admin/models/admin.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';

class AdminController extends ControllerMVC {
  late Admin admin;

  AdminController() {
    admin = Admin(email: '', password: '');
  }

  Future<int> retrieveTechnicianNumber() async {
    return await admin.retrieveTechnicianNumber();
  }

  Future<double> getCancellationRate() async {
    return await admin.calculateCancellationRate();
  }

  Future<int> retrieveChartData(String serviceCategory) async {
    return await admin.retrieveServiceCount(serviceCategory);
  }
}
