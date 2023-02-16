import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/common/loading_page.dart';
import 'package:twitter_clone_app/common/rounded_small_button.dart';
import 'package:twitter_clone_app/constants/ui_constants.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/auth/view/signup_view.dart';
import 'package:twitter_clone_app/features/auth/widgets/auth_field.dart';
import 'package:twitter_clone_app/theme/pallete.dart';

class LoginView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const LoginView(),
      );
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appbar = UIConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onLogin() {
    final email = emailController.text;
    final password = passwordController.text;
    ref.read(authControllerProvider.notifier).login(
          email: email,
          password: password,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.read(authControllerProvider);
    return Scaffold(
        appBar: appbar,
        body: isLoading
            ? const Loader()
            : Center(
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
                            onTap: onLogin,
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
