import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone_app/common/rounded_small_button.dart';
import 'package:twitter_clone_app/constants/ui_constants.dart';
import 'package:twitter_clone_app/features/auth/view/signup_view.dart';
import 'package:twitter_clone_app/features/auth/widgets/auth_field.dart';
import 'package:twitter_clone_app/theme/pallete.dart';

class LoginView extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginView(),
      );
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final appbar = UIConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AuthField(
                    controller: emailController,
                    hintText: "Email address",
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    controller: passwordController,
                    hintText: "Password",
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.topRight,
                    child: RoundedSmallButton(
                      onTap: (() => {}),
                      label: "Done",
                      backgroundColor: Pallete.whiteColor,
                      textColor: Pallete.backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      text: "Don't have an account?",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: const TextStyle(
                              color: Pallete.blueColor, fontSize: 16),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context, SignUpView.route());
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
