import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class UserAccountsPage extends StatefulWidget {
  const UserAccountsPage({Key? key, required this.adminCon}) : super(key: key);
  final AdminController adminCon;

  @override
  StateMVC<UserAccountsPage> createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends StateMVC<UserAccountsPage> {
  bool isLoading = true;
  List<DocumentSnapshot> usersDoc = [];
  List<String> accountTypeList = [];
  String selectedAccountType = "All account types";
  final List<String> accountTypeOptions = [
    "All account types",
    "Customer",
    "Technician",
  ];

  @override
  void initState() {
    setUserData();
    super.initState();
  }

  Future<void> setUserData() async {
    final mapData = await widget.adminCon.obtainUserData();
    usersDoc = mapData['doc'];
    accountTypeList = mapData['accountType'];
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
                  currentScreen: "User Accounts",
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "List of User Accounts",
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
                          value: selectedAccountType,
                          items: accountTypeOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedAccountType = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: usersDoc.isEmpty
                            ? const Center(
                                child: Text(
                                  "No user account available",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 150,
                                  child: ListView.builder(
                                    itemCount: usersDoc.length,
                                    itemBuilder: (context, index) {
                                      final currentType =
                                          accountTypeList[index];
                                      final userDoc = usersDoc[index];

                                      if (selectedAccountType !=
                                              "All account types" &&
                                          selectedAccountType != currentType) {
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
                                              currentType,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 8, 114, 70),
                                              ),
                                            ),
                                            const SizedBox(width: 35),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userDoc['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  userDoc['phoneNumber'],
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
                                                widget.adminCon.viewFullProfile(
                                                    currentType,
                                                    userDoc,
                                                    context);
                                              },
                                              style: viewBtnStyle,
                                              child: const Text(
                                                'View full profile',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 130),
                                            IconButton(
                                              onPressed: () {
                                                widget.adminCon
                                                    .deleteIconClicked(
                                                        currentType,
                                                        userDoc,
                                                        context);
                                              },
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              iconSize: 30,
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
