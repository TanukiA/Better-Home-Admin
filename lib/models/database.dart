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
}
