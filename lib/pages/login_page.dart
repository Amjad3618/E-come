import 'package:e_com_1/widgets/custome_btn.dart' show CircularImageButton;
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../utils/color.dart';
import '../widgets/fancy)btn.dart';
import '../widgets/fancy_text.dart';
import 'forgor_password.dart';
import 'singup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.scaffold.withOpacity(0.9),
              AppColors.scaffold,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                        prefixIcon: const Icon(Icons.email, color: AppColors.primary),
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
                          Get.to(ForgotPasswordScreen());
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
                  
                  // Login button with improved style
                  Container(
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
                    child: FancyButton(
                      text: 'Login',
                      onPressed: () {
                        // Login logic
                      },
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
                        // Google
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
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Apple
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
                            onPressed: () {},
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
                            Get.to(const SignUpPage());
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