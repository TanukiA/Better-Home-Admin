import 'dart:convert';
import 'package:better_home_admin/models/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:better_home_admin/models/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> obtainUserData() async {
    Database firestore = Database();
    final userDoc = await firestore.readUserData();
    return userDoc;
  }

  void viewVerificationFile(String verificationDocUrl) async {
    final Uri url = Uri.parse(verificationDocUrl);

    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> removeUserAccount(String accountType, String id) async {
    Database firestore = Database();
    await firestore.deleteUser(accountType, id);
  }

  Future<List<DocumentSnapshot>> retrieveRegistrationRequests() async {
    Database firestore = Database();
    return await firestore.getUnapprovedTechnicians();
  }

  Future<void> rejectRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    removeUserAccount("Technician", id);
    final message =
        'We are sorry to inform you that your technician registration associated with $phoneNumber in BetterHome has been rejected. Kindly contact us for clarification.';
    final response = await sendNotificationEmail(
        name, email, message, 'Registration rejected');
    if (response != 200) {
      throw Exception('Send rejection email failed');
    }
  }

  Future<void> approveRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    Database firestore = Database();
    await firestore.updateApprovalStatus(id);
    final message =
        'Your technician registration associated with $phoneNumber in BetterHome has been approved. Kindly login now.';
    final response = await sendNotificationEmail(
        name, email, message, 'Registration approved');
    if (response != 200) {
      throw Exception('Send approval email failed');
    }
  }

  Future sendNotificationEmail(
      String name, String email, String message, String subject) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    const serviceId = 'service_maoya7g';
    const templateId = 'template_c2b1sda';
    const userId = 'haj1CA0xZVtU10OOu';
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_name': name,
            'to_email': email,
            'subject': subject,
            'message': message
          }
        }));
    return response.statusCode;
  }

  Future<List<DocumentSnapshot>> retrieveServices() async {
    Database firestore = Database();
    return await firestore.readServices();
  }

  Future<String> retrieveUserName(String id, String collectionName) async {
    Database firestore = Database();
    String userName = await firestore.readUserName(id, collectionName);
    return userName;
  }

  Future<List<DocumentSnapshot>> retrieveCancelledServices() async {
    Database firestore = Database();
    return await firestore.readCancelledServices();
  }

  Future<void> refundService(String id) async {
    Database firestore = Database();
    await firestore.updateRefundStatus(id);
  }

  Future<List<DocumentSnapshot>> retrieveTechnicianData() async {
    Database db = Database();
    return await db.readApprovedTechnicians();
  }

  Future<List<Map<String, dynamic>>> retrieveTechnicianRating(
      String technicianID) async {
    Database db = Database();
    return await db.readRating(technicianID);
  }
}
