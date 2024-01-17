import 'package:better_home_admin/models/admin.dart';
import 'package:better_home_admin/models/database.dart';
import 'package:better_home_admin/views/cancelled_services_detail_page.dart';
import 'package:better_home_admin/views/request_detail_page.dart';
import 'package:better_home_admin/views/service_detail_page.dart';
import 'package:better_home_admin/views/technician_review_detail_page.dart';
import 'package:better_home_admin/views/user_accounts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:intl/intl.dart';

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

  Future<Map<String, dynamic>> obtainUserData() async {
    return await admin.obtainUserData();
  }

  void viewFullProfile(
      String accountType, DocumentSnapshot userDoc, BuildContext context) {
    final docData = userDoc.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(35, 35, 35, 35),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account type: $accountType',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Name: ${userDoc['name']}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Phone number: ${userDoc['phoneNumber']}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${userDoc['email']}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                if (accountType == 'Technician')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'State: ${userDoc['city']}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Address: ${userDoc['address']}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Specialization: ${userDoc['specialization'].join(', ')}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Experience: ${userDoc['experience']}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (docData.containsKey('verificationDoc'))
                        SizedBox(
                          width: 205,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              String verificationDocUrl =
                                  userDoc['verificationDoc'];
                              admin.viewVerificationFile(verificationDocUrl);
                            },
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 14,
                              ),
                              backgroundColor: const Color(0xFF89B218),
                              foregroundColor: Colors.white,
                              fixedSize: const Size(50, 33),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                              shadowColor: Colors.grey[400],
                            ),
                            child: const Text('Download verification file'),
                          ),
                        )
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteIconClicked(
      String accountType, DocumentSnapshot userDoc, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete this account?"),
          content: const Text("All user data will be removed permanently."),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Yes"),
              onPressed: () async {
                admin.removeUserAccount(accountType, userDoc.id);

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserAccountsPage(
                        adminCon: AdminController(),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> retrieveRegistrationRequests() async {
    return await admin.retrieveRegistrationRequests();
  }

  String formatToLocalDateTime(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  void manageRequestClicked(DocumentSnapshot userDoc, BuildContext context) {
    final docData = userDoc.data() as Map<String, dynamic>;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RequestDetailPage(
            controller: AdminController(),
            docData: docData,
            userDoc: userDoc,
          );
        });
  }

  void viewVerificationFile(String verificationDocUrl) {
    admin.viewVerificationFile(verificationDocUrl);
  }

  Future<void> rejectRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    await admin.rejectRegistrationRequest(id, name, email, phoneNumber);
  }

  Future<void> approveRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    await admin.approveRegistrationRequest(id, name, email, phoneNumber);
  }

  Future<List<DocumentSnapshot>> retrieveServices() async {
    return await admin.retrieveServices();
  }

  String formatToLocalDate(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<String> retrieveUserName(String id, String collectionName) async {
    return await admin.retrieveUserName(id, collectionName);
  }

  DateTime formatDateTime(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return dateTime;
  }

  String formatStrFromDateTime(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime newDateTime = tz.TZDateTime.from(dateTime, location);
    return DateFormat('dd/MM/yyyy').format(newDateTime);
  }

  void viewServiceDetailClicked(
      DocumentSnapshot serviceDoc, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ServiceDetailPage(
            controller: AdminController(),
            serviceDoc: serviceDoc,
          );
        });
  }

  Future<List<Widget>> retrieveServiceImages(DocumentSnapshot serviceDoc) {
    Database db = Database();
    return db.downloadServiceImages(serviceDoc);
  }

  Future<List<DocumentSnapshot>> retrieveCancelledServices() async {
    return await admin.retrieveCancelledServices();
  }

  void viewCancelledServiceDetailClicked(
      DocumentSnapshot serviceDoc, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CancelledServiceDetailPage(
            controller: AdminController(),
            serviceDoc: serviceDoc,
          );
        });
  }

  Future<void> refundService(String id) async {
    await admin.refundService(id);
  }

  Future<List<DocumentSnapshot>> retrieveTechnicianData() async {
    return await admin.retrieveTechnicianData();
  }

  Future<List<Map<String, dynamic>>> retrieveTechnicianRating(
      String technicianID) async {
    final ratingData = await admin.retrieveTechnicianRating(technicianID);

    return ratingData;
  }

  double calculateAvgRating(List<Map<String, dynamic>> data) {
    final List allStarQtys = data
        .where((review) => review.containsKey('starQty'))
        .map((review) => review['starQty'].toDouble())
        .toList();

    final double sum = allStarQtys.reduce((a, b) => a + b);
    return sum / allStarQtys.length;
  }

  void viewCustomerReviewClicked(List<Map<String, dynamic>> reviewData,
      String technicianName, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return TechnicianReviewDetailPage(
            controller: AdminController(),
            reviewData: reviewData,
            technicianName: technicianName,
          );
        });
  }
}
