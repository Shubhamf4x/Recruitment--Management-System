import 'package:flutter/material.dart';
import 'Screens/forgot.dart';
import 'Services/dbhelper.dart';
import 'Screens/login.dart';
import 'Screens/signup.dart';
import 'package:project_rms/piechart.dart';

import 'constant/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppDataBase appDatabase = AppDataBase();

  bool isDatabaseInitialized = await appDatabase.isDatabaseInitialized();

  if (!isDatabaseInitialized) {
    await appDatabase.getDatabase();
    await appDatabase.storeDataInDatabase();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: color1,
        canvasColor: color2,
        highlightColor:color3
      ),
      initialRoute: '/',
      routes: {
        '/': (context) =>  LogInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forgot':(context)=>const ForgotPassword(),
      },
    );
  }
}
