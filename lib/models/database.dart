import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class Database extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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

  Future<void> deleteUser(String accountType, String id) async {
    CollectionReference collection;

    if (accountType == "Customer") {
      collection = _firebaseFirestore.collection('customers');
    } else if (accountType == "Technician") {
      collection = _firebaseFirestore.collection('technicians');
    } else {
      return;
    }

    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw PlatformException(
        code: 'user-deletion-failed',
        message: e.toString(),
      );
    }
  }

  Future<List<DocumentSnapshot>> getUnapprovedTechnicians() async {
    QuerySnapshot snapshot = await _firebaseFirestore
        .collection('technicians')
        .where('approvalStatus', isEqualTo: false)
        .orderBy('dateTimeRegistered', descending: true)
        .get();

    return snapshot.docs;
  }

  Future<void> updateApprovalStatus(String id) async {
    try {
      final userCollection = _firebaseFirestore.collection("technicians");
      final userDoc = userCollection.doc(id);

      await userDoc.update({'approvalStatus': true});
    } catch (e) {
      throw PlatformException(
          code: 'update-approvalStatus-failed', message: e.toString());
    }
  }

  Future<List<DocumentSnapshot>> readServices() async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('serviceStatus', whereIn: [
          'Assigning',
          'Confirmed',
          'In Progress',
          'Completed',
          'Rated'
        ])
        .orderBy('dateTimeSubmitted', descending: true)
        .get();

    List<DocumentSnapshot> documents =
        querySnapshot.docs.map((doc) => doc).toList();
    return documents;
  }

  Future<String> readUserName(String id, String collectionName) async {
    final CollectionReference usersRef =
        _firebaseFirestore.collection(collectionName);

    final DocumentSnapshot userDoc = await usersRef.doc(id).get();
    return userDoc.get('name');
  }

  Future<List<Widget>> downloadServiceImages(
      DocumentSnapshot serviceDoc) async {
    List<String> imageRefs = List.from(serviceDoc['images']);

    if (imageRefs.isNotEmpty) {
      // Download the images from Cloud Storage and store them in a list of PhotoView
      List<Future<Widget>> imageFutures = imageRefs.map((imageRef) async {
        return SizedBox(
          width: 390.0,
          height: 280.0,
          child: PhotoView(
            imageProvider: NetworkImage(imageRef),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          ),
        );
      }).toList();

      Iterable<Future<Widget>> imageIterable = imageFutures;
      List<Widget> images = await Future.wait(imageIterable);
      return images;
    }
    return [];
  }

  Future<List<DocumentSnapshot>> readCancelledServices() async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('serviceStatus', whereIn: ['Cancelled', 'Refunded'])
        .orderBy('dateTimeSubmitted', descending: true)
        .get();

    List<DocumentSnapshot> documents =
        querySnapshot.docs.map((doc) => doc).toList();
    return documents;
  }
}
