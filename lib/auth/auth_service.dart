import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  //Sign in
  Future<AuthResponse> signIn(String email, String password) async{
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }
  //Sign Up
  Future<AuthResponse> signUp(String displayName, String email, String password) async{
    return await _supabase.auth.signUp( data: {'display_name': displayName}, email: email, password: password);
  }
  //Sign out
  Future<void> signOut() async{
    await _supabase.auth.signOut();
  }
  //Get user email
  String? getCurrentUserEmail(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
  //Get user name
  String? getCurrentDisplayName(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    final userMetadata = user?.userMetadata;
    return userMetadata != null ? userMetadata['display_name'] : null;
  }

  Future<PostgrestResponse> updateDisplayName(String displayName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from('Users')
        .update({'Display name': displayName})
        .eq('id', user.id);

    return response;
  }

  

}