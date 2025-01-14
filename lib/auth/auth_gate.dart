//Continuously listen for auth state changes

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fruitadvisor/pages/home.dart';
import 'package:fruitadvisor/pages/login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot){
        //loading..
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(body: Center(child: CircularProgressIndicator()),);
        }
        //Check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if(session != null){
          return HomePage();
        }else{
          return LoginPage();
        }
      }
    );
  }
}