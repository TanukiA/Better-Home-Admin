import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({Key? key, required this.adminCon}) : super(key: key);
  final AdminController adminCon;

  @override
  StateMVC<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends StateMVC<ServiceListPage> {
  bool isLoading = true;
  List<DocumentSnapshot> servicesDoc = [];

  String selectedServiceStatus = "All service status";
  final List<String> serviceStatusOptions = [
    "All service status",
    "Assigning",
    "Confirmed",
    "In Progress",
    "Completed",
    "Rated",
  ];

  @override
  void initState() {
    setUserData();
    super.initState();
  }

  Future<void> setUserData() async {
    servicesDoc = await widget.adminCon.retrieveServices();

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

    final ButtonStyle viewBtnStyle = ElevatedButton.styleFrom(
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
      body: isLoading == true
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
                  currentScreen: "Ongoing & Completed Services",
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Ongoing and Completed Services",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 12),
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: selectedServiceStatus,
                          items: serviceStatusOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedServiceStatus = newValue!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: servicesDoc.isEmpty
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
                                    itemCount: servicesDoc.length,
                                    itemBuilder: (context, index) {
                                      final serviceDoc = servicesDoc[index];
                                      final currentStatus =
                                          serviceDoc['serviceStatus'];

                                      if (selectedServiceStatus !=
                                              "All service status" &&
                                          selectedServiceStatus !=
                                              currentStatus) {
                                        return const SizedBox.shrink();
                                      }

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
                                            Text(
                                              currentStatus,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFAD07B8),
                                              ),
                                            ),
                                            const SizedBox(width: 35),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  serviceDoc['serviceName'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "id: ${serviceDoc.id}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: viewBtnStyle,
                                              child: const Text(
                                                'View details',
                                              ),
                                            ),
                                            const SizedBox(width: 130),
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
