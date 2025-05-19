import 'package:adoption_ui_app/main/login_user.dart';
import 'package:flutter/material.dart';
import 'theme/color.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawGuard',
      theme: ThemeData(primaryColor: AppColor.primary),
      home: LoginPage(),
    );
  }
}
