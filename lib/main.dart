import 'package:better_home_admin/controllers/login_controller.dart';
import 'package:better_home_admin/firebase_options.dart';
import 'package:better_home_admin/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(controller: LoginController()),
      debugShowCheckedModeBanner: false,
    );
  }
}
