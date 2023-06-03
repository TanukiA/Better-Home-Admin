import 'package:better_home_admin/models/admin.dart';
import 'package:better_home_admin/views/registration_requests_page.dart';
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
                        'Specialization: ${userDoc['specialization']}',
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
                          width: 200,
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              String verificationDocUrl =
                                  userDoc['verificationDoc'];
                              admin.viewVerificationFile(verificationDocUrl);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF89B218)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
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
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(35, 35, 35, 35),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Request Details',
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
                  'Specialization: ${userDoc['specialization']}',
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
                    width: 200,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        String verificationDocUrl = userDoc['verificationDoc'];
                        admin.viewVerificationFile(verificationDocUrl);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF89B218)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: const Text('Download verification file'),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  formatToLocalDateTime(userDoc['dateTimeRegistered']),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () async {
                            await admin.removeUserAccount(
                                "Technician", userDoc.id);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrationRequestsPage(
                                    adminCon: AdminController(),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 100,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () async {
                            await admin.approveRegistrationRequest(
                                userDoc.id,
                                userDoc['name'],
                                userDoc['email'],
                                userDoc['phoneNumber']);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrationRequestsPage(
                                    adminCon: AdminController(),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromRGBO(46, 125, 45, 1)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
}
