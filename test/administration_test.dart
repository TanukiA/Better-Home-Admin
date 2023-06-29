// ignore_for_file: subtype_of_sealed_class

import 'package:better_home_admin/controllers/admin_controller.dart';
import 'package:better_home_admin/models/database.dart';
import 'package:better_home_admin/models/admin.dart';
import 'package:better_home_admin/views/service_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late MockDatabase mockDatabase;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCustomersCollection;
  late MockCollectionReference mockTechniciansCollection;
  late MockQuerySnapshot mockCustomersSnapshot;
  late MockQuerySnapshot mockTechniciansSnapshot;
  late MockQuery mockTechniciansQuery;
  late MockDocumentReference mockDocumentReference;
  late MockHttpClient httpClient;
  late MockAdmin mockAdmin;
  late MockAdminController mockAdminController;
  late List<DocumentSnapshot> mockDocumentSnapshotList;

  final mockNavigatorObserver = MockNavigatorObserver();

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCustomersCollection = MockCollectionReference();
    mockTechniciansCollection = MockCollectionReference();
    mockCustomersSnapshot = MockQuerySnapshot();
    mockTechniciansSnapshot = MockQuerySnapshot();
    mockTechniciansQuery = MockQuery();
    mockDocumentReference = MockDocumentReference();
    httpClient = MockHttpClient();
    mockAdminController = MockAdminController();
    mockDatabase = MockDatabase(mockFirestore);
    mockAdmin = MockAdmin(mockFirestore, httpClient);
    registerFallbackValue(Uri());
  });

  group('Administration', () {
    test('Retrieve user account data', () async {
      final mockCustomerDoc1 = MockQueryDocumentSnapshot();
      final mockCustomerDoc2 = MockQueryDocumentSnapshot();
      final mockTechnicianDoc1 = MockQueryDocumentSnapshot();
      final mockTechnicianDoc2 = MockQueryDocumentSnapshot();

      final expectedUserData = {
        'doc': [
          mockCustomerDoc1,
          mockCustomerDoc2,
          mockTechnicianDoc1,
          mockTechnicianDoc2,
        ],
        'accountType': ['Customer', 'Customer', 'Technician', 'Technician'],
      };

      when(() => mockFirestore.collection('customers'))
          .thenReturn(mockCustomersCollection);
      when(() => mockFirestore.collection('technicians'))
          .thenReturn(mockTechniciansCollection);
      when(() => mockCustomersCollection.get())
          .thenAnswer((_) async => mockCustomersSnapshot);
      when(() => mockTechniciansCollection.where('approvalStatus',
          isEqualTo: true)).thenReturn(mockTechniciansQuery);
      when(() => mockCustomersCollection.get())
          .thenAnswer((_) async => mockCustomersSnapshot);
      when(() => mockTechniciansQuery.get())
          .thenAnswer((_) async => mockTechniciansSnapshot);

      when(() => mockCustomersSnapshot.docs).thenReturn([
        mockCustomerDoc1,
        mockCustomerDoc2,
      ]);
      when(() => mockTechniciansSnapshot.docs).thenReturn([
        mockTechnicianDoc1,
        mockTechnicianDoc2,
      ]);

      final result = await mockDatabase.readUserData();

      expect(result, equals(expectedUserData));

      verify(() => mockFirestore.collection('customers')).called(1);
      verify(() => mockFirestore.collection('technicians')).called(1);
      verify(() => mockTechniciansCollection.where('approvalStatus',
          isEqualTo: true)).called(1);
      verify(() => mockCustomersCollection.get()).called(1);
      verify(() => mockTechniciansQuery.get()).called(1);
    });

    test('Delete user account', () async {
      const customerID = 'ABC123';

      when(() => mockFirestore.collection('customers'))
          .thenReturn(mockCustomersCollection);
      when(() => mockCustomersCollection.doc(any()))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.delete())
          .thenAnswer((_) async => Future<void>.value());

      await mockDatabase.deleteUser('Customer', customerID);

      verify(() => mockFirestore.collection('customers')).called(1);
      verify(() => mockCustomersCollection.doc(customerID)).called(1);
      verify(() => mockDocumentReference.delete()).called(1);
    });

    test('Approve technician’s registration request', () async {
      const technicianID = 'DEF456';

      when(() => mockFirestore.collection('technicians'))
          .thenReturn(mockTechniciansCollection);
      when(() => mockTechniciansCollection.doc(technicianID))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any()))
          .thenAnswer((_) async => Future<void>.value());

      await mockAdmin.approveRegistrationRequest(technicianID,
          "Anthony Fong An Tian", "anthony@gmail.com", "0192882733");

      verify(() => mockFirestore.collection('technicians')).called(1);
      verify(() => mockTechniciansCollection.doc(technicianID)).called(1);
      verify(() => mockDocumentReference.update({'approvalStatus': true}))
          .called(1);
    });

    test('Reject technician’s registration request', () async {
      const technicianID = 'DEF456';

      when(() => mockFirestore.collection('technicians'))
          .thenReturn(mockCustomersCollection);
      when(() => mockCustomersCollection.doc(any()))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.delete())
          .thenAnswer((_) async => Future<void>.value());

      await mockAdmin.rejectRegistrationRequest(technicianID,
          "Anthony Fong An Tian", "anthony@gmail.com", "0192882733");

      verify(() => mockFirestore.collection('technicians')).called(1);
      verify(() => mockCustomersCollection.doc(technicianID)).called(1);
      verify(() => mockDocumentReference.delete()).called(1);
    });

    test('Send notification email to technician', () async {
      const name = "Anthony Fong An Tian";
      const email = "anthony@gmail.com";
      const message =
          "Your technician registration associated with 0192882733 in BetterHome has been approved. Kindly login now.";
      const subject = "Registration approved";

      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => httpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => mockResponse);

      final response =
          await mockAdmin.sendNotificationEmail(name, email, message, subject);

      verify(
        () => httpClient.post(
          any(),
          headers: {'Content-Type': 'application/json'},
          body: any(named: 'body'),
        ),
      ).called(1);

      expect(response, 200);
    });

    testWidgets('Filter service list by date range',
        (WidgetTester tester) async {
      final initialServices = [
        {
          'id': '1',
          'serviceName': 'Service 1',
          'serviceStatus': 'Confirmed',
          'dateTimeSubmitted': Timestamp.fromDate(DateTime(2023, 6, 24))
        },
        {
          'id': '2',
          'serviceName': 'Service 2',
          'serviceStatus': 'Assigning',
          'dateTimeSubmitted': Timestamp.fromDate(DateTime(2023, 6, 29))
        },
        {
          'id': '3',
          'serviceName': 'Service 3',
          'serviceStatus': 'Confirmed',
          'dateTimeSubmitted': Timestamp.fromDate(DateTime(2023, 6, 25))
        },
      ];

      mockDocumentSnapshotList = initialServices.map((service) {
        final mockDocumentSnapshot = MockDocumentSnapshot();
        when(() => mockDocumentSnapshot.id).thenReturn(service['id'] as String);
        when(() => mockDocumentSnapshot['serviceName'])
            .thenReturn(service['serviceName'] as String);
        when(() => mockDocumentSnapshot['serviceStatus'])
            .thenReturn(service['serviceStatus'] as String);
        when(() => mockDocumentSnapshot['dateTimeSubmitted'])
            .thenReturn(service['dateTimeSubmitted'] as dynamic);
        return mockDocumentSnapshot;
      }).toList();

      when(() => mockAdminController.retrieveServices())
          .thenAnswer((_) async => mockDocumentSnapshotList);

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceListPage(adminCon: mockAdminController),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify initial service list
      expect(find.text('Service 1'), findsOneWidget);
      expect(find.text('Service 2'), findsOneWidget);
      expect(find.text('Service 3'), findsOneWidget);

      // filter date range
      await tester.tap(find.text('Select date range'));
      await tester.pumpAndSettle();

      final selectedDates = DateTimeRange(
        start: DateTime(2023, 6, 26),
        end: DateTime(2023, 6, 28),
      );

      // Simulate the date range picker dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify that the service list is updated according to the selected date range
      expect(find.text('Service 2'), findsOneWidget);
      expect(find.text('Service 1'), findsNothing);
      expect(find.text('Service 3'), findsNothing);
    });

    test('Change service status to “Refunded”', () async {
      const id = '12345';
      final userCollection = MockCollectionReference();

      when(() => mockFirestore.collection('services'))
          .thenReturn(userCollection);
      when(() => userCollection.doc(id)).thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any()))
          .thenAnswer((_) async => Future<void>.value());

      await mockDatabase.updateRefundStatus(id);

      verify(() => mockDocumentReference.update({'serviceStatus': 'Refunded'}))
          .called(1);
    });

    test('Retrieve technician’s ratings and reviews (reviews found)', () async {
      const technicianID = 'ABC123';
      const ratingData = {
        'starQty': 4.5,
        'reviewText': 'Great service',
      };

      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs)
          .thenReturn([mockQueryDocumentSnapshot]);
      when(() => mockQueryDocumentSnapshot.data()).thenReturn(ratingData);

      final result = await mockDatabase.readRating(technicianID);

      expect(result, [ratingData]);
    });

    test('Retrieve technician’s ratings and reviews (reviews not found)',
        () async {
      const technicianID = 'DEF456';

      final mockCollectionReference = MockCollectionReference();
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => mockFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final result = await mockDatabase.readRating(technicianID);

      expect(result, isEmpty);
    });

    test('Calculate average rating', () {
      final ratingDataList = [
        {'starQty': 4.5},
        {'starQty': 3.5},
        {'starQty': 5.0},
      ];
      const expectedAvgRating = 4.333333333333333;

      final result = mockAdminController.calculateAvgRating(ratingDataList);

      expect(result, expectedAvgRating);
    });
  });
}

class MockAdmin extends Mock implements Admin {
  final MockFirebaseFirestore _firebaseFirestore;
  final MockHttpClient _httpClient;

  MockAdmin(this._firebaseFirestore, this._httpClient);

  @override
  Future<void> removeUserAccount(String accountType, String id) async {
    MockDatabase firestore = MockDatabase(_firebaseFirestore);
    await firestore.deleteUser(accountType, id);
  }

  @override
  Future<void> rejectRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    removeUserAccount("Technician", id);
  }

  @override
  Future<void> approveRegistrationRequest(
      String id, String name, String email, String phoneNumber) async {
    MockDatabase firestore = MockDatabase(_firebaseFirestore);
    await firestore.updateApprovalStatus(id);
  }

  @override
  Future sendNotificationEmail(
      String name, String email, String message, String subject) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    const serviceId = 'service_maoya7g';
    const templateId = 'template_c2b1sda';
    const userId = 'haj1CA0xZVtU10OOu';
    final response = await _httpClient.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'to_name': name,
            'to_email': email,
            'subject': subject,
            'message': message
          }
        }));
    return response.statusCode;
  }
}

class MockDatabase extends Mock implements Database {
  final MockFirebaseFirestore _firebaseFirestore;

  MockDatabase(this._firebaseFirestore);

  @override
  Future<Map<String, dynamic>> readUserData() async {
    final customersQuery = _firebaseFirestore.collection('customers');
    final techniciansQuery = _firebaseFirestore
        .collection('technicians')
        .where('approvalStatus', isEqualTo: true);

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

  @override
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

  @override
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

  @override
  Future<void> updateRefundStatus(String id) async {
    try {
      final userCollection = _firebaseFirestore.collection("services");
      final userDoc = userCollection.doc(id);

      await userDoc.update({'serviceStatus': 'Refunded'});
    } catch (e) {
      throw PlatformException(
          code: 'update-status-failed', message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> readRating(String technicianID) async {
    final ratingQuerySnapshot = await _firebaseFirestore
        .collection('ratings')
        .where('technicianID', isEqualTo: technicianID)
        .get();

    if (ratingQuerySnapshot.docs.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> ratingDataList = [];

    for (final ratingDoc in ratingQuerySnapshot.docs) {
      final ratingData = ratingDoc.data();
      final starQty = ratingData['starQty']?.toDouble() ?? 0.0;
      final reviewText = ratingData['reviewText'] ?? '';

      ratingDataList.add({'starQty': starQty, 'reviewText': reviewText});
    }

    return ratingDataList;
  }
}

class MockAdminController extends Mock implements AdminController {
  @override
  DateTime formatDateTime(Timestamp timestamp) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime dateTime = tz.TZDateTime.from(timestamp.toDate(), location);
    return dateTime;
  }

  @override
  double calculateAvgRating(List<Map<String, dynamic>> data) {
    final List allStarQtys = data
        .where((review) => review.containsKey('starQty'))
        .map((review) => review['starQty'].toDouble())
        .toList();

    final double sum = allStarQtys.reduce((a, b) => a + b);
    return sum / allStarQtys.length;
  }
}
