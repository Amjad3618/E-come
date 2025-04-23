// ignore_for_file: deprecated_member_use

import 'package:e_com_1/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:e_com_1/widgets/custome_btn.dart';
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/fancybtn.dart';
import 'package:e_com_1/widgets/password_form.dart';
import 'package:e_com_1/utils/color.dart';
import 'package:e_com_1/widgets/fancy_text.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    
    // Get instance of AuthController
    final AuthServices authController = Get.put(AuthServices());
    
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
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Title
                  const CustomText(
                    text: 'Create Account',
                     color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  const CustomText(
                    text: 'Enter your details to get started',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: EmailTextField(
                        controller: nameController, 
                        hintText: "Full Name",
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
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
                  const SizedBox(height: 16),
                  
                  // Confirm Password field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PasswordTextField(
                        controller: confirmPasswordController,
                        // labelText: "Confirm Password",
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms and conditions checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.scaffold.withOpacity(0.3),
                    ),
                    child: const _TermsAndConditions(),
                  ),
                  const SizedBox(height: 32),
                  
                  // SignUp button with improved style
                  Obx(() => Container(
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
                    child: authController.isLoading.value
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : FancyButton(
                            text: 'Sign Up',
                            onPressed: () async {
                              // Validate and process signup
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  passwordController.text.isEmpty ||
                                  confirmPasswordController.text.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please fill all fields',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              if (passwordController.text != confirmPasswordController.text) {
                                Get.snackbar(
                                  'Error',
                                  'Passwords do not match',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Proceed with signup
                              await authController.signUp(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                            },
                          ),
                  )),
                  const SizedBox(height: 20),
                  
                  // Divider with text
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomText(
                          text: 'Or sign up with',
                          fontSize: 16,
                          color: AppColors.textPrimary,                          
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
                            onPressed: () async {
                              // Add Google Sign-In functionality here
                              try {
                                await authController.signInWithGoogle();
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Facebook
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
                            onPressed: () async {
                              // Add Facebook Sign-In functionality here
                              try {
                                await authController.signInWithFacebook();
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Already have an account
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.scaffold.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          text: 'Already have an account?',
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate back to login page
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const CustomText(
                            text: 'Login',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Terms and conditions checkbox
class _TermsAndConditions extends StatefulWidget {
  const _TermsAndConditions();

  @override
  State<_TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<_TermsAndConditions> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  // Use TapGestureRecognizer here if you want to make this clickable
                ),
                const TextSpan(
                  text: ' and ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  // Use TapGestureRecognizer here if you want to make this clickable
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}