import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TechnicianReviewPage extends StatefulWidget {
  const TechnicianReviewPage({Key? key, required this.adminCon})
      : super(key: key);
  final AdminController adminCon;

  @override
  StateMVC<TechnicianReviewPage> createState() => _TechnicianReviewPageState();
}

class _TechnicianReviewPageState extends StateMVC<TechnicianReviewPage> {
  bool isLoading = true;
  List<DocumentSnapshot> techniciansDoc = [];
  List<Map<String, dynamic>> ratingData = [];
  List<double> starQtyList = [];

  @override
  void initState() {
    setTechnicianData();
    super.initState();
  }

  Future<void> setTechnicianData() async {
    techniciansDoc = await widget.adminCon.retrieveTechnicianData();

    for (final technicianDoc in techniciansDoc) {
      final technicianId = technicianDoc.id;
      ratingData = await widget.adminCon.retrieveTechnicianRating(technicianId);

      // add average star rating to the list if there is rating exists
      // if the technician has no review yet, add 0
      if (ratingData.isNotEmpty) {
        final avgStarQty = widget.adminCon.calculateAvgRating(ratingData);
        starQtyList.add(avgStarQty);
      } else {
        starQtyList.add(0);
      }
    }

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
                  currentScreen: "Technician Reviews",
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Technician Ratings & Reviews",
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
                                  "No technician found",
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
                                      final String specialization =
                                          technicianDoc['specialization']
                                              .join(', ');

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
                                                  "Specialization: $specialization",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            if (starQtyList[index] > 0)
                                              ElevatedButton(
                                                onPressed: () {
                                                  widget.adminCon
                                                      .viewCustomerReviewClicked(
                                                          ratingData,
                                                          technicianDoc['name'],
                                                          context);
                                                },
                                                style: viewBtnStyle,
                                                child: const Text(
                                                  'View reviews',
                                                ),
                                              ),
                                            const SizedBox(width: 60),
                                            Container(
                                                width: 65,
                                                height: 40,
                                                padding:
                                                    const EdgeInsets.all(7),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color.fromARGB(
                                                      255, 80, 86, 165),
                                                ),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons.star,
                                                          color: Colors.white),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                          "${starQtyList[index]}",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          )),
                                                    ])),
                                            const SizedBox(width: 50),
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
