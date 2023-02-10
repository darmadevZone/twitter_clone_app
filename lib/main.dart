import 'package:flutter/material.dart';
import 'package:twitter_clone_app/features/auth/view/signup_view.dart';
import 'package:twitter_clone_app/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.theme,
      home: const SignUpView(),
    );
  }
}
