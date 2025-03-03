import 'package:e_com_1/widgets/custome_btn.dart' show CircularImageButton;
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/fancy)btn.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../widgets/fancy_text.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/animaton1.json', height: 180),
              
              // Name field
               EmailTextField(controller: nameController, hintText: "Name",),
              const SizedBox(height: 20),
              
              // Email field
              EmailTextField(controller: emailController, hintText: "Email",),
              const SizedBox(height: 20),
              
              // Password field
              PasswordTextField(controller: passwordController),
              const SizedBox(height: 20),
              
              
              
              // Terms and conditions checkbox
              const _TermsAndConditions(),
              const SizedBox(height: 20),
              
              // Social login options
              const CustomText(
                text: 'Or sign up with',
                fontSize: 16,
              ),
              SizedBox(
                width: 300,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularImageButton(
                      imagePath: 'assets/images/google.png',
                      onPressed: () {},
                    ),
                    CircularImageButton(
                      imagePath: 'assets/images/apple-logo.png',
                      onPressed: () {},
                    ),
                    CircularImageButton(
                      imagePath: 'assets/images/facebook.png',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomText(
                    text: 'Already have an account?',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate back to login page
                      Navigator.pop(context);
                    },
                    child: const CustomText(
                      text: 'Login',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      textColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // SignUp button
              FancyButton(
                text: 'Sign Up',
                onPressed: () {
                  // Validate and process signup
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }
                  
                  // Proceed with signup
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Name input field widget
class _NameTextField extends StatelessWidget {
  final TextEditingController controller;
  
  const _NameTextField({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
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
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  // Use TapGestureRecognizer here if you want to make this clickable
                ),
                const TextSpan(
                  text: ' and ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Colors.blue,
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