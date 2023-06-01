import 'package:better_home_admin/models/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                      const SizedBox(height: 10),
                      if (docData.containsKey('verificationDoc'))
                        ElevatedButton(
                          onPressed: () {
                            String verificationDocUrl =
                                userDoc['verificationDoc'];

                            admin.downloadVerificationDoc(verificationDocUrl);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF89B218)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: const Text('Download verification doc'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
