import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fruitadvisor/colors.dart';
import 'package:fruitadvisor/pages/home.dart';
import 'package:fruitadvisor/pages/search.dart';
import 'package:fruitadvisor/pages/login.dart';
import 'package:fruitadvisor/pages/register.dart';
import 'package:fruitadvisor/pages/camera.dart';
import 'package:fruitadvisor/pages/profile.dart';
import 'package:fruitadvisor/pages/history.dart';

void main() async{
  //Supabase setup
  await Supabase.initialize(
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2bWRzanpndGl1bnV5YnFic3FoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3ODYzMDIsImV4cCI6MjA1MDM2MjMwMn0.AUDxxuJAW-DNF0KVYu4uJEq7wm-uZD16dM8NscQqbmo",
    url: "https://vvmdsjzgtiunuybqbsqh.supabase.co" 
  );
  runApp(FruitAdvisorApp());
}

class FruitAdvisorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/search': (context) => SearchPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/camera': (context) => CameraPage(),
        '/profile': (context) => ProfilePage(),
        '/history': (context) => HistoryPage(),
      }
    );
  }
}

