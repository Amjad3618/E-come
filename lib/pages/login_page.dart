import 'package:e_com_1/widgets/custome_btn.dart' show CircularImageButton;
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
        
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/animaton1.json',height:200 ),
            EmailTextField(controller: emailController),
            SizedBox(height: 20,),
            PasswordTextField(controller: passwordController),
            SizedBox(height: 20,),
            Container(
              width: 300,
              height: 120,
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
              ],),
            )
          ],
        ),
      ),
    );
  }
}
