import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/views/registration_requests_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage(
      {Key? key,
      required this.userDoc,
      required this.docData,
      required this.controller})
      : super(key: key);
  final DocumentSnapshot userDoc;
  final Map<String, dynamic> docData;
  final AdminController controller;

  @override
  StateMVC<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends StateMVC<RequestDetailPage> {
  @override
  Widget build(BuildContext context) {
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
              'Name: ${widget.userDoc['name']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Phone number: ${widget.userDoc['phoneNumber']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${widget.userDoc['email']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'State: ${widget.userDoc['city']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Address: ${widget.userDoc['address']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Specialization: ${widget.userDoc['specialization'].join(', ')}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Experience: ${widget.userDoc['experience']}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            if (widget.docData.containsKey('verificationDoc'))
              SizedBox(
                width: 205,
                height: 38,
                child: ElevatedButton(
                  onPressed: () {
                    String verificationDocUrl =
                        widget.userDoc['verificationDoc'];
                    widget.controller.viewVerificationFile(verificationDocUrl);
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
              ),
            const SizedBox(height: 20),
            Text(
              widget.controller
                  .formatToLocalDateTime(widget.userDoc['dateTimeRegistered']),
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
                    width: 103,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () async {
                        await widget.controller.rejectRegistrationRequest(
                            widget.userDoc.id,
                            widget.userDoc['name'],
                            widget.userDoc['email'],
                            widget.userDoc['phoneNumber']);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationRequestsPage(
                                adminCon: AdminController(),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 103,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.controller.approveRegistrationRequest(
                            widget.userDoc.id,
                            widget.userDoc['name'],
                            widget.userDoc['email'],
                            widget.userDoc['phoneNumber']);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationRequestsPage(
                                adminCon: AdminController(),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(65, 33),
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
  }
}
