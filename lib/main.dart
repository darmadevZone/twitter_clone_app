import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone_app/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone_app/features/auth/view/signup_view.dart';
import 'package:twitter_clone_app/theme/theme.dart';

import 'common/common.dart';
import 'features/home/view/home_view.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAccount = ref.watch(currentUserAccountProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      title: "Twitter Clone App",
      home: userAccount.when(
        data: (user) {
          if (user != null) {
            print(user.email);
            return const HomeView();
          }
          return const SignUpView();
        },
        error: (error, st) => ErrorPage(
          error: error.toString(),
        ),
        loading: () => const LoadingPage(),
      ),
    );
  }
}
