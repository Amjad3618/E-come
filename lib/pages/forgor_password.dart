import 'package:flutter/material.dart';
import '../widgets/email_form.dart';
import '../widgets/fancy)btn.dart';
import '../widgets/fancy_text.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const CustomText(
              text: 'Forgot Password',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              isGradient: true,
            ),
            const SizedBox(height: 16),
            
            // Description
            const CustomText(
              text: 'Enter your email address. We will send you a link to reset your password.',
              fontSize: 16,
              textColor: Colors.grey,
            ),
            const SizedBox(height: 40),
            
            // Email field - using your existing email form field
            EmailTextField(controller: emailController,hintText: "Email",),
            const SizedBox(height: 40),
            
            // Reset button
            Center(
              child: FancyButton(
                text: 'Reset Password',
                onPressed: () {
                  // Validate email
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your email')),
                    );
                    return;
                  }
                  
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  // Simulate API call with delay
                  Future.delayed(const Duration(seconds: 2), () {
                    // Close loading dialog
                    Navigator.pop(context);
                    
                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Email Sent'),
                        content: Text(
                          'Password reset link has been sent to ${emailController.text}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Back to login
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Back to login
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CustomText(
                  text: 'Remember password? Back to Login',
                  textColor: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage (how to navigate to this screen)
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
// );