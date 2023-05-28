import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Database extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<bool> checkAdminAccount(String email, String password) async {
    final querySnapshot = await _firebaseFirestore
        .collection("admin")
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
