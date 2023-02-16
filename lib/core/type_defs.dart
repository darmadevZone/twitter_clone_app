import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone_app/core/failure.dart';

// Error -> Failure ,Succes -> T
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;

/**
 * class Failure()
 * String message
 * StackTrace stackTrace
 *
 *
 */
