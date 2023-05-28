import 'package:better_home_admin/models/database.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class Admin extends ModelMVC {
  String? email;
  String? password;

  Admin({required String this.email, required String this.password});

  Future<bool> isValidAdmin(String email, String password) async {
    Database firestore = Database();
    return await firestore.checkAdminAccount(email, password);
  }
}
