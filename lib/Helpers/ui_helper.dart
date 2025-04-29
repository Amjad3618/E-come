import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:e_com_1/pages/login_page.dart';
import 'package:e_com_1/pages/home_page.dart'; // Import your home page

class AuthHelper {
  // Check if user is logged in and navigate accordingly
  static void handleAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, navigate to home page
        Get.offAll(() => HomeScreen());
      } else {
        // User is signed out, navigate to login page
        Get.offAll(() => LoginPage());
      }
    });
  }

  // Sign out method
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LoginPage());
  }
  
  // Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
  
  // Check if user is logged in
  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}