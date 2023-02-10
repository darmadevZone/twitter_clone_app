import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone_app/core/providers.dart';

import '../core/core.dart';

final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

// access user data -> model.account データの保存,アクセスしたいとき
// get user account -> appwrite.account データの書き込み、作成

abstract class IAuthAPI {
  // singup view (email,password) -> create user account
  //-> return model.Account
  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  });
}

class AuthAPI implements IAuthAPI {
  final Account _account;

  AuthAPI({
    required Account account,
  }) : _account = account;

  @override
  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );

      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? "Error auth_api.dart at 41", stackTrace),
      );
    } catch (e, stackTrace) {
      return left(
        Failure(e.toString(), stackTrace),
      );
    }
  }
}
