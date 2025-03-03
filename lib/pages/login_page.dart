import 'package:e_com_1/widgets/custome_btn.dart' show CircularImageButton;
import 'package:e_com_1/widgets/email_form.dart';
import 'package:e_com_1/widgets/password_form.dart' show PasswordTextField;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
          
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/animaton1.json',height:200 ),
              EmailTextField(controller: emailController,hintText: "Email",),
              SizedBox(height: 20,),
              PasswordTextField(controller: passwordController),
              SizedBox(height: 20,),
               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                TextButton(
                  onPressed: () {
                    Get.to(ForgotPasswordScreen());
                  },
                  child: CustomText(text: 'FORGOT PASSWORD'),
                ),
              ],),
              SizedBox(
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
              ), Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                CustomText(text: 'Dont have on Account?',fontSize: 20,fontWeight: FontWeight.bold,),
                TextButton(
                  onPressed: () {
                    Get.to( SignUpPage());
                  },
                  child: CustomText(text: 'SignUp',fontSize: 20,fontWeight: FontWeight.bold,textColor: Colors.blue,),
                ),
              ],),
             
              SizedBox(height:20),
              FancyButton(
                text: 'Login',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
