import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Database extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<int> getTechniciansCount() async {
    QuerySnapshot snapshot =
        await _firebaseFirestore.collection('technicians').get();

    return snapshot.size;
  }

  Future<int> getTotalServices() async {
    QuerySnapshot querySnapshot =
        await _firebaseFirestore.collection('services').get();
    return querySnapshot.size;
  }

  Future<int> getCancelledServices() async {
    QuerySnapshot cancelledSnapshot = await _firebaseFirestore
        .collection('services')
        .where('serviceStatus', isEqualTo: 'Cancelled')
        .get();
    return cancelledSnapshot.size;
  }

  Future<int> readServiceCount(String serviceCategory) async {
    // Get the current month's start and end dates
    //final now = DateTime.now();
    //final startOfMonth = DateTime(now.year, now.month, 1);
    //final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('serviceName', isGreaterThanOrEqualTo: serviceCategory)
        .where('serviceName', isLessThanOrEqualTo: '$serviceCategory\uf8ff')
        .get();

    final matchingDocuments = querySnapshot.docs
        .where((doc) => doc['serviceName'].contains(serviceCategory))
        .toList();
    return matchingDocuments.length;
  }

  Future<Map<String, dynamic>> readUserData() async {
    final customersQuery = _firebaseFirestore.collection('customers');
    final techniciansQuery = _firebaseFirestore.collection('technicians');

    final customersSnapshot = await customersQuery.get();
    final techniciansSnapshot = await techniciansQuery.get();

    final List<DocumentSnapshot> allUser = [];
    final List<String> accountType = [];

    for (final customerDoc in customersSnapshot.docs) {
      allUser.add(customerDoc);
      accountType.add('Customer');
    }

    for (final technicianDoc in techniciansSnapshot.docs) {
      allUser.add(technicianDoc);
      accountType.add('Technician');
    }

    return {
      'doc': allUser,
      'accountType': accountType,
    };
  }
}
