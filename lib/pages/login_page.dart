import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Column(
        children: [
          EmailTextField(controller: emailController),
          PasswordTextField(controller: passwordController)
           
        ],
      ),
    );
  }
}
