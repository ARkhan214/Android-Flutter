import 'package:flutter/material.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/page/registrationpage.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});




  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: LoginPage(),


    );
  }
}
