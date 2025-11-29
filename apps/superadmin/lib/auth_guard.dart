import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginPage();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: _checkUserRole(session.user.id),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasError || 
                roleSnapshot.data == null || 
                roleSnapshot.data!['role'] != 'superadmin') {
              // Sign out and redirect to login
              Supabase.instance.client.auth.signOut();
              return const LoginPage();
            }

            return child;
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _checkUserRole(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }
}