import 'package:e_com_1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthServices extends GetxController {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late Rx<User?> _firebaseUser;
  
  // Observable loading state
  RxBool isLoading = false.obs;
  
  // Error message
  RxString errorMessage = ''.obs;

  User? get user => _firebaseUser.value;
  
  @override
  void onInit() {
    super.onInit();
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.authStateChanges());
    
    // This will notify GetX whenever the user state changes
    ever(_firebaseUser, _setInitialScreen);
  }
  
  _setInitialScreen(User? user) {
    if (user == null) {
      // If user is not logged in, navigate to login page
      // You can replace this with your login route
      // Get.offAll(() => LoginPage());
    } else {
      // If user is logged in, navigate to home page
      // You can replace this with your home route
      // Get.offAll(() => HomePage());
    }
  }
  
  // Sign up with email and password
 // Sign up with email and password
Future<void> signUp({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    isLoading(true);
    errorMessage('');

    // Create user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the UID from Firebase user
    String uid = userCredential.user!.uid;

    // Create the UserModel object with the UID
    UserModel userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      password: "",
      confirmpassword: "",
    );

    // Store user data in Firestore with UID as the document ID
    await _firestore.collection('Clients').doc(uid).set(userModel.toJson());

    // Update user display name
    await userCredential.user!.updateDisplayName(name);

    // Show success message
    Get.snackbar(
      'Success',
      'Account created successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Navigate to home screen or login screen
    // Get.offAll(() => HomePage());
  } on FirebaseAuthException catch (e) {
    String message = '';
    if (e.code == 'weak-password') {
      message = 'The password provided is too weak';
    } else if (e.code == 'email-already-in-use') {
      message = 'The account already exists for that email';
    } else if (e.code == 'invalid-email') {
      message = 'The email address is not valid';
    } else {
      message = e.message ?? 'An error occurred during sign up';
    }

    errorMessage(message);
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } catch (e) {
    errorMessage(e.toString());
    Get.snackbar(
      'Error',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading(false);
  }
}

  
  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading(true);
      errorMessage('');
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user';
      } else {
        message = e.message ?? 'An error occurred during sign in';
      }
      
      errorMessage(message);
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAll(LoginPage());
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Sign in with Google - you can implement this if needed
  Future<void> signInWithGoogle() async {
    // Implement Google Sign-In logic here
  }
  
  // Sign in with Facebook - you can implement this if needed
  Future<void> signInWithFacebook() async {
    // Implement Facebook Sign-In logic here
  }
}