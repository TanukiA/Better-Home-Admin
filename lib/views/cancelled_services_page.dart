import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class CancelledServicesPage extends StatefulWidget {
  const CancelledServicesPage({super.key, required this.adminCon});
  final AdminController adminCon;

  @override
  StateMVC<CancelledServicesPage> createState() => _CancelledServicesPage();
}

class _CancelledServicesPage extends StateMVC<CancelledServicesPage> {
  bool isLoading = true;
  List<DocumentSnapshot> servicesDoc = [];

  DateTimeRange selectedDates = DateTimeRange(
    start: DateTime(2000),
    end: DateTime(3000),
  );

  @override
  void initState() {
    setServiceData();
    super.initState();
  }

  Future<void> setServiceData() async {
    servicesDoc = await widget.adminCon.retrieveCancelledServices();

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

    final ButtonStyle dateRangeBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 14,
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.14, 37),
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
                  currentScreen: "Cancelled Services",
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Cancelled Services",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: dateRangeBtnStyle,
                            onPressed: () async {
                              final DateTimeRange? dateTimeRange =
                                  await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(3000),
                                      initialDateRange: (selectedDates.start !=
                                                  DateTime(2000)) &&
                                              (selectedDates.end !=
                                                  DateTime(3000))
                                          ? selectedDates
                                          : null,
                                      builder: (context, child) {
                                        return Column(
                                          children: [
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 380.0,
                                                maxHeight: 580.0,
                                              ),
                                              child: child,
                                            )
                                          ],
                                        );
                                      });
                              if (dateTimeRange != null) {
                                setState(() {
                                  selectedDates = dateTimeRange;
                                });
                              }
                            },
                            child: const Text("Select date range"),
                          ),
                          const SizedBox(width: 15),
                          if (selectedDates.start != DateTime(2000) &&
                              selectedDates.end != DateTime(3000))
                            Text.rich(
                              TextSpan(
                                text: 'Date filter: ',
                                style: const TextStyle(fontSize: 14),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${widget.adminCon.formatStrFromDateTime(selectedDates.start)} - ${widget.adminCon.formatStrFromDateTime(selectedDates.end)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: servicesDoc.isEmpty
                            ? const Center(
                                child: Text(
                                  "No cancelled service available",
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
                                      final serviceDateTime = widget.adminCon
                                          .formatDateTime(
                                              serviceDoc['dateTimeSubmitted']);

                                      if (selectedDates.start !=
                                              DateTime(2000) &&
                                          selectedDates.end != DateTime(3000) &&
                                          (serviceDateTime.isBefore(
                                                  selectedDates.start) ||
                                              serviceDateTime.isAfter(
                                                  selectedDates.end))) {
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
                                            Container(
                                              constraints: const BoxConstraints(
                                                  minWidth: 90),
                                              child: Text(
                                                currentStatus,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFAD07B8),
                                                ),
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
                                                  "ID: ${serviceDoc.id}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              onPressed: () {
                                                widget.adminCon
                                                    .viewCancelledServiceDetailClicked(
                                                        serviceDoc, context);
                                              },
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
