import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RegistrationRequestsPage extends StatefulWidget {
  const RegistrationRequestsPage({Key? key, required this.adminCon})
      : super(key: key);
  final AdminController adminCon;

  @override
  StateMVC<RegistrationRequestsPage> createState() =>
      _RegistrationRequestsPageState();
}

class _RegistrationRequestsPageState
    extends StateMVC<RegistrationRequestsPage> {
  bool isLoading = true;
  List<DocumentSnapshot> techniciansDoc = [];

  @override
  void initState() {
    setRequestData();
    super.initState();
  }

  Future<void> setRequestData() async {
    techniciansDoc = await widget.adminCon.retrieveRegistrationRequests();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle manageBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 12,
      ),
      backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.10, 33),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 51, 119, 54),
              ),
            )
          : Row(
              children: [
                VerticalMenu(
                  loginCon: LoginController(),
                  adminCon: AdminController(),
                  currentScreen: "Registration Requests",
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Technicians' Registration Requests",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: techniciansDoc.isEmpty
                            ? const Center(
                                child: Text(
                                  "No registration request available",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 150,
                                  child: ListView.builder(
                                    itemCount: techniciansDoc.length,
                                    itemBuilder: (context, index) {
                                      final technicianDoc =
                                          techniciansDoc[index];

                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(
                                            60, 7, 60, 7),
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 3,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  technicianDoc['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  technicianDoc['phoneNumber'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              onPressed: () {
                                                widget.adminCon
                                                    .manageRequestClicked(
                                                        technicianDoc, context);
                                              },
                                              style: manageBtnStyle,
                                              child: const Text(
                                                'Manage request',
                                              ),
                                            ),
                                            const SizedBox(width: 100),
                                            Text(
                                              widget.adminCon
                                                  .formatToLocalDateTime(
                                                      technicianDoc[
                                                          'dateTimeRegistered']),
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
