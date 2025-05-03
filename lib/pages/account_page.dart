import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_services.dart';

class AccountScreen extends StatelessWidget {
  // Initialize AuthServices if not already injected
  final AuthServices _authServices = Get.put(AuthServices());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display user info if available
            Obx(() {
              final user = _authServices.user;
              if (user != null) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      user.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                );
              } else {
                return SizedBox();
              }
            }),
            
            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await _authServices.signOut();
                // After signing out, you might want to navigate to login screen
                // Get.offAll(() => LoginScreen());
              },
              icon: Icon(Icons.logout),
              label: Text(
                'Logout',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}