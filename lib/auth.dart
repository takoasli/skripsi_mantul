import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Aplikasi Untuk Admin/DashBoard_Admin.dart';
import 'dashboard/Dashboards.dart';
import 'login.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<String?>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasError) {
                  return const Center(child: Text('Error fetching role'));
                } else {
                  String? role = roleSnapshot.data;
                  // Debug: Print the fetched role
                  print('Fetched role: $role');

                  if (role == 'Admin') {
                    return Dashboard_Admins();
                  } else {
                    return Dashboards();
                  }
                }
              },
            );
          } else {
            return const Login();
          }
        },
      ),
    );
  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
}
