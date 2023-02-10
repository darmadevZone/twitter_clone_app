import 'package:fpdart/fpdart.dart';

import 'core.dart';

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
