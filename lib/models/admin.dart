import 'package:better_home_admin/models/database.dart';
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

  void logout() {
    AuthService auth = AuthService();
    auth.signOut();
  }

  Future<int> retrieveTechnicianNumber() async {
    Database firestore = Database();
    final count = await firestore.getTechniciansCount();
    return count;
  }

  Future<double> calculateCancellationRate() async {
    Database firestore = Database();
    int totalServices = await firestore.getTotalServices();
    int cancelledServices = await firestore.getCancelledServices();

    double cancellationRate = (cancelledServices / totalServices) * 100;

    return cancellationRate;
  }

  Future<int> retrieveServiceCount(String serviceCategory) async {
    Database firestore = Database();
    final serviceCount = await firestore.readServiceCount(serviceCategory);
    return serviceCount;
  }
}
