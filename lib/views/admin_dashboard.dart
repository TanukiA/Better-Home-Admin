import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/views/service_chart_data.dart';
import 'package:better_home_admin/views/vertical_menu.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard(
      {Key? key, required this.loginCon, required this.adminCon})
      : super(key: key);
  final LoginController loginCon;
  final AdminController adminCon;

  @override
  StateMVC<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends StateMVC<AdminDashboard> {
  int technicianNumber = 0;
  double cancelRate = 0.0;
  bool isLoading = true;

  final data = [
    ServiceChartData('Plumbing', 0),
    ServiceChartData('Aircon Servicing', 0),
    ServiceChartData('Roof Servicing', 0),
    ServiceChartData('Electrical & Wiring', 0),
    ServiceChartData('Window & Door', 0),
    ServiceChartData('Painting', 0),
  ];

  List<charts.Series<ServiceChartData, String>>? chartData;

  @override
  void initState() {
    setData();
    super.initState();
  }

  Future<void> setData() async {
    technicianNumber = await widget.adminCon.retrieveTechnicianNumber();
    cancelRate = await widget.adminCon.getCancellationRate();
    final updatedData = await createData();
    setState(() {
      chartData = updatedData;
      isLoading = false;
    });
  }

  Future<List<charts.Series<ServiceChartData, String>>> createData() async {
    final updatedData = List<ServiceChartData>.from(data);

    final retrieveDataFutures = updatedData.map((serviceChartData) {
      final serviceCategory = serviceChartData.serviceCategory;
      return widget.adminCon.retrieveChartData(serviceCategory).then((count) {
        return ServiceChartData(serviceCategory, count);
      });
    });

    final List<ServiceChartData> newData =
        await Future.wait(retrieveDataFutures);

    updatedData.clear();
    updatedData.addAll(newData);

    return [
      charts.Series<ServiceChartData, String>(
        id: 'Services',
        domainFn: (ServiceChartData data, _) => data.serviceCategory,
        measureFn: (ServiceChartData data, _) => data.count,
        data: updatedData,
        colorFn: (_, __) => charts.MaterialPalette.deepOrange.shadeDefault,
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E5D4),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 51, 119, 54),
              ),
            )
          : chartData != null
              ? Row(
                  children: [
                    VerticalMenu(
                      loginCon: LoginController(),
                      adminCon: AdminController(),
                      currentScreen: "Dashboard",
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 170,
                            height: 120,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Current number of technician:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "$technicianNumber",
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontFamily: 'Roboto',
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          Container(
                            width: 170,
                            height: 120,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Cancellation rate:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "$cancelRate%",
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontFamily: 'Roboto',
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          Container(
                            width: 425,
                            height: 460,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Service Distribution",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: charts.BarChart(
                                    chartData!,
                                    animate: true,
                                    vertical: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
    );
  }
}
