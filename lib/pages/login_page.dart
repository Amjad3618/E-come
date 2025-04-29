import 'package:e_com_1/widgets/custome_btn.dart' show CircularImageButton;
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/fancybtn.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// Import AuthServicezs
import '../services/auth_services.dart';

// ignore: unused_shown_name
import '../bottom_nav/bottom_nav.dart'
    // ignore: unused_shown_name
    show BottomNavController, BottomNavScreen;
import '../utils/color.dart';
import '../widgets/fancy_text.dart';
import 'forgor_password.dart';
import 'singup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // Controllers for form fields
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Get instance of AuthServices
    final AuthServices authServices = Get.put(AuthServices());
    // Function to handle login
    void handleLogin() async {
      // Validate input fields
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter both email and password',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call sign in method from AuthServices
      await authServices.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Check if there's no error and user is logged in
      if (authServices.errorMessage.value.isEmpty &&
          authServices.user != null) {
        // Navigate to home screen
        Get.offAll(() => BottomNavScreen());
      }
    }

    // Function to handle Google sign-in
    void handleGoogleSignIn() async {
      await authServices.signInWithGoogle();

      // Check if user is logged in
      if (authServices.user != null) {
        // Navigate to home screen
        Get.offAll(() => BottomNavScreen());
      }
    }

    // Function to handle Facebook sign-in
    void handleFacebookSignIn() async {
      await authServices.signInWithFacebook();

      // Check if user is logged in
      if (authServices.user != null) {
        // Navigate to home screen
        Get.offAll(() => BottomNavScreen());
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.scaffold.withOpacity(0.9), AppColors.scaffold],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Animation with subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/animations/animaton1.json',
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  const CustomText(
                    text: 'Welcome Back',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const CustomText(
                    text: 'Sign in to continue',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 32),

                  // Email field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: EmailTextField(
                        controller: emailController,
                        hintText: "Email Address",
                        prefixIcon: const Icon(
                          Icons.email,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PasswordTextField(controller: passwordController),
                    ),
                  ),

                  // Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPasswordScreen());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: const CustomText(
                          text: 'FORGOT PASSWORD',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Login button with improved style - Now with authentication logic
                  Obx(
                    () => Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child:
                          authServices.isLoading.value
                              ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                              : FancyButton(
                                text: 'Login',
                                onPressed: handleLogin,
                              ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with text
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomText(
                          text: 'Or login with',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),

                  // Social login options with improved spacing and effects
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google - Updated with auth logic
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CircularImageButton(
                            imagePath: 'assets/images/google.png',
                            onPressed: handleGoogleSignIn,
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Facebook - Updated with auth logic
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CircularImageButton(
                            imagePath: 'assets/images/facebook.png',
                            onPressed: handleFacebookSignIn,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Don't have an account
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.scaffold.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          text: "Don't have an Account?",
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => SignUpPage());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const CustomText(
                            text: 'SignUp',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
