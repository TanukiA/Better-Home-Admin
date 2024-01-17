import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage(
      {Key? key, required this.serviceDoc, required this.controller})
      : super(key: key);
  final DocumentSnapshot serviceDoc;
  final AdminController controller;

  @override
  StateMVC<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends StateMVC<ServiceDetailPage> {
  bool isLoading = true;
  String technicianName = "";
  String customerName = "";

  @override
  void initState() {
    setServiceData();
    super.initState();
  }

  Future<void> setServiceData() async {
    technicianName = await widget.controller
        .retrieveUserName(widget.serviceDoc["technicianID"], "technicians");
    customerName = await widget.controller
        .retrieveUserName(widget.serviceDoc["customerID"], "customers");
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
    return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(35, 35, 35, 35),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Service Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                )),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 51, 119, 54),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            widget.serviceDoc["serviceStatus"],
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Service Type:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["serviceName"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Variation:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["serviceVariation"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Technician:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          technicianName,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Customer:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        if (widget.serviceDoc["serviceStatus"] == "Confirmed" ||
                            widget.serviceDoc["serviceStatus"] ==
                                "In Progress" ||
                            widget.serviceDoc["serviceStatus"] == "Completed" ||
                            widget.serviceDoc["serviceStatus"] == "Rated") ...[
                          const Text(
                            'Confirmed Appointment:',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "${widget.controller.formatToLocalDate(widget.serviceDoc["confirmedDate"])}, ${widget.serviceDoc["confirmedTime"]}",
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Preferred Appointment:',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "${widget.controller.formatToLocalDate(widget.serviceDoc["preferredDate"])}, ${widget.serviceDoc["preferredTime"]}",
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 19.0),
                          const Text(
                            'Alternative Appointment:',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "${widget.controller.formatToLocalDate(widget.serviceDoc["alternativeDate"])}, ${widget.serviceDoc["alternativeTime"]}",
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                        const SizedBox(height: 19.0),
                        const Text(
                          'Property Type:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["propertyType"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'State:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["city"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Address:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["address"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 19.0),
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          widget.serviceDoc["description"],
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Text(
                          '# Requested on ${widget.controller.formatToLocalDateTime(widget.serviceDoc["dateTimeSubmitted"])}',
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        Text(
                          'TOTAL: RM ${widget.serviceDoc["payment"].toInt()}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                  ],
                ),
              ));
  }
}
